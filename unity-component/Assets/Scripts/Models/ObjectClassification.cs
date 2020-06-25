namespace Models
{
    [System.Serializable]
    public class ObjectClassification
    {
        public string label;
        public int label_id;
        public BoundingBox box;
        public float score;

        public ObjectClassification(string label, int labelId, BoundingBox box, float score)
        {
            this.label = label;
            label_id = labelId;
            this.box = box;
            this.score = score;
        }
    }
}