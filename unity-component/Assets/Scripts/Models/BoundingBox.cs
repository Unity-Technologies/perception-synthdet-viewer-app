using UnityEngine;

namespace Models
{
    [System.Serializable]
    public class BoundingBox
    {
        public Point2D topLeft;
        public Point2D bottomRight;

        public Vector2 Size()
        {
            return new Vector2(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
        }

        public Vector2 TopRight()
        {
            return new Vector2(bottomRight.x, topLeft.y);
        }

        public Vector2 BottomLeft()
        {
            return new Vector2(topLeft.x, bottomRight.y);
        }

        public Vector2 MiddlePoint()
        {
            return new Vector2((topLeft.x + bottomRight.x) / 2, (topLeft.y + bottomRight.y) / 2);
        }
    }

    [System.Serializable]
    public class Point2D
    {
        public float x;
        public float y;

        public Vector2 AsVector2()
        {
            return new Vector2(x, y);
        }
    }
}