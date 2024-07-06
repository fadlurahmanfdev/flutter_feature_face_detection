import 'dart:convert';

import 'package:example/presentation/preview_image_page.dart';
import 'package:example/presentation/widget/camera_control_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';
import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';

class CameraSelfiePage extends StatefulWidget {
  const CameraSelfiePage({super.key});

  @override
  State<CameraSelfiePage> createState() => _CameraSelfiePageState();
}

class _CameraSelfiePageState extends State<CameraSelfiePage> with BaseFeatureCamera {
  FaceDetectionRepository repository = FaceDetectionRepositoryImpl(
    faceDetector: FaceDetector(
      options: FaceDetectorOptions(),
    ),
  );

  @override
  void initState() {
    super.initState();
    addListener(
      onCameraInitialized: () {
        setState(() {});
      },
      onFlashModeChanged: (flashMode) {
        setState(() {});
      },
    );
    initializeCamera(cameraLensDirection: CameraLensDirection.front);
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
            child: ClipPath(
              clipper: CircleClipper(),
              child: CustomPaint(
                painter: CirclePainter(),
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CameraControlLayoutWidget(
              flashIcon: Icon(Icons.flash_off),
              onFlashTap: onFlashTap,
              captureIcon: Icon(Icons.camera_alt),
              onCaptureTap: onCaptureTap,
              switchCameraIcon: Icon(Icons.autorenew),
              onSwitchCameraTap: onSwitchCameraTap,
            ),
          ),
        ],
      ),
    );
  }

  void onCaptureTap() {
    takePicture().then((file) async {
      if (file != null) {
        final inputImage = InputImage.fromFilePath(file.path);
        final faces = await repository.detectFace(inputImage);
        for (int i = 0; i < faces.length; i++) {
          print("FACE $i, LEFT EYE OPEN PROBABILITY: ${faces[i].leftEyeOpenProbability}");
          print("FACE $i, RIGHT EYE OPEN PROBABILITY: ${faces[i].rightEyeOpenProbability}");
          print("FACE $i, SMILING PROBABILITY: ${faces[i].smilingProbability}");
        }
        final bytes = await file.readAsBytes();
        final base64Image = base64.encode(bytes);
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => PreviewImagePage(base64Image: base64Image)));
        }
      }
    });
  }

  void onFlashTap() {}

  void onSwitchCameraTap() {}
}
