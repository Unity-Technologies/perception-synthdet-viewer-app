using System.Collections.Generic;
using System.IO;
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

        private static readonly string StoragePath = Path.Combine(Application.persistentDataPath, FolderName);
        private static readonly string LabeledImagesPath = Path.Combine(StoragePath, LabeledImagesFolder);

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
            
            // TODO: Save image
        }
    }
}