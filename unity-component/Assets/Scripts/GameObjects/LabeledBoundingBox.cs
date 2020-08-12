using System;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace GameObjects
{
    public class LabeledBoundingBox : MonoBehaviour
    {
        private static int _sortOrder;
        
        [SerializeField] public ARCameraManager cameraManager;
        [SerializeField] private SpriteRenderer rectangle;
        [SerializeField] private SpriteRenderer textBackground;
        [SerializeField] private TextMesh textMesh;
    
        public int UpdatesRemaining { get; set; }

        private RectTransform _rectTransform;

        private string _label = "";
        private float _predictionScore;

        private const float TextBackgroundHeight = 0.5f;

        private void Awake()
        {
            _rectTransform = GetComponent<RectTransform>();
            
            // Increment the sort order when box is first created
            _sortOrder++;
        }

        private void Start()
        {
            rectangle.transform.SetParent(transform);
            textBackground.transform.SetParent(rectangle.transform);
            textMesh.transform.SetParent(textBackground.transform);

            // Set the incremented sort order for the rectangle and text background
            // so it never overlaps with another rectangle causing graphical glitches
            rectangle.sortingOrder = _sortOrder;
            textBackground.sortingOrder = _sortOrder;
        }

        private void Update()
        {
            var eulerAngles = cameraManager.transform.eulerAngles;
        
            // Rotate box in the same direction as the camera so the text appears to always face the screen
            transform.eulerAngles = eulerAngles;
        }

        private void UpdateText()
        {
            textMesh.text = $"{_label} - {Math.Round(_predictionScore * 100)}%";
            
            UpdateTextSize();
        }

        private void UpdateTextSize()
        {
            // Set text background size to the larger of text size or width of bounding box
            textBackground.size = new Vector2(Math.Max(textMesh.GetTextWidth(), rectangle.size.x), TextBackgroundHeight);
            
            // Set local position so that the left edge of the text aligns with the left of the background
            // (TextMesh aligns text to the pivot which needs to be centered for positioning)
            textBackground.transform.localPosition = new Vector3((textBackground.size.x - rectangle.size.x) / 2, TextBackgroundHeight / 2 + rectangle.size.y / 2, 0);
            
            // Position text so text aligns to the left, and move it forward by a tiny amount so it does not collide with background
            textMesh.transform.localPosition = new Vector3(-textBackground.size.x / 2, 0, -0.01f);
        }

        public void SetWidth(float width)
        {
            rectangle.size = new Vector2(width, rectangle.size.y);
            _rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, width);
            textBackground.size = new Vector2(width, textBackground.size.y);

            UpdateTextSize();
        }

        public void SetHeight(float height)
        {
            rectangle.size = new Vector2(rectangle.size.x, height);
            _rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, height);

            UpdateTextSize();
        }

        public void SetColor(Color color)
        {
            rectangle.color = color;
            textBackground.color = color;
        }

        public void SetLabel(string label)
        {
            _label = label;
            UpdateText();
        }

        public string GetLabel()
        {
            return _label;
        }

        public void SetPredictionScore(float score)
        {
            _predictionScore = score;
            UpdateText();
        }
    }
}
