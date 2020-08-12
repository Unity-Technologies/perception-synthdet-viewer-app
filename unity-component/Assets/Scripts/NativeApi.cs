using System.Runtime.InteropServices;

#if UNITY_IOS
/// <summary>
/// Native bridge from Unity to iOS. All these functions are implemented in ObjC on the iOS side of things
/// </summary>
public static class NativeApi {
    [DllImport("__Internal")]
    public static extern void arFoundationDidReceiveCameraFrame(byte[] bytes, int count);
    
    [DllImport("__Internal")]
    public static extern void settingsJsonDidChange(char[] json, int count);
    
    [DllImport("__Internal")]
    public static extern void imageRequestHandler(byte[] bytes, int count);
}
#endif