using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class Utils : MonoBehaviour
{
    private Utils() { } // No instantiation

    public static Color ColorFromRgba255(short r, short g, short b, short a = 255)
    {
        return new Color((float) r / 255, (float) g / 255, (float) b / 255, (float) a / 255);
    }

    // Take a "screenshot" of a camera's Render Texture
    public static Texture2D TakeScreenshotOfCamera(Camera camera, int width, int height)
    {
        var currentRt = RenderTexture.active;
        var currentCameraTexture = camera.targetTexture;
        
        var rt = new RenderTexture(width, height, 24);
        var image = new Texture2D(rt.width, rt.height);

        camera.targetTexture = rt;
        camera.Render();
        
        RenderTexture.active = camera.targetTexture;

        image.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        image.Apply();
        RenderTexture.active = currentRt;
        camera.targetTexture = currentCameraTexture;
        Destroy(rt);

        return image;
    }
    
    [CanBeNull]
    public static unsafe byte[] GetJpgBytesSync(ARCameraManager cameraManager)
    {
        if (!cameraManager.TryGetLatestImage(out var image))
        {
            return null;
        }
        
        var conversionParams = new XRCameraImageConversionParams
        {
            inputRect = new RectInt(0, 0, image.width, image.height),
            outputDimensions = new Vector2Int(image.width, image.height),
            outputFormat = TextureFormat.RGBA32,
            transformation = CameraImageTransformation.MirrorY
        };
        
        var size = image.GetConvertedDataSize(conversionParams);
        var buffer = new NativeArray<byte>(size, Allocator.Temp);

        image.Convert(conversionParams, new IntPtr(buffer.GetUnsafePtr()), buffer.Length);
        image.Dispose();

        var texture = new Texture2D(
            conversionParams.outputDimensions.x,
            conversionParams.outputDimensions.y,
            conversionParams.outputFormat,
            false);

        texture.LoadRawTextureData(buffer);
        texture.Apply();
        
        var bytes = texture.EncodeToJPG();
        
        buffer.Dispose();
        Destroy(texture);

        return bytes;
    }

    public static IEnumerator WaitForTaskToComplete(Task t)
    {
        while (!t.IsCompleted)
        {
            yield return null;
        }
    }
    
}

public enum Rotation
{
    Left, // Rotate left by 90°
    Right, // Rotate right by 90°
    HalfCircle, // Rotate by 180°
    Up // Rotate by nothing
}

public static class Texture2DExtensions 
{
    // Very expensive to call! Do not call this on any interval!
    public static void Rotate(this Texture2D texture, Rotation rotation)
    {
        var originalPixels = texture.GetPixels32();
        IEnumerable<Color32> rotatedPixels;

        if (rotation == Rotation.HalfCircle)
        {
            rotatedPixels = originalPixels.Reverse();
        }
        else
        {
            // Rotate left:
            var firstRowPixelIndexes = Enumerable.Range(0, texture.height)
                .Select(i => i * texture.width)
                .Reverse()
                .ToArray();
            rotatedPixels = Enumerable.Repeat(firstRowPixelIndexes, texture.width)
                .SelectMany((frpi, rowIndex) => frpi.Select(i => originalPixels[i + rowIndex]));

            if (rotation == Rotation.Right)
            {
                rotatedPixels = rotatedPixels.Reverse();
            }
            
            // Width and Height need to be swapped if image is rotated left or right
            texture.Resize(texture.height, texture.width);
        }
 
        texture.SetPixels32(rotatedPixels.ToArray());
    }
}

public static class IEnumerableExtensions
{
    public static void ForEachIndexed<T>(this IEnumerable<T> enumerable, Action<T, int> action)
    {
        var i = 0;
        foreach (var e in enumerable)
        {
            action(e, i++);
        }
    }
}

public static class StringExtensions
{
    public static string GetUntilOrEmpty(this string text, string stopAt)
    {
        if (!String.IsNullOrWhiteSpace(text))
        {
            var charLocation = text.IndexOf(stopAt, StringComparison.Ordinal);

            if (charLocation > 0)
            {
                return text.Substring(0, charLocation);
            }
        }

        return String.Empty;
    }
}

public static class TextMeshExtensions
{
    // Returns intrinsic content width of a TextMesh. This factors in font sizes and styles.
    public static float GetTextWidth(this TextMesh textMesh)
    {
        var width = 0;
        
        foreach (var symbol in textMesh.text)
        {
            if (textMesh.font.GetCharacterInfo(symbol, out var info, textMesh.fontSize, textMesh.fontStyle))
            {
                width += info.advance;
            }
        }
        
        return width * textMesh.characterSize * 0.1f;
    }
}
