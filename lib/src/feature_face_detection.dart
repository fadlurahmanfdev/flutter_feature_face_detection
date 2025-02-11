import 'dart:async';
import 'dart:developer';

import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';
import 'package:flutter_feature_face_detection/src/domain/plugin/flutter_face_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FeatureFaceDetection {
  late FaceDetector _faceDetector;
  double _thresholdEyeOpen = 0.3;
  double _thresholdSmiling = 0.3;

  void initializeLiveness({
    double thresholdEyeOpen = 0.3,
    double thresholdSmiling = 0.3,
  }) {
    _thresholdEyeOpen = thresholdEyeOpen;
    _thresholdSmiling = thresholdSmiling;

    _faceDetector = FlutterFaceDetection.getStreamingFaceDetector();
    log("successfully initialized liveness face detection");
  }

  Future<Face?> _detectFace(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    return faces.first;
  }

  Timer? _timer;

  bool _isLEORECSuccess = false;
  bool _isREOLECSuccess = false;
  bool _isSmiling = false;
  int _iteration = 0;

  Future<void> detectLiveness(
    InputImage inputImage, {
    required void Function(double progress) onAskLeftEyeOpenRightEyeClosed,
    required void Function() onSuccessLeftEyeOpenRightEyeClosed,
    required void Function(double progress) onAskRightEyeOpenLeftEyeClosed,
    required void Function() onSuccessRightEyeOpenLeftEyeClosed,
    required void Function(double progress) onAskSmiling,
    required void Function() onSuccessDetectLiveness,
  }) async {
    final face = await _detectFace(inputImage);

    if (face == null) return;

    final allProgress = [
      _isLEORECSuccess,
      _isREOLECSuccess,
      _isSmiling,
    ];
    double progress = (allProgress.where((isSuccess) => !isSuccess).length / allProgress.length);
    bool isComplete = allProgress.where((isSuccess) => isSuccess).length == allProgress.length;

    if (!_isLEORECSuccess) {
      bool leftEyeOpen = (face.rightEyeOpenProbability ?? 0.0) >= _thresholdEyeOpen;
      bool rightEyeClosed = (face.leftEyeOpenProbability ?? 0.0) < _thresholdEyeOpen;

      if (leftEyeOpen && rightEyeClosed) {
        _iteration++;
        _resetTimerFaceLiveness();
      }

      onAskLeftEyeOpenRightEyeClosed(_iteration / 9);

      if (_iteration == 3) {
        _iteration = 0;
        _isLEORECSuccess = true;
        onSuccessLeftEyeOpenRightEyeClosed();
        onAskRightEyeOpenLeftEyeClosed(3 / 9);
      }
    } else if (!_isREOLECSuccess) {
      bool rightEyeOpen = (face.leftEyeOpenProbability ?? 0.0) >= _thresholdEyeOpen;
      bool leftEyeClose = (face.rightEyeOpenProbability ?? 0.0) < _thresholdEyeOpen;

      if (!rightEyeOpen || !leftEyeClose) {
        return;
      }

      if (rightEyeOpen && leftEyeClose) {
        _iteration++;
        _resetTimerFaceLiveness();
      }

      onAskRightEyeOpenLeftEyeClosed((3 + _iteration) / 9);

      if (_iteration == 3) {
        _iteration = 0;
        _isREOLECSuccess = true;
        onSuccessRightEyeOpenLeftEyeClosed();
        onAskSmiling(6 / 9);
      }
    } else if (!_isSmiling) {
      bool isSmiling = (face.smilingProbability ?? 0.0) > _thresholdSmiling;
      if (isSmiling) {
        _iteration++;
        _resetTimerFaceLiveness();
      }

      onAskSmiling((6 + _iteration) / 9);

      if (_iteration == 3) {
        _iteration = 0;
        _isSmiling = true;
        onSuccessDetectLiveness();
      }
    }
  }

  void _resetTimerFaceLiveness() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      _isLEORECSuccess = false;
      _isREOLECSuccess = false;
      _isSmiling = false;
      _iteration = 0;
    });
  }
}
