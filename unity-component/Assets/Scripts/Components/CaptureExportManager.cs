using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using JetBrains.Annotations;
using Models;
using Models.Coco;
using UnityEngine;
using Application = UnityEngine.Application;

namespace Components
{
    public class CaptureExportManager : MonoBehaviour
    {
        public enum CaptureExportFormat
        {
            LabeledImage,
            OriginalImageWithJsonAnnotations,
            Both
        }
        
        private const string FolderName = "Captures";
        private const string LabeledImagesFolderName = "LabeledImages";
        private const string OriginalImagesFolderName = "OriginalImagesWithAnnotations";
        private const string CocoDocumentFileName = "annotations.json";

        private static string _storagePath;
        private static string _labeledImagesPath;
        private static string _originalImagesPath;
        private static string _cocoDocumentPath;

        private CocoDocument _cocoDocument;

        private void Start()
        {
            _storagePath = Path.Combine(Application.persistentDataPath, FolderName);
            _labeledImagesPath = Path.Combine(_storagePath, LabeledImagesFolderName);
            _originalImagesPath = Path.Combine(_storagePath, OriginalImagesFolderName);
            _cocoDocumentPath = Path.Combine(_originalImagesPath, CocoDocumentFileName);
            
            CreateDirectories();

            if (File.Exists(_cocoDocumentPath))
            {
                _cocoDocument = JsonUtility.FromJson<CocoDocument>(File.ReadAllText(_cocoDocumentPath));
            }
            else
            {
                _cocoDocument = new CocoDocument();
            }

            // Update info, licenses, categories in annotations.json every time the app starts
            var emptyCocoDoc = CocoDocument.CreateEmptyDocument();
            _cocoDocument.info = emptyCocoDoc.info;
            _cocoDocument.licenses = emptyCocoDoc.licenses;
            _cocoDocument.categories = emptyCocoDoc.categories;

            File.WriteAllText(_cocoDocumentPath, JsonUtility.ToJson(_cocoDocument));
        }

        public static CaptureExportFormat? CaptureExportFormatFromString(string s)
        {
            switch (s)
            {
                case "LabeledImage":
                    return CaptureExportFormat.LabeledImage;
                case "OriginalImageWithJsonAnnotations":
                    return CaptureExportFormat.OriginalImageWithJsonAnnotations;
                case "Both":
                    return CaptureExportFormat.Both;
                default:
                    return null;
            }
        }

        public void ExportCaptureAsFormat(CaptureExportFormat format,
            [CanBeNull] byte[] labeledImageBytes,
            [CanBeNull] byte[] originalImageBytes,
            Vector2Int originalImageSize,
            [CanBeNull] List<ObjectClassification> classifications)
        {
            if (format == CaptureExportFormat.LabeledImage ||
                format == CaptureExportFormat.Both &&
                labeledImageBytes == null)
            {
                Debug.LogError("Cannot export labeled image without labeledImageBytes");
                return;
            }
            
            if (format == CaptureExportFormat.OriginalImageWithJsonAnnotations ||
                format == CaptureExportFormat.Both &&
                originalImageBytes == null)
            {
                Debug.LogError("Cannot export original image without originalImageBytes");
                return;
            }

            if (format != CaptureExportFormat.LabeledImage && classifications == null)
            {
                Debug.LogError("Cannot export annotations without classifications list");
                return;
            }
            
            // Create needed directories if they don't exist yet
            CreateDirectories();
            
            Debug.Log("Saving capture of current bounding boxes");

            if (format == CaptureExportFormat.LabeledImage || format == CaptureExportFormat.Both)
            {
                SaveLabeledImage(labeledImageBytes);
            }
            
            if (format == CaptureExportFormat.OriginalImageWithJsonAnnotations || format == CaptureExportFormat.Both)
            {
                SaveOriginalImage(originalImageBytes, originalImageSize, classifications);
            }
        }
        
        // Can be called from native platforms to delete all captures in Captures folder
        // ReSharper disable once UnusedMember.Global
        public void DeleteAllCaptures()
        {
            Directory.Delete(_storagePath, true); // Delete _storagePath and recursive subdirectories
            
            // Create empty directories and start new coco annotations file
            CreateDirectories();
            InitCocoDocument();
        }

