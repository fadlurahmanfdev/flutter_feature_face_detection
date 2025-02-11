import 'dart:developer';

import 'package:example/presentation/widget/camera_control_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:flutter_feature_camera/camera.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';
import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';

class LivenessFaceDetectionPage extends StatefulWidget {
  const LivenessFaceDetectionPage({super.key});

  @override
  State<LivenessFaceDetectionPage> createState() => _LivenessFaceDetectionPageState();
}

class _LivenessFaceDetectionPageState extends State<LivenessFaceDetectionPage>
    with BaseMixinFlutterFaceDetectionCamera, BaseMixinFeatureCameraV2 {
  FeatureFaceDetection featureFaceDetection = FeatureFaceDetection();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      featureFaceDetection.initializeLiveness();
      addListener(
        onFlashModeChanged: (flashMode) {
          setState(() {});
        },
      );
      initializeStreamingCamera(
        cameraLensDirection: CameraLensDirection.front,
        onCameraInitialized: onCameraInitialized,
      );
    });
  }

  void onCameraInitialized(_) {
    setState(() {});

    initializeLivenessFaceDetection();
  }

  bool _isLEORECSuccess = false;
  bool _isREOLECSuccess = false;
  bool _isSmiling = false;
  double progress = 0.0;

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liveness Detection", style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: cameraController?.value.isInitialized == true ? CameraPreview(cameraController!) : Container(),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: CirclePainterV2(progress: progress, strokeWidth: 4.0, overlayColor: Colors.white),
              child: Container(),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 200.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: Text(
                !_isLEORECSuccess
                    ? 'Please open your left eye and keep your right eye close to continue'
                    : !_isREOLECSuccess
                        ? 'Now please close your left eye and keep your right eye open to continue'
                        : !_isSmiling
                            ? 'Last please give us a smile!'
                            : 'Success Liveness Detection',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CameraControlLayoutWidget(
              flashIcon: const Icon(Icons.flash_off),
              onFlashTap: onFlashTap,
              captureIcon: isStream ? const Icon(Icons.stop) : const Icon(Icons.fiber_manual_record),
              onCaptureTap: onStreamTap,
              switchCameraIcon: const Icon(Icons.autorenew),
              onSwitchCameraTap: onSwitchCameraTap,
            ),
          ),
        ],
      ),
    );
  }

  bool isStream = false;

  void onStreamTap() {
    if (!isStream) {
      setState(() {
        isStream = true;
      });
      startImageStream(
        onImageStream: onImageStream,
      );
    } else {
      stopImageStream();
    }
  }

  @override
  Future<void> stopImageStream() {
    setState(() {
      isStream = false;
    });
    return super.stopImageStream();
  }

  void onFlashTap() {}

  void onSwitchCameraTap() {}

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
      featureFaceDetection.detectLiveness(
        inputImage,
        onAskLeftEyeOpenRightEyeClosed: (progress) {
          log("on ask left eye open right eye closed: $progress");
          setState(() {
            _isLEORECSuccess = false;
            this.progress = progress;
          });
        },
        onSuccessLeftEyeOpenRightEyeClosed: () {
          log("on success left eye open right eye closed");
          setState(() {
            _isLEORECSuccess = true;
          });
        },
        onAskRightEyeOpenLeftEyeClosed: (progress) {
          log("on ask right eye open left eye closed: $progress");
          setState(() {
            _isREOLECSuccess = false;
            this.progress = progress;
          });
        },
        onSuccessRightEyeOpenLeftEyeClosed: () {
          log("on success right eye open left eye closed");
          setState(() {
            _isREOLECSuccess = true;
          });
        },
        onAskSmiling: (progress) {
          log("on ask smiling: $progress");
          setState(() {
            _isSmiling = false;
            this.progress = progress;
          });
        },
        onSuccessDetectLiveness: () {
          setState(() {
            _isSmiling = true;
            _isREOLECSuccess = true;
            _isLEORECSuccess = true;
          });
          stopImageStream();
        },
      );
    }
  }
}
