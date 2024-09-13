import 'package:example/data/dto/model/feature_model.dart';
import 'package:example/presentation/camera_selfie_page.dart';
import 'package:example/presentation/camera_selfie_stream_page.dart';
import 'package:example/presentation/preview_face_detection_page.dart';
import 'package:example/presentation/widget/feature_widget.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<FeatureModel> features = [
    FeatureModel(
      title: 'Face Detection',
      desc: 'Face Detection',
      key: 'FACE_DETECTION',
    ),
    FeatureModel(
      title: 'Stream Face Detection',
      desc: 'Stream Face Detection',
      key: 'STREAM_FACE_DETECTION',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: features.length,
        itemBuilder: (_, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () async {
              switch (feature.key) {
                case "FACE_DETECTION":
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PreviewFaceDetectionPage()));
                  break;
                case "STREAM_FACE_DETECTION":
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraSelfieStreamPage()));
                  break;
              }
            },
            child: ItemFeatureWidget(feature: feature),
          );
        },
      ),
    );
  }
}
