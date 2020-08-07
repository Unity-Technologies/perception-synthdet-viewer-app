![App on iPad Pro](docs/images/app-on-ipad.PNG)

# SynthDet Viewer App for iOS
Test your machine learning models generated with Unity SynthDet in real life using Unity SynthDet Viewer! This app uses your device’s camera to send a stream of pictures to your machine learning models. Host your machine learning models online, and point the app to your server. Bounding boxes will appear around everything your ML models detect. Capture, share, and export the results of your object detection.

This is an app for iPhone and iPad that displays results of object detection machine learning models in augmented reality. For AR, this app uses Unity AR Foundation. Bounding boxes of detected objects are added to points in the real world through AR. The app relies on a web API for prediction. We use TorchServe to host our SynthDet model. The app consists of two parts: the Unity component and native iOS component. 

## Features
* Augmented Reality rendering of bounding boxes around your ML model's predictions
* Customizable experience with ability to change minimum prediction score, and easily editable model list
* Switch models in the Viewer live, for easy comparison in training between many models
* Capture, share, and export the results of your object detection

## Usage

| Section | Steps |
| ------- | ----- |
| Dependencies | TorchServe REST server: Host your SynthDet trained model using [perception-synthdet-torchserve](https://github.com/Unity-Technologies/perception-synthdet-torchserve).<br/>You can also [host your own object dection model](https://github.com/Unity-Technologies/perception-synthdet-viewer-app/blob/master/docs/custom-models.md).|
| Installation | <ul><li>Install the app from the [App Store]() (recommended), or</li><li> Build from source with the steps in [How to Build](https://github.com/Unity-Technologies/perception-synthdet-viewer-app/blob/master/docs/how-to-build.md)</li></ul> |
| Run | <ol><li>Run the app, and tap on Settings in the top right corner. Tap Edit Models, and then Add Model Endpoint.</li><li>In the row for your new model endpoint, enter a name (this can be anything you want, something to remember the model by). Then, enter the URL where the app should send prediction requests. If you don't want to type in a long URL on your iOS device, feel free to use the `qr.sh` script in perception-synthdet-torchserve, which will generate QR codes for the model endpoints it exposes.</li><li>Tap Done Editing, then Done.</li><li>Select your model by tapping Choose Model at the bottom of your screen. If the button displays the name of one of your models, that model is selected.</li><li>Point your device at detectable objects, and watch the boxes be drawn!</li></ol> |

### Button Functions
| Button | What it does | Where it is |
| ------ | ------------ | ----------- |
| Choose Model / {model name} | Tap to choose the active model | Bottom center of the main screen |
| Shutter Button | Circular button that takes a picture of the current image on screen, and saves a COCO export of the scene as well, for data analysis | On the middle right side of the screen |
| Share Captures | Shares a folder of all captures taken with the Shutter Button. This uses the iOS Share Sheet, so you can share your captures like normal photos on iOS, sending them via AirDrop, Google Drive, email, text, etc | Settings screen |
| Delete All Captures | Deletes all captures taken | Settings screen |
| QR | Reads current camera image for QR codes; if it finds one, places the text in the URL box next to it | Settings screen, on each model row |
