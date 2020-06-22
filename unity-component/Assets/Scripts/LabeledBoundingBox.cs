using System;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

[RequireComponent(typeof(TextMesh))]
public class LabeledBoundingBox : MonoBehaviour
{
    public ARCameraManager cameraManager;
    public GameObject rectangle;
    
    public int UpdatesRemaining { get; set; }

    private RectTransform _rectTransform;
    private SpriteRenderer _rectangleSpriteRenderer;
    private TextMesh _textMesh;

    private string _label = "";
    private float _predictionScore;

    private void Awake()
    {
        _rectTransform = GetComponent<RectTransform>();
        _rectangleSpriteRenderer = rectangle.GetComponent<SpriteRenderer>();
        _textMesh = GetComponent<TextMesh>();
        
        
        _textMesh.transform.SetParent(transform);
        _textMesh.color = new Color(0.8f, 0.8f, 0.8f);
        _textMesh.fontStyle = FontStyle.Bold;
        _textMesh.characterSize = 0.040f;
        _textMesh.fontSize = 50;
    }

    private void Update()
    {
        var eulerAngles = cameraManager.transform.eulerAngles;
        
        transform.eulerAngles = eulerAngles;
    }

    private void UpdateText()
    {
        _textMesh.text = $"{_label}\n{Math.Round(_predictionScore * 100)}%";
    }

    public void SetWidth(float width)
    {
        _rectangleSpriteRenderer.size = new Vector2(width, _rectangleSpriteRenderer.size.y);
        _rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, width);
    }

    public void SetHeight(float height)
    {
        _rectangleSpriteRenderer.size = new Vector2(_rectangleSpriteRenderer.size.x, height);
        _rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, height);
    }

    public void SetColor(Color color)
    {
        _rectangleSpriteRenderer.color = color;
        _textMesh.color = color;
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
