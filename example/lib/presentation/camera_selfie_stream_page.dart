import 'package:example/presentation/widget/camera_control_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_camera/camera.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';
import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';
import 'package:flutter_feature_face_detection/google_mlkit_face_detection.dart';

class CameraSelfieStreamPage extends StatefulWidget {
  const CameraSelfieStreamPage({super.key});

  @override
  State<CameraSelfieStreamPage> createState() => _CameraSelfieStreamPageState();
}

class _CameraSelfieStreamPageState extends State<CameraSelfieStreamPage> with BaseMixinFeatureCameraV2 {
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
              painter: CirclePainterV2(),
              child: Container(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CameraControlLayoutWidget(
              flashIcon: Icon(Icons.flash_off),
              onFlashTap: onFlashTap,
              captureIcon: isStream ? Icon(Icons.stop) : Icon(Icons.fiber_manual_record),
              onCaptureTap: onStreamTap,
              switchCameraIcon: Icon(Icons.autorenew),
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
        onImageStream: (cameraImage, sensorOrientation, deviceOrientation, cameraLensDirection) async {
          final inputImage = FlutterFaceDetection.inputImageFromCameraImage(
            cameraImage,
            sensorOrientation: sensorOrientation,
            deviceOrientation: deviceOrientation,
            cameraLensDirection: cameraLensDirection,
          );
          if (inputImage != null) {
            final faces = await repository.detectFace(inputImage);
            for (int i = 0; i < faces.length; i++) {
              final face = faces[i];
              print("FACE $i, LEFT EYE OPEN PROBABILITY: ${face.leftEyeOpenProbability}");
              print("FACE $i, RIGHT EYE OPEN PROBABILITY: ${face.rightEyeOpenProbability}");
              print("FACE $i, SMILING PROBABILITY: ${face.smilingProbability}");
            }
          }
        },
      );
    } else {
      setState(() {
        isStream = false;
      });
      stopImageStream();
    }
  }

  void onFlashTap() {}

  void onSwitchCameraTap() {}
}
