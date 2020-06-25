using System;
using UnityEngine;

namespace Models
{
    [Serializable]
    public class BoundingBox
    {
        // ReSharper disable once InconsistentNaming
        public Point2D top_left;
        
        // ReSharper disable once InconsistentNaming
        public Point2D bottom_right;

        public BoundingBox(Point2D topLeft, Point2D bottomRight)
        {
            top_left = topLeft;
            bottom_right = bottomRight;
        }

        public Vector2 Size()
        {
            return new Vector2(bottom_right.x - top_left.x, bottom_right.y - top_left.y);
        }

        public Vector2 TopRight()
        {
            return new Vector2(bottom_right.x, top_left.y);
        }

        public Vector2 BottomLeft()
        {
            return new Vector2(top_left.x, bottom_right.y);
        }

        public Vector2 MiddlePoint()
        {
            return new Vector2((top_left.x + bottom_right.x) / 2, (top_left.y + bottom_right.y) / 2);
        }

        public BoundingBox RotatedBy(Rotation rotation, Vector2 imageSize)
        {
            var width = imageSize.x;
            var height = imageSize.y;
            
            switch (rotation)
            {
                case Rotation.Left:
                    return new BoundingBox(new Point2D(x: top_left.y, y: width - bottom_right.x), 
                        new Point2D(x: bottom_right.y, y: width - top_left.x));
                case Rotation.Right:
                    return new BoundingBox(new Point2D(x: height - bottom_right.y, y: top_left.x),
                        new Point2D(x: height - top_left.y, y: bottom_right.x));
                case Rotation.HalfCircle:
                    return new BoundingBox(new Point2D(width - bottom_right.x, height - bottom_right.y), 
                        new Point2D(x: width - top_left.x, y: height - top_left.y));
                case Rotation.Up:
                    return this;
                default:
                    throw new ArgumentOutOfRangeException(nameof(rotation), rotation, null);
            }
        }

        public BoundingBox ScaledBy(float scaleFactor)
        {
            return new BoundingBox(new Point2D(top_left.x * scaleFactor, top_left.y * scaleFactor),
                new Point2D(bottom_right.x * scaleFactor, bottom_right.y * scaleFactor));
        }
    }

    [Serializable]
    public class Point2D
    {
        public float x;
        public float y;

        public Point2D(float x, float y)
        {
            this.x = x;
            this.y = y;
        }

        public Vector2 AsVector2()
        {
            return new Vector2(x, y);
        }
    }
}
