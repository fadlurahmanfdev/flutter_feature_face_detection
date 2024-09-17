import 'dart:developer';

import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';
import 'package:flutter_feature_face_detection/google_mlkit_face_detection.dart';

/// A mixin that provides face detection functionality for liveness checks, including eye and smile detection.
///
/// The `BaseMixinFlutterFaceDetectionCamera` mixin is designed to be integrated into camera systems for
/// detecting facial features and performing liveness detection based on eye openness, smiling, and other
/// facial expressions. It supports the following features:
mixin BaseMixinFlutterFaceDetectionCamera {
  late FaceDetector _faceDetector;

  double _thresholdEyeOpen = 0.35;

  double get thresholdEyeOpen => _thresholdEyeOpen;

  double _thresholdSmiling = 0.35;

  double get thresholdSmiling => _thresholdSmiling;

  /// Initializes the liveness face detection system with specified thresholds.
  ///
  /// This function sets up the face detection system for liveness checks by:
  /// 1. Setting thresholds for eye openness and smiling detection.
  /// 2. Initializing the face detector for streaming.
  ///
  /// Parameters:
  /// - [thresholdEyeOpen]: The threshold value for determining if an eye is open.
  ///   Default is 0.3. Values closer to 1.0 make the check more stringent.
  /// - [thresholdSmiling]: The threshold value for determining if a face is smiling.
  ///   Default is 0.3. Values closer to 1.0 make the check more stringent.
  void initializeLivenessFaceDetection({
    double thresholdEyeOpen = 0.3,
    double thresholdSmiling = 0.3,
  }) {
    _thresholdEyeOpen = thresholdEyeOpen;
    _thresholdSmiling = thresholdSmiling;

    _faceDetector = FlutterFaceDetection.getStreamingFaceDetector();
    log("successfully initialized liveness face detection");
  }

  int _iteration = 0;

  // is left eye open & right eye closed success
  bool _isLEORECSuccess = false;

  bool get isLEORECSuccess => _isLEORECSuccess;

  /// Detects liveness by checking if the left eye is open and the right eye is closed.
  ///
  /// This function is part of a liveness detection system that verifies if a person
  /// is present and conscious by analyzing their eye movements.
  ///
  /// Parameters:
  /// - [inputImage]: The [InputImage] to process for face detection.
  ///
  /// Returns:
  /// A [LivenessModel] containing the progress and completion status of the check.
  ///
  /// The function works as follows:
  /// 1. If the check hasn't succeeded yet:
  ///    a. Detects a face in the input image.
  ///    b. If no face is detected, resets and returns 0 progress.
  ///    c. Checks if the left eye is open and the right eye is closed.
  ///    d. If the condition is not met, resets and returns 0 progress.
  ///    e. If the condition is met, increments an iteration counter.
  ///    f. If the iteration counter is less than 3, returns partial progress.
  ///    g. If the iteration counter reaches 3, marks the check as successful and returns complete progress.
  /// 2. If the check has already succeeded, returns complete progress.
  ///
  /// Note:
  /// - The function uses a threshold ([thresholdEyeOpen]) to determine if an eye is open or closed.
  /// - It requires 3 consecutive successful detections to consider the check complete.
  /// - Progress is reported as a value between 0.0 and 1.0.
  Future<LivenessModel> detectLivenessLeftEyeOpenAndRightEyeClose(InputImage inputImage) async {
    if (!isLEORECSuccess) {
      final face = await _detectFace(inputImage);
      if (face == null) {
        log("face is not detected");
        _resetIteration();
        return LivenessModel(progress: 0, isComplete: false);
      }

      log("leftEyeOpenProbability: ${face.rightEyeOpenProbability}");
      log("rightEyeOpenProbability: ${face.leftEyeOpenProbability}");

      bool leftEyeClose = (face.rightEyeOpenProbability ?? 0.0) < thresholdEyeOpen;
      bool rightEyeOpen = (face.leftEyeOpenProbability ?? 0.0) >= thresholdEyeOpen;
      if (leftEyeClose || rightEyeOpen) {
        log("The left eye is closed, and the right eye is open. Repeat.");
        _resetIteration();
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
        _resetIteration();
        return LivenessModel(progress: 1.0, isComplete: true);
      }
    }

    if (isLEORECSuccess) {
      _resetIteration();
      return LivenessModel(progress: 1.0, isComplete: true);
    }

    return LivenessModel(progress: 0.0, isComplete: false);
  }

  // is right eye open & left eye open close
  bool _isREOLECSuccess = false;

  bool get isREOLECSuccess => _isREOLECSuccess;

  /// Detects liveness by checking if the right eye is open and the left eye is closed.
  ///
  /// This function is part of a liveness detection system that verifies if a person
  /// is present and conscious by analyzing their eye movements.
  ///
  /// Parameters:
  /// - [inputImage]: The [InputImage] to process for face detection.
  ///
  /// Returns:
  /// A [LivenessModel] containing the progress and completion status of the check.
  ///
  /// The function works as follows:
  /// 1. If the check hasn't succeeded yet:
  ///    a. Detects a face in the input image.
  ///    b. If no face is detected, resets and returns 0 progress.
  ///    c. Checks if the right eye is open and the left eye is closed.
  ///    d. If the condition is not met, resets and returns 0 progress.
  ///    e. If the condition is met, increments an iteration counter.
  ///    f. If the iteration counter is less than 3, returns partial progress.
  ///    g. If the iteration counter reaches 3, marks the check as successful and returns complete progress.
  /// 2. If the check has already succeeded, returns complete progress.
  ///
  /// Note:
  /// - The function uses a threshold ([thresholdEyeOpen]) to determine if an eye is open or closed.
  /// - It requires 3 consecutive successful detections to consider the check complete.
  /// - Progress is reported as a value between 0.0 and 1.0.
  Future<LivenessModel> detectLivenessRightEyeOpenAndLeftEyeClose(InputImage inputImage) async {
    if (!isREOLECSuccess) {
      final face = await _detectFace(inputImage);
      if (face == null) {
        log("face is not detected");
        _resetIteration();
        return LivenessModel(progress: 0, isComplete: false);
      }

      log("rightEyeOpenProbability: ${face.leftEyeOpenProbability}");
      log("leftEyeOpenProbability: ${face.rightEyeOpenProbability}");

      bool rightEyeClose = (face.leftEyeOpenProbability ?? 0.0) < thresholdEyeOpen;
      bool leftEyeOpen = (face.rightEyeOpenProbability ?? 0.0) >= thresholdEyeOpen;
      if (rightEyeClose || leftEyeOpen) {
        log("The right eye is closed, and the left eye is open. Repeat.");
        _resetIteration();
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
        _resetIteration();
        return LivenessModel(progress: 1.0, isComplete: true);
      }
    }

    if (isREOLECSuccess) {
      _resetIteration();
      return LivenessModel(progress: 1.0, isComplete: true);
    }

    return LivenessModel(progress: 0.0, isComplete: false);
  }

  // is smiling
  bool _isSmiling = false;

  bool get isSmiling => _isSmiling;

  /// Detects liveness by checking if the person is smiling.
  ///
  /// This function is part of a liveness detection system that verifies if a person
  /// is present and conscious by analyzing their facial expressions.
  ///
  /// Parameters:
  /// - [inputImage]: The [InputImage] to process for face detection.
  ///
  /// Returns:
  /// A [Future<LivenessModel>] containing the progress and completion status of the check.
  ///
  /// The function works as follows:
  /// 1. If the smiling check hasn't succeeded yet:
  ///    a. Detects a face in the input image.
  ///    b. If no face is detected, resets and returns 0 progress.
  ///    c. Checks if the detected face is smiling.
  ///    d. If not smiling, resets and returns 0 progress.
  ///    e. If smiling, increments an iteration counter.
  ///    f. If the iteration counter is less than 3, returns partial progress.
  ///    g. If the iteration counter reaches 3, marks the check as successful and returns complete progress.
  /// 2. If the smiling check has already succeeded, returns complete progress.
  ///
  /// Note:
  /// - The function uses a threshold ([thresholdSmiling]) to determine if a face is smiling.
  /// - It requires 3 consecutive successful detections to consider the check complete.
  /// - Progress is reported as a value between 0.0 and 1.0.
  Future<LivenessModel> detectSmiling(InputImage inputImage) async {
    if (!isSmiling) {
      final face = await _detectFace(inputImage);
      if (face == null) {
        log("face is not detected");
        _resetIteration();
        return LivenessModel(progress: 0, isComplete: false);
      }

      log("smilingProbability: ${face.smilingProbability}");

      bool isSmiling = (face.smilingProbability ?? 0.0) >= thresholdSmiling;
      if (!isSmiling) {
        log("face is smiling: $isSmiling");
        _resetIteration();
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
        _resetIteration();
        return LivenessModel(progress: 1.0, isComplete: true);
      }
    }

    if (isSmiling) {
      _resetIteration();
      return LivenessModel(progress: 1.0, isComplete: true);
    }

    return LivenessModel(progress: 0.0, isComplete: false);
  }

  void _resetIteration() {
    _iteration = 0;
  }

  /// Resets all liveness detection checks to their initial state.
  ///
  /// This function is used to reset the state of various liveness checks,
  /// typically called when starting a new liveness detection session or
  /// when needing to restart the detection process.
  ///
  /// The following checks are reset:
  /// - Left Eye Open, Right Eye Closed (LEOREC)
  /// - Right Eye Open, Left Eye Closed (REOLEC)
  /// - Smiling
  void reset() {
    _isLEORECSuccess = false;
    _isREOLECSuccess = false;
    _isSmiling = false;
  }

  Future<Face?> _detectFace(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    return faces.first;
  }

  /// Dispose of the face detector resources.
  ///
  /// This function should be called when the face detector is no longer needed
  /// to free up system resources. It's typically called in the dispose method
  /// of a StatefulWidget or when shutting down the liveness detection system.
  ///
  /// Note:
  /// Ensure this function is called to prevent resource leaks.
  Future<void> disposeFaceDetector() async {
    await _faceDetector.close();
  }
}
