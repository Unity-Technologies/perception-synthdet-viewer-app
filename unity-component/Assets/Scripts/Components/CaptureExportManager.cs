using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using JetBrains.Annotations;
using Models;
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
        private const string LabeledImagesFolder = "LabeledImages";

        private static string _storagePath;
        private static string _labeledImagesPath;

        private void Start()
        {
            _storagePath = Path.Combine(Application.persistentDataPath, FolderName);
            _labeledImagesPath = Path.Combine(_storagePath, LabeledImagesFolder);
            
            Directory.CreateDirectory(_storagePath);
            Directory.CreateDirectory(_labeledImagesPath);
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
            }

            return null;
        }
        
        public void ExportCaptureAsFormat(CaptureExportFormat format,
            [CanBeNull] byte[] labeledImageBytes,
            [CanBeNull] byte[] originalImageBytes,
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
            
            Debug.Log("Saving capture of current bounding boxes");

            if (format == CaptureExportFormat.LabeledImage || format == CaptureExportFormat.Both)
            {
                SaveLabeledImage(labeledImageBytes);
            }
            
            // TODO: Save original image
        }

        private void SaveLabeledImage(byte[] labeledImageBytes)
        {
            Console.WriteLine(Directory.GetFiles(_labeledImagesPath).ToList().Count);
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

        private string LabeledImageFileNameForNumber(int n) => $"labeled-{n}.jpg";
    }
}