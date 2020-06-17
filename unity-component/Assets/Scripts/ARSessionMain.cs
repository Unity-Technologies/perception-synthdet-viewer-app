using System;
using System.Collections;
using System.Runtime.InteropServices;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

#if UNITY_IOS
public static class NativeApi {
    [DllImport("__Internal")]
    public static extern void arFoundationDidReceiveCameraFrame(byte[] bytes, int count);
}
#endif

public class ARSessionMain : MonoBehaviour
{
    private const int Width = 1280;
    private const int Height = 960;

    private const float UpdatesPerSecond = 5;
    
    public ARSession arSession;
    public ARCameraManager cameraManager;

    private float _lastTime = 0;
    
    private IEnumerator Start() {
        if (ARSession.state == ARSessionState.None ||
            ARSession.state == ARSessionState.CheckingAvailability)
        {
            yield return ARSession.CheckAvailability();
        }

        if (ARSession.state == ARSessionState.Unsupported)
        {
            Console.WriteLine("AR Foundation not supported on this device");
        }
        else
        {
            arSession.enabled = true;

            Console.WriteLine("AR Session started");
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
        
        if (!cameraManager.TryGetLatestImage(out var image))
        {
            return;
        }
        
        ProcessImage(image);
    }

    private unsafe void ProcessImage(XRCameraImage image)
    {
        var conversionParams = new XRCameraImageConversionParams
        {
            inputRect = new RectInt(0, 0, image.width, image.height),
            outputDimensions = new Vector2Int(Width, Height),
            outputFormat = TextureFormat.RGBA32,
            transformation = CameraImageTransformation.MirrorY
        };
        var size = image.GetConvertedDataSize(conversionParams);
        var buffer = new NativeArray<byte>(size, Allocator.Temp);

        try
        {
            image.Convert(conversionParams, new IntPtr(buffer.GetUnsafePtr()), buffer.Length);
        }
        finally
        {
            image.Dispose();
        }

        PackageAndSendBuffer(buffer, conversionParams);
    }

    private void PackageAndSendBuffer(NativeArray<byte> buffer, XRCameraImageConversionParams conversionParams)
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
        buffer.Dispose();
        
        #if UNITY_IOS
            NativeApi.arFoundationDidReceiveCameraFrame(jpgData, jpgData.Length);
        #else
            Console.WriteLine("Not using iOS platform - no image data is being sent");
        #endif
    }
}
