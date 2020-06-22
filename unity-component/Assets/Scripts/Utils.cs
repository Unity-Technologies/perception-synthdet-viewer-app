using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Utils
{
    public static Color ColorFromRgba255(short r, short g, short b, short a = 255) {
        return new Color((float) r / 255, (float) g / 255, (float) b / 255, (float) a / 255);
    }
}

public enum Rotation
{
    Left, 
    Right, 
    HalfCircle
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
            int charLocation = text.IndexOf(stopAt, StringComparison.Ordinal);

            if (charLocation > 0)
            {
                return text.Substring(0, charLocation);
            }
        }

        return String.Empty;
    }
}
