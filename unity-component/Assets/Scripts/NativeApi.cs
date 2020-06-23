using System.Runtime.InteropServices;

#if UNITY_IOS
public static class NativeApi {
    [DllImport("__Internal")]
    public static extern void arFoundationDidReceiveCameraFrame(byte[] bytes, int count);
    
    [DllImport("__Internal")]
    public static extern void settingsJsonDidChange(char[] json, int count);
}
#endif