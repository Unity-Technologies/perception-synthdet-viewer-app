using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Utils
{

}

public static class Texture2DExtensions 
{
    public enum Rotation { Left, Right, HalfCircle }
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