        private void CreateDirectories()
        {
            Directory.CreateDirectory(_storagePath);
            Directory.CreateDirectory(_labeledImagesPath);
            Directory.CreateDirectory(_originalImagesPath);
        }

        private void InitCocoDocument()
        {
            _cocoDocument = CocoDocument.CreateEmptyDocument();
            
            File.WriteAllText(_cocoDocumentPath, JsonUtility.ToJson(_cocoDocument));
        }

        private void SaveLabeledImage(byte[] labeledImageBytes)
        {
            var maxNumber = Directory.GetFiles(_labeledImagesPath).ToList()
                .ConvertAll(it =>
                {
                    var afterDashIndex = it.LastIndexOf("-", StringComparison.Ordinal) + 1;
                    var dotIndex = it.LastIndexOf(".", StringComparison.Ordinal);

                    return int.Parse(it.Substring(afterDashIndex, dotIndex - afterDashIndex));
                })
                .DefaultIfEmpty(0)
                .Max();

            // Save number is 1 plus the maximum previous save number
            var filePath = Path.Combine(_labeledImagesPath, LabeledImageFileNameForNumber(maxNumber + 1));
            
            File.WriteAllBytes(filePath, labeledImageBytes);
            
            Debug.LogFormat("Saved labeled image to {0}", filePath);
        }

        private static string LabeledImageFileNameForNumber(int n) => $"labeled-{n}.jpg";

        private void SaveOriginalImage(byte[] originalImageBytes, Vector2Int imageSize, List<ObjectClassification> classifications)
        {
            Console.WriteLine("COCO DOC: " + _cocoDocument);
            Console.WriteLine("COCO IMAGES: " + _cocoDocument.images);
            Console.WriteLine("COCO INFO: " + _cocoDocument.info);
            
            var imageId = _cocoDocument.images
                .ConvertAll(image => image.id)
                .DefaultIfEmpty(-1)
                .Max() + 1;

            var cocoImage = new CocoImage(imageId, 
                imageSize.x, 
                imageSize.y, 
                OriginalImageFileNameForNumber(imageId), 
                1, 
                DateTime.Now.ToString(CultureInfo.InvariantCulture));

            _cocoDocument.images.Add(cocoImage);

            var cocoAnnotations = classifications
                .ConvertAll(classification =>
                {
                    // Segmentation is four x, y pairs flattened into an array: Top Left, Bottom Left, Bottom Right, Top Right
                    float[] segmentation =
                    {
                        classification.box.top_left.x, classification.box.top_left.y,
                        classification.box.BottomLeft().x, classification.box.BottomLeft().y,
                        classification.box.bottom_right.x, classification.box.bottom_right.y,
                        classification.box.TopRight().x, classification.box.TopRight().y,
                    };

                    // bbox (Bounding Box) is x, y of top left corner, then width and then height
                    float[] bbox =
                    {
                        classification.box.top_left.x, classification.box.top_left.y,
                        classification.box.Size().x, classification.box.Size().y
                    };

                    return new CocoAnnotation(_cocoDocument.annotations.Count,
                        imageId,
                        classification.label_id,
                        segmentation.ToList().ConvertAll(n => (int) n),
                        classification.box.Size().x * classification.box.Size().y,
                        bbox.ToList().ConvertAll(n => (int) n),
                        0);
                });
            
            _cocoDocument.annotations.AddRange(cocoAnnotations);

            var imagePath = Path.Combine(_originalImagesPath, OriginalImageFileNameForNumber(imageId));

            // Write image and COCO annotations document to disk
            File.WriteAllBytes(imagePath, originalImageBytes);
            File.WriteAllText(_cocoDocumentPath, JsonUtility.ToJson(_cocoDocument));
            
            Debug.LogFormat("Saved labeled image to {0} with ID {1}", imagePath, imageId);
        }
        
        private static string OriginalImageFileNameForNumber(int n) => $"original-{n}.jpg";
    }
}
