# flutter_face_detection

`flutter_face_detection` is a Flutter package designed to streamline face detection and liveness
face detection for developers. It combines the powerful functionality of the Flutter camera library
and Google ML Kit, enabling seamless integration into camera-based applications. The package is
optimized for detecting facial features, such as eye openness and smiling, with configurable
thresholds, making it ideal for liveness verification scenarios.

## Key Features:

- **Face Detection**: Accurately detects faces in real-time using Google ML Kit.
- **Liveness Detection**: Supports advanced liveness detection by analyzing facial movements such as
  eye openness and smiling.
- **Threshold Customization**: Developers can easily adjust thresholds for detecting eye openness
  and smiles to suit various use cases.
- **Camera Integration**: Combines with the `flutter_feature_camera` library to handle camera
  functions like image streaming and camera switching.

## Dependencies:

- [flutter_feature_camera](https://pub.dev/packages/flutter_feature_camera): Facilitates camera
  functionality required for real-time face detection.

This library is ideal for applications that require accurate and real-time face and liveness
detection, such as biometric verification, security, and user authentication.

## Features

<table>
  <tr>
    <td>
		<img width="250px" src="https://raw.githubusercontent.com/fadlurahmanfdev/flutter_feature_face_detection/master/media/face_detection_single_shot.mp4">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/fadlurahmanfdev/flutter_feature_face_detection/master/media/face_detection_streaming.mp4">
    </td>
  </tr>
</table>

### Liveness Face Detection

#### Detect Left Eye Close & Right Eye Open

Detects liveness by checking if the left eye is open and the right eye is closed.

```dart
Future<void> onImageStream(CameraImage cameraImage,
    int sensorOrientation,
    DeviceOrientation deviceOrientation,
    CameraLensDirection cameraLensDirection,) async {
  final inputImage = FlutterFaceDetection.inputImageFromCameraImage(
    cameraImage,
    sensorOrientation: sensorOrientation,
    deviceOrientation: deviceOrientation,
    cameraLensDirection: cameraLensDirection,
  );
  if (inputImage != null) {
    final result = await detectLivenessLeftEyeOpenAndRightEyeClose(inputImage);
    // process result
  }
}
```

#### Detect Right Eye Close & Left Eye Open

Detects liveness by checking if the right eye is open and the left eye is closed.

```dart
Future<void> onImageStream(CameraImage cameraImage,
    int sensorOrientation,
    DeviceOrientation deviceOrientation,
    CameraLensDirection cameraLensDirection,) async {
  final inputImage = FlutterFaceDetection.inputImageFromCameraImage(
    cameraImage,
    sensorOrientation: sensorOrientation,
    deviceOrientation: deviceOrientation,
    cameraLensDirection: cameraLensDirection,
  );
  if (inputImage != null) {
    final result = await detectLivenessRightEyeOpenAndLeftEyeClose(inputImage);
    // process result
  }
}
```

#### Detect Smiling

Detects liveness by checking if the person is smiling.

```dart
Future<void> onImageStream(CameraImage cameraImage,
    int sensorOrientation,
    DeviceOrientation deviceOrientation,
    CameraLensDirection cameraLensDirection,) async {
  final inputImage = FlutterFaceDetection.inputImageFromCameraImage(
    cameraImage,
    sensorOrientation: sensorOrientation,
    deviceOrientation: deviceOrientation,
    cameraLensDirection: cameraLensDirection,
  );
  if (inputImage != null) {
    final result = await detectSmiling(inputImage);
    // process result
  }
}
```

## Getting started

### Change Min SDK Version

in `android/app/build.gradle`, change minSdkVersion to `21`

```gradle
// ..
android {
    // ..
    defaultConfig {
        // ..
        minSdkVersion 21 // change the sdk version
        // ..
    }
}
```

### Import Flutter Feature Camera

```yaml
flutter_feature_camera: ^0.0.6-beta
```

### Extend Base Mixin Class

Extend Stateful Widget with `BaseMixinFlutterFaceDetectionCamera` and `BaseMixinFeatureCameraV2`

## Usage

### Initialized Streaming Camera
```dart
@override
void initState() {
  super.initState();
  initializeStreamingCamera(
    cameraLensDirection: CameraLensDirection.front,
    onCameraInitialized: onCameraInitialized,
  );
}

void onCameraInitialized(_) {
  setState(() {});

  initializeLivenessFaceDetection();
}
```

### Start Streaming Image

```dart
void streamingCameraTap() {
  startImageStream(
    onImageStream: onImageStream,
  );
}

Future<void> onImageStream(
    CameraImage cameraImage,
    int sensorOrientation,
    DeviceOrientation deviceOrientation,
    CameraLensDirection cameraLensDirection,
    ) async {
  final inputImage = FlutterFaceDetection.inputImageFromCameraImage(
    cameraImage,
    sensorOrientation: sensorOrientation,
    deviceOrientation: deviceOrientation,
    cameraLensDirection: cameraLensDirection,
  );
  if (inputImage != null) {
    // process detect liveness here
  }
}
```
