using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Components;
using GameObjects;
using Models;
using Unity.Collections;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[RequireComponent(typeof(CaptureExportManager))]
[RequireComponent(typeof(OrientationObserver))]
public class ArSessionMain : MonoBehaviour
{
    private const float Width = 1280;
    private static float Height => Width * Math.Min(Screen.width, Screen.height) / Math.Max(Screen.width, Screen.height);
    private static float ScaleFactor => Math.Max(Screen.width, Screen.height) / Width;

    private const float UpdatesPerSecond = 5;
    private const float MaximumActiveRequests = 5;

    private CaptureExportManager _captureExportManager;
    private OrientationObserver _orientationObserver;
    
    public ARSession arSession;
    public ARCameraManager cameraManager;
    public BoundingBoxManager boundingBoxManager;
    public SettingsManager settingsManager;

    private float _lastTime;

    private List<ObjectClassification> _currentClassifications;
    private byte[] _currentJpgBytes;

    private int _activeRequests;

    private void Awake()
    {
        _captureExportManager = GetComponent<CaptureExportManager>();
        _orientationObserver = GetComponent<OrientationObserver>();
    }

    private IEnumerator Start() {
        if (ARSession.state == ARSessionState.None ||
            ARSession.state == ARSessionState.CheckingAvailability)
        {
            yield return ARSession.CheckAvailability();
        }

        if (ARSession.state == ARSessionState.Unsupported)
        {
            Debug.LogError("AR Foundation not supported on this device");
        }
        else
        {
            arSession.enabled = true;

            Debug.Log("AR Session started");
            
            ServicePointManager.ServerCertificateValidationCallback += (sender, cert, chain, sslPolicyErrors) => true;
        }
    }

    private void OnEnable()
    {
        cameraManager.frameReceived += OnCameraFrameReceived;
    }

    private void OnDisable()
    {
        cameraManager.frameReceived -= OnCameraFrameReceived;
    }

    private void OnCameraFrameReceived(ARCameraFrameEventArgs eventArgs)
    {
        if (1 / (Time.realtimeSinceStartup - _lastTime) > UpdatesPerSecond)
        {
            return;
        }
        _lastTime = Time.realtimeSinceStartup;
        
        if (_activeRequests >= MaximumActiveRequests)
        {
            return;
        }
        
        var urlString = settingsManager.SettingsModel.activeEndpoint?.url;
        if (urlString == null || !Uri.IsWellFormedUriString(urlString, UriKind.Absolute))
        {
            Debug.LogErrorFormat("Invalid model endpoint URL: {0}", urlString);
            return;
        }
        
        if (!cameraManager.TryGetLatestImage(out var image))
        {
            return;
        }

        StartCoroutine(ProcessImage(image));
        image.Dispose();
    }

    // Can be called from native platforms to capture current image
    // ReSharper disable once UnusedMember.Global
    public void CaptureWithFormat(string formatString)
    {
        var exportFormat = CaptureExportManager.CaptureExportFormatFromString(formatString);

        if (!exportFormat.HasValue)
        {
            Debug.LogErrorFormat("Cannot parse capture export format from string: {0}", formatString);
            return;
        }

        byte[] labeledImageBytes = null;
        if (exportFormat == CaptureExportManager.CaptureExportFormat.Both ||
            exportFormat == CaptureExportManager.CaptureExportFormat.LabeledImage)
        {
            var currentCamera = cameraManager.GetComponent<Camera>();
            var image = Utils.TakeScreenshotOfCamera(currentCamera, Screen.width, Screen.height);
            labeledImageBytes = image.EncodeToJPG();
            Destroy(image);
        }

        _captureExportManager.ExportCaptureAsFormat(exportFormat.Value, 
            labeledImageBytes, 
            _currentJpgBytes, 
            new Vector2Int((int) Width, (int) Height), 
            _currentClassifications);
    }

