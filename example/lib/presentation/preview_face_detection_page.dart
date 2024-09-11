import 'dart:convert';

import 'package:example/data/dto/model/face_detection_model.dart';
import 'package:example/presentation/camera_selfie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';

class PreviewFaceDetectionPage extends StatefulWidget {
  const PreviewFaceDetectionPage({super.key});

  @override
  State<PreviewFaceDetectionPage> createState() => _PreviewFaceDetectionPageState();
}

class _PreviewFaceDetectionPageState extends State<PreviewFaceDetectionPage> {
  String? base64Image;
  double? leftEyeOpenProbability;
  double? rightEyeOpenProbability;
  double? smilingProbability;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraSelfiePage())).then((value) {
        if (value is FaceDetectionModel) {
          if (mounted) {
            setState(() {
              base64Image = value.base64Image;
              leftEyeOpenProbability = value.leftEyeOpenProbability;
              rightEyeOpenProbability = value.rightEyeOpenProbability;
              smilingProbability = value.smilingProbability;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Preview Image", style: TextStyle(color: Colors.black)),
      ),
      body: base64Image != null
          ? Stack(
              children: [
                Image.memory(base64.decode(base64Image ?? ''), fit: BoxFit.cover),
                IgnorePointer(
                  child: CustomPaint(
                    painter: CirclePainterV2(),
                    child: Container(),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 0, right: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Text(
                      'Left Eye Open Probability: $leftEyeOpenProbability\n\n'
                      'Right Eye Open Probability: $rightEyeOpenProbability\n\n'
                      'Smiling Probability: $smilingProbability',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
