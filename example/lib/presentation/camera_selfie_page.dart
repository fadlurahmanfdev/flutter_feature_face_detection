import 'dart:convert';

import 'package:example/data/dto/model/face_detection_model.dart';
import 'package:example/presentation/preview_face_detection_page.dart';
import 'package:example/presentation/widget/camera_control_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';
import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';

class CameraSelfiePage extends StatefulWidget {
  const CameraSelfiePage({super.key});

  @override
  State<CameraSelfiePage> createState() => _CameraSelfiePageState();
}

class _CameraSelfiePageState extends State<CameraSelfiePage> with BaseMixinFeatureCameraV2 {
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
    initializeCamera(
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
        final bytes = await file.readAsBytes();
        final base64Image = base64.encode(bytes);
        final FaceDetectionModel faceDetectionModel = FaceDetectionModel(
          base64Image: base64Image,
          leftEyeOpenProbability: -1.0,
          smilingProbability: -1.0,
          rightEyeOpenProbability: -1.0,
        );
        for (int i = 0; i < faces.length; i++) {
          final face = faces[i];
          print("FACE $i, LEFT EYE OPEN PROBABILITY: ${faces[i].leftEyeOpenProbability}");
          print("FACE $i, RIGHT EYE OPEN PROBABILITY: ${faces[i].rightEyeOpenProbability}");
          print("FACE $i, SMILING PROBABILITY: ${faces[i].smilingProbability}");
          faceDetectionModel.leftEyeOpenProbability = face.leftEyeOpenProbability ?? -1.0;
          faceDetectionModel.rightEyeOpenProbability = face.rightEyeOpenProbability ?? -1.0;
          faceDetectionModel.smilingProbability = face.smilingProbability ?? -1.0;
        }
        if (mounted) {
          Navigator.of(context).pop(faceDetectionModel);
        }
      }
    });
  }

  void onFlashTap() {}

  void onSwitchCameraTap() {}
}
