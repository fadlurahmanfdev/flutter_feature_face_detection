import 'package:example/presentation/widget/camera_control_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:flutter_feature_camera/camera.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';
import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';

class CameraSelfieStreamPage extends StatefulWidget {
  const CameraSelfieStreamPage({super.key});

  @override
  State<CameraSelfieStreamPage> createState() => _CameraSelfieStreamPageState();
}

class _CameraSelfieStreamPageState extends State<CameraSelfieStreamPage>
    with BaseMixinFlutterFaceDetectionCamera, BaseMixinFeatureCameraV2 {
  FaceDetectionRepository repository = FaceDetectionRepositoryImpl(
    faceDetector: FlutterFaceDetection.getStreamingFaceDetector(),
  );

  @override
  void initState() {
    super.initState();
    addListener(
      onFlashModeChanged: (flashMode) {
        setState(() {});
      },
    );
    initializeStreamingCamera(
      cameraLensDirection: CameraLensDirection.front,
      onCameraInitialized: onCameraInitialized,
    );
  }

  void onCameraInitialized(_) {
    setState(() {});

    initializeLivenessFaceDetection();
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera ID Card Page", style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: cameraController?.value.isInitialized == true ? CameraPreview(cameraController!) : Container(),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: CirclePainterV2(
                progress: progress,
                strokeWidth: 4.0,
                overlayColor: Colors.white
              ),
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
                !isLEORECSuccess
                    ? 'Please open your left eye and keep your right eye close to continue'
                    : !isREOLECSuccess
                        ? 'Now please close your left eye and keep your right eye open to continue'
                        : !isSmiling
                            ? 'Last please give us a smile!'
                            : '-',
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

  double progress = 0.0;

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
      if (!isLEORECSuccess) {
        final result = await detectLivenessLeftEyeOpenAndRightEyeClose(inputImage);
        if (result.isComplete) {
          await stopImageStream();
          if (mounted) {
            setState(() {
              progress = 1.0;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  progress = 0.0;
                });
              }
            });
          }
        } else {
          setState(() {
            progress = result.progress;
          });
        }
      } else if (!isREOLECSuccess) {
        final result = await detectLivenessRightEyeOpenAndLeftEyeClose(inputImage);
        if (result.isComplete) {
          await stopImageStream();
          if (mounted) {
            setState(() {
              progress = 1.0;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  progress = 0.0;
                });
              }
            });
          }
        } else {
          setState(() {
            progress = result.progress;
          });
        }
      } else if (!isSmiling) {
        final result = await detectSmiling(inputImage);
        if (result.isComplete) {
          await stopImageStream();
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          setState(() {
            progress = result.progress;
          });
        }
      }
    }
  }
}
