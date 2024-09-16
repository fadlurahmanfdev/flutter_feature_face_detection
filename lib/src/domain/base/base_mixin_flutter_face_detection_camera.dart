import 'dart:developer';

import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';
import 'package:flutter_feature_face_detection/google_mlkit_face_detection.dart';

mixin BaseMixinFlutterFaceDetectionCamera {
  late FaceDetector faceDetector;

  double _thresholdEyeOpen = 0.35;

  double get thresholdEyeOpen => _thresholdEyeOpen;

  double _thresholdSmiling = 0.35;

  double get thresholdSmiling => _thresholdSmiling;

  void initializeLivenessFaceDetection({
    double thresholdEyeOpen = 0.3,
    double thresholdSmiling = 0.3,
  }) {
    _thresholdEyeOpen = thresholdEyeOpen;
    _thresholdSmiling = thresholdSmiling;

    faceDetector = FlutterFaceDetection.getStreamingFaceDetector();
    log("successfully initialized liveness face detection");
  }

  // is left eye open & right eye closed success
  bool _isLEORECSuccess = false;

  bool get isLEORECSuccess => _isLEORECSuccess;

  int _iteration = 0;

  Future<LivenessModel> detectLivenessLeftEyeOpenAndRightEyeClose(InputImage inputImage) async {
    if (!isLEORECSuccess) {
      final face = await detectFace(inputImage);
      if (face == null) {
        log("face is not detected");
        _reset();
        return LivenessModel(progress: 0, isComplete: false);
      }

      log("leftEyeOpenProbability: ${face.rightEyeOpenProbability}");
      log("rightEyeOpenProbability: ${face.leftEyeOpenProbability}");

      bool leftEyeClose = (face.rightEyeOpenProbability ?? 0.0) < thresholdEyeOpen;
      bool rightEyeOpen = (face.leftEyeOpenProbability ?? 0.0) >= thresholdEyeOpen;
      if (leftEyeClose || rightEyeOpen) {
        log("The left eye is closed, and the right eye is open. Repeat.");
        _reset();
        return LivenessModel(progress: 0.0, isComplete: false);
      }

      // check if left eye open and right eye close
      if (!leftEyeClose && !rightEyeOpen) {
        _iteration++;
        log("success leftEyeClose & rightEyeOpen, iteration change to $_iteration");
      }

      if (_iteration < 3) {
        log("success leftEyeClose & rightEyeOpen, iteration: $_iteration, repeat");
        return LivenessModel(progress: _iteration / 3, isComplete: false);
      }

      if (_iteration >= 3) {
        log("leftEyeClose & rightEyeOpen completed");
        _isLEORECSuccess = true;
        _reset();
        return LivenessModel(progress: 1.0, isComplete: true);
      }
    }

    if (isLEORECSuccess) {
      _reset();
      return LivenessModel(progress: 1.0, isComplete: true);
    }

    return LivenessModel(progress: 0.0, isComplete: false);
  }

  // is right eye open & left eye open close
  bool _isREOLECSuccess = false;

  bool get isREOLECSuccess => _isREOLECSuccess;

  Future<LivenessModel> detectLivenessRightEyeOpenAndLeftEyeClose(InputImage inputImage) async {
    if (!isREOLECSuccess) {
      final face = await detectFace(inputImage);
      if (face == null) {
        log("face is not detected");
        _reset();
        return LivenessModel(progress: 0, isComplete: false);
      }

      log("rightEyeOpenProbability: ${face.leftEyeOpenProbability}");
      log("leftEyeOpenProbability: ${face.rightEyeOpenProbability}");

      bool rightEyeClose = (face.leftEyeOpenProbability ?? 0.0) < thresholdEyeOpen;
      bool leftEyeOpen = (face.rightEyeOpenProbability ?? 0.0) >= thresholdEyeOpen;
      if (rightEyeClose || leftEyeOpen) {
        log("The right eye is closed, and the left eye is open. Repeat.");
        _reset();
        return LivenessModel(progress: 0.0, isComplete: false);
      }

      // check if right eye open and left eye close
      if (!rightEyeClose && !leftEyeOpen) {
        _iteration++;
        log("success rightEyeOpen & leftEyeClose, iteration change to $_iteration");
      }

      if (_iteration < 3) {
        final progress = _iteration / 3;
        log("success rightEyeOpen & leftEyeClose, progress: $progress");
        return LivenessModel(progress: _iteration / 3, isComplete: false);
      }

      if (_iteration >= 3) {
        log("rightEyeOpen & leftEyeClose completed");
        _isREOLECSuccess = true;
        _reset();
        return LivenessModel(progress: 1.0, isComplete: true);
      }
    }

    if (isREOLECSuccess) {
      _reset();
      return LivenessModel(progress: 1.0, isComplete: true);
    }

    return LivenessModel(progress: 0.0, isComplete: false);
  }

  // is smiling
  bool _isSmiling = false;

  bool get isSmiling => _isSmiling;

  Future<LivenessModel> detectSmiling(InputImage inputImage) async {
    if (!isSmiling) {
      final face = await detectFace(inputImage);
      if (face == null) {
        log("face is not detected");
        _reset();
        return LivenessModel(progress: 0, isComplete: false);
      }

      log("smilingProbability: ${face.smilingProbability}");

      bool isSmiling = (face.smilingProbability ?? 0.0) >= thresholdSmiling;
      if (!isSmiling) {
        log("face is smiling: $isSmiling");
        _reset();
        return LivenessModel(progress: 0.0, isComplete: false);
      }

      // check if smiling
      if (isSmiling) {
        _iteration++;
        log("success smiling, iteration change to $_iteration");
      }

      if (_iteration < 3) {
        final progress = _iteration / 3;
        log("success smiling, progress: $progress");
        return LivenessModel(progress: _iteration / 3, isComplete: false);
      }

      if (_iteration >= 3) {
        log("detect smiling completed");
        _isSmiling = true;
        _reset();
        return LivenessModel(progress: 1.0, isComplete: true);
      }
    }

    if (isREOLECSuccess) {
      _reset();
      return LivenessModel(progress: 1.0, isComplete: true);
    }

    return LivenessModel(progress: 0.0, isComplete: false);
  }

  void _reset() {
    _iteration = 0;
  }

  Future<Face?> detectFace(InputImage inputImage) async {
    final faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    return faces.first;
  }

  Future<void> disposeFaceDetector() async {
    await faceDetector.close();
  }
}
