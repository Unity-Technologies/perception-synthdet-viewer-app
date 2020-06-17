namespace Models
{
    [System.Serializable]
    public class ObjectClassification
    {
        public string label;
        public BoundingBox box;
        public float score;
    }
}