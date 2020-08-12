## Developing new Features

The app is made of two parts: a Unity-based component for AR and gathering and drawing bounding boxes, and a UIKit-based native component for the user interface. The native part is written in Swift.
To develop features in Unity, open the C# solution in Rider, Visual Studio, or VSCode. To develop native Swift code and deploy the app to an iOS device, open the synthdet-viewer-app.xcworkspace project. Keep in mind the app will only work on a real iOS device running iOS 13.4 or later. It will not work in the simulator.

### Communicating from Unity to Swift
The path goes from C# to C to Obj-C to Swift. C# can only communicate with C, which can only communicate with Obj-C, which can only communicate with Swift. Because of this it is necessary ☹️ to go through four languages.

Add your function declaration to NativeApi.cs in the Unity project. It will look something like this:
```cs
[DllImport("__Internal")]
public static extern void yourFunction();
```
Add parameters as needed, but make sure to use parameter types allowed both in C# and C.
<br/>
In Native Code/NativeCallProxy.h, create the Obj-C declaration of your method (it's now a method since it belongs to a type: `NativeCallProxy`. It will look something like this:
```obj-c
- (void) yourFunction;
```
Read the paragraph on method arguments of the [wiki](https://en.wikipedia.org/wiki/Objective-C) for formatting your method declaration for some clarity. I had to look at this page many times :]
<br/>
In Native Code/NativeCallProxy.mm, add the C implementation of your function. It will look like this:
```obj-c
void yourFunction() {
    return [api yourFunction];
}
```
In Xcode, open native-app/native-app/Sources/Unity/UnityEmbeddedSwift.swift. Near the bottom of that file, add the Swift implementation of your method you declared in `NativeCallProxy`. It should look like this:
```swift
func yourFunction() {

}
```

As a result, when calling `NativeApi.yourFunction();` in C#, your implenentation of `yourFunction` in Swift from the last step will be called.

### Communicating from Swift to Unity
Thankfully this is much shorter, but it relies on Unity's deprecated reflection way of sending a "message" to a `GameObject`. The message can only be a string, so it is slightly inconvenient for complex types. In Swift, call this function:
```swift
UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("YourGameObject",
        method: "YourMethodOnGameObject", // Can be in any component
        message: theMessage) // Can be nil
```
