using UnityEngine;

namespace Components
{
    public enum Orientation
    {
        Portrait,
        LandscapeLeft,
        PortraitUpsideDown,
        LandscapeRight,
        Unknown
    }
    
    // Since Screen.orientation isn't always correct, this component is needed to track screen orientation
    public class OrientationObserver : MonoBehaviour
    {
        public Orientation ScreenOrientation { get; private set; } = Orientation.Unknown;

        private void Update()
        {
            switch (Input.deviceOrientation)
            {
                // For the first four, Input.deviceOrientation and screen orientation are the same
                case DeviceOrientation.Portrait: 
                    ScreenOrientation = Orientation.Portrait;
                    break;
                case DeviceOrientation.PortraitUpsideDown: 
                    ScreenOrientation = Orientation.PortraitUpsideDown;
                    break;
                case DeviceOrientation.LandscapeLeft: 
                    ScreenOrientation = Orientation.LandscapeLeft;
                    break;
                case DeviceOrientation.LandscapeRight: 
                    ScreenOrientation = Orientation.LandscapeRight;
                    break;
                default: 
                    // Otherwise, if the orientation is still unknown, fall back on Screen.orientation
                    if (ScreenOrientation == Orientation.Unknown)
                    {
                        ScreenOrientation = OrientationForScreenOrientation(Screen.orientation);
                    }
                    break;
            }
        }
        
        private Orientation OrientationForScreenOrientation(ScreenOrientation so)
        {
            switch (so)
            {
                case UnityEngine.ScreenOrientation.Portrait:
                    return Orientation.Portrait;
                case UnityEngine.ScreenOrientation.PortraitUpsideDown:
                    return Orientation.PortraitUpsideDown;
                case UnityEngine.ScreenOrientation.LandscapeLeft:
                    return Orientation.LandscapeLeft;
                case UnityEngine.ScreenOrientation.LandscapeRight:
                    return Orientation.LandscapeRight;
                default:
                    return Orientation.Unknown;
            }
        }
    }
}
