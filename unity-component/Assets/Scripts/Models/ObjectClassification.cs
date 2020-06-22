namespace Models
{
    [System.Serializable]
    public class ObjectClassification
    {
        public string label;
        public BoundingBox box;
        public float score;

        public ObjectClassification(string label, BoundingBox box, float score)
        {
            this.label = label;
            this.box = box;
            this.score = score;
        }
    }
}