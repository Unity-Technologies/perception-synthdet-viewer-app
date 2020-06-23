using System;
using System.Collections;
using System.Collections.Generic;
using Models;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class ArSessionMain : MonoBehaviour
{
    private const float Width = 1280;
    private static float Height => Width * Math.Min(Screen.width, Screen.height) / Math.Max(Screen.width, Screen.height);
    private static float ScaleFactor => Math.Max(Screen.width, Screen.height) / Width;

    private const float UpdatesPerSecond = 5;
    
    public ARSession arSession;
    public ARCameraManager cameraManager;
    public BoundingBoxManager boundingBoxManager;
    public SettingsManager settingsManager;

    private float _lastTime;

    private string _url;
    private float _scoreThreshold = 0.5f;
    
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
        if (1 / (Time.fixedTime - _lastTime) > UpdatesPerSecond)
        {
            return;
        }
        _lastTime = Time.fixedTime;
        
        var urlString = settingsManager.SettingsModel.activeEndpoint?.url;
        if (!Uri.IsWellFormedUriString(urlString, UriKind.Absolute))
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

    // Can be called by iOS to set URL
    // ReSharper disable once UnusedMember.Global
    public void SetUrl(string url)
    {
        _url = url;
    }
    
    // Can be called by iOS to set minimum score; that's why it's a string here and not a float
    // ReSharper disable once UnusedMember.Global
    public void SetScoreThreshold(string score)
    {
        _scoreThreshold = float.Parse(score);
    }

    private IEnumerator ProcessImage(XRCameraImage image)
    {
        var request = image.ConvertAsync(new XRCameraImageConversionParams
        {
            inputRect = new RectInt(0, 0, image.width, image.height),
            outputDimensions = new Vector2Int((int) Width, (int) Height),
            outputFormat = TextureFormat.RGBA32,
            transformation = CameraImageTransformation.MirrorY
        });

        while (!request.status.IsDone())
        {
            yield return null;
        }

        if (request.status != AsyncCameraImageConversionStatus.Ready)
        {
            Debug.LogErrorFormat("Image request failed with status {0}", request.status);
            
            request.Dispose();
            yield break;
        }

        var imageData = request.GetData<byte>();
        var jpgData = ConvertBufferToJpg(imageData, request.conversionParams);
        imageData.Dispose();
        request.Dispose();
        
        var webRequest = GetRequestForImage(jpgData, settingsManager.SettingsModel.activeEndpoint?.url);
        yield return webRequest.SendWebRequest();

        if (webRequest.isNetworkError)
        {
            Debug.LogErrorFormat("Error While Sending: {0}", webRequest.error);
            yield return null;
        }

        webRequest.uploadHandler.Dispose();
        var text = "{\"objects\":" + webRequest.downloadHandler.text + "}";

        // If JSON output does not have an array, the response was not a 200 OK
        // I wish JsonUtility had error handling
        if (!text.Contains("["))
        {
            Debug.LogErrorFormat("Prediction error: {0}\n", webRequest.downloadHandler.text);
            webRequest.downloadHandler.Dispose();
            yield return null;
        }
        webRequest.downloadHandler.Dispose();

        var rotation = Screen.orientation == ScreenOrientation.Landscape ? Rotation.HalfCircle : Rotation.Left;
        
        Console.WriteLine("About to parse");
        var classifications = JsonUtility.FromJson<JsonWrapper>(text).objects
            .FindAll(it => it.score >= settingsManager.SettingsModel.predictionScoreThreshold)
            .ConvertAll(old => new ObjectClassification(old.label,
                old.box
                    .RotatedBy(rotation, new Vector2(Width, Height))
                    .ScaledBy(ScaleFactor),
                old.score));

        boundingBoxManager.SetObjectClassifications(classifications);
    }

    private byte[] ConvertBufferToJpg(NativeArray<byte> buffer, XRCameraImageConversionParams conversionParams)
    {
        var texture = new Texture2D(
            conversionParams.outputDimensions.x,
            conversionParams.outputDimensions.y,
            conversionParams.outputFormat,
            false);
        texture.LoadRawTextureData(buffer);
        texture.Apply();

        var jpgData = texture.EncodeToJPG();
        Destroy(texture);

        return jpgData;
    }

    private UnityWebRequest GetRequestForImage(byte[] jpgData, string modelUrl)
    {
        var request = new UnityWebRequest(modelUrl, UnityWebRequest.kHttpVerbPOST);
        var downloadHandler = new DownloadHandlerBuffer();
        
        request.certificateHandler = new CertificateBypassHandler();
        request.uploadHandler = new UploadHandlerRaw(jpgData);
        request.SetRequestHeader("Content-Type", "image/jpg");
        request.downloadHandler = downloadHandler;

        return request;
    }
    
    // JsonUtility needs this wrapper class since it cannot parse a top-level array
    [Serializable]
    private class JsonWrapper
    {
        #pragma warning disable 0649
        public List<ObjectClassification> objects;
        #pragma warning restore 0649
    }

    private class CertificateBypassHandler : CertificateHandler
    {
        protected override bool ValidateCertificate(byte[] certificateData)
        {
            return true;
        }
    }
}