    private IEnumerator ProcessImage(XRCameraImage image)
    {
        using (var request = image.ConvertAsync(new XRCameraImageConversionParams
        {
            inputRect = new RectInt(0, 0, image.width, image.height),
            outputDimensions = new Vector2Int((int) Width, (int) Height),
            outputFormat = TextureFormat.RGBA32,
            transformation = CameraImageTransformation.MirrorY
        }))
        {
            while (!request.status.IsDone())
            {
                yield return null;
            }

            if (request.status != AsyncCameraImageConversionStatus.Ready)
            {
                Debug.LogErrorFormat("Image request failed with status {0}", request.status);
                yield break;
            }
        
            _currentJpgBytes = ConvertBufferToJpg(request.GetData<byte>(), request.conversionParams);
        }

        using (var client = new HttpClient { Timeout = TimeSpan.FromMilliseconds(2000) })
        {
            if (settingsManager.SettingsModel.activeEndpoint?.url == null)
            {
                Debug.LogWarning("Null Model Endpoint URL");
                yield break;
            }
            
            var content = new ByteArrayContent(_currentJpgBytes);
            content.Headers.Add("Content-Type", "image/jpg");
            
            _activeRequests += 1;
            var startTime = Time.realtimeSinceStartup;
            
            Task<HttpResponseMessage> webRequestTask;
            try
            {
                webRequestTask = client.PostAsync(new Uri(settingsManager.SettingsModel.activeEndpoint?.url), content);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                yield break;
            }

            yield return Utils.WaitForTaskToComplete(webRequestTask);
            _activeRequests -= 1;

            Console.WriteLine("Round trip: " + (Time.realtimeSinceStartup - startTime));
            
            if (!webRequestTask.Result.IsSuccessStatusCode)
            {
                Debug.LogErrorFormat("Error While Sending: {0}", webRequestTask.Result.ReasonPhrase);
                yield break;
            }

            var stringReadingTask = webRequestTask.Result.Content.ReadAsStringAsync();
            yield return Utils.WaitForTaskToComplete(stringReadingTask);

            // Wrap output in top-level object for JsonUtility
            var text = "{\"objects\":" + stringReadingTask.Result + "}";

            // If JSON output does not have an array, the response was not a 200 OK
            // I wish JsonUtility had error handling
            if (!text.Contains("["))
            {
                Debug.LogErrorFormat("Prediction error: {0}\n", stringReadingTask.Result);
                yield break;
            }
            
            var rotation = RotationForScreenOrientation();
            if (!rotation.HasValue)
            {
                Debug.LogErrorFormat("Invalid screen orientation: {0}", _orientationObserver.ScreenOrientation);
                yield break;
            }

            _currentClassifications = JsonUtility.FromJson<JsonWrapper>(text).objects
                .FindAll(it => it.score >= settingsManager.SettingsModel.predictionScoreThreshold);
        
            var classifications = _currentClassifications
                .ConvertAll(old => new ObjectClassification(old.label,
                    old.label_id,
                    old.box
                        .RotatedBy(rotation.Value, new Vector2(Width, Height))
                        .ScaledBy(ScaleFactor),
                    old.score));

            boundingBoxManager.SetObjectClassifications(classifications);
        }
    }

    private Rotation? RotationForScreenOrientation()
    {
        switch (_orientationObserver.ScreenOrientation)
        {
            case Orientation.Portrait: return Rotation.Left;
            case Orientation.LandscapeRight: return Rotation.Up;
            case Orientation.PortraitUpsideDown: return Rotation.Right;
            case Orientation.LandscapeLeft: return Rotation.HalfCircle;
        }

        return null;
    }

    private byte[] ConvertBufferToJpg(NativeArray<byte> buffer, XRCameraImageConversionParams conversionParams)
    {
        var texture = new Texture2D(conversionParams.outputDimensions.x,
            conversionParams.outputDimensions.y,
            conversionParams.outputFormat,
            false);
        texture.LoadRawTextureData(buffer);
        texture.Apply();

        var jpgData = texture.EncodeToJPG();
        Destroy(texture);

        return jpgData;
    }

    // JsonUtility needs this wrapper class since it cannot parse a top-level array
    [Serializable]
    private class JsonWrapper
    {
        #pragma warning disable 0649
        public List<ObjectClassification> objects;
        #pragma warning restore 0649
    }
}
