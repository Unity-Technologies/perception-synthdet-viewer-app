# SynthDet Demo App for iOS

## Summary
This is an app for iPhone and iPad that displays results of object detection machine learning models in augmented reality. For AR, this app uses Unity AR Foundation. Bounding boxes of detected objects are added to points in the real world through AR. The app relies on a web API for prediction. In our demo, we use TorchServe to host our SynthDet model. The app consists of two parts: the Unity component and native iOS component. 

## How to build
1. Open the project in Xcode by opening synthdet-demo-app.xcworkspace. Change bundle identifiers and Teams in Xcode. Click on _native-app_ in the Project navigator. Click on the _native-app_ target and change the Team and Bundle Identifier. The Team should be capable of capable of code signing to run on a real iOS device (this app will not work in the SImulator). Any free or paid Apple Developer account can be used for the Team. The Bundle Identifier can be set to any string that is not in use as a bundle identifier already.
2. Change bundle identifiers and Teams in Unity. Click on File and then Build Settings. Click on Player Settings. Under the Identification section, change the Bundle Identifier and Team. The Bundle Identifier should be different than the one used in _native-app_. The Signing Team ID should be the same as the Team ID in Xcode. To find it in Xcode, click on the circled "i" next to Provisioning Profile. The Team ID is the string in the Certificates section in parentheses.
3. Build the Unity component by clicking File and then Build for iOS.
4. Make sure your iOS device is plugged in, and build the _native-app_ scheme in Xcode by selecing it in the top-left corner, and selecting the iOS device as the destination. Then click the play button.
