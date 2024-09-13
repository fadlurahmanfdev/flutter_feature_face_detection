import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FlutterFaceDetection {
  static final _orientations = <DeviceOrientation, int>{
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// - [sensorOrientation] from [CameraDescription.sensorOrientation]
  /// - [deviceOrientation] from [CameraController.value.deviceOrientation]
  static InputImage? inputImageFromCameraImage(
    CameraImage cameraImage, {
    required int sensorOrientation,
    required DeviceOrientation deviceOrientation,
    required CameraLensDirection cameraLensDirection,
  }) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    InputImageRotation rotation = InputImageRotation.rotation0deg;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[deviceOrientation];
      if (rotationCompensation == null) return null;
      if (cameraLensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation) ?? InputImageRotation.rotation0deg;
    }
    log("initialized rotation: $rotation");

    final nv21CameraImageBytes = cameraImage.getNv21Uint8List();

    // get image format
    final format = InputImageFormatValue.fromRawValue(cameraImage.format.raw);
    if (format == null) {
      log("failed to get format, format is null");
      return null;
    }

    final planes = cameraImage.planes;
    if (planes.isEmpty) {
      log("planes is empty");
      return null;
    }

    return InputImage.fromBytes(
      bytes: nv21CameraImageBytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: planes.first.bytesPerRow,
      ),
    );
  }

  static FaceDetector getStreamingFaceDetector() {
    return FaceDetector(
      options: FaceDetectorOptions(
        enableTracking: true,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        minFaceSize: .5,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  static FaceDetector getCaptureFaceDetector() {
    return FaceDetector(
      options: FaceDetectorOptions(
        enableTracking: true,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        minFaceSize: .5,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }
}
