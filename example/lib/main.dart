import 'package:example/data/dto/model/feature_model.dart';
import 'package:example/presentation/liveness_face_detection_page.dart';
import 'package:example/presentation/preview_face_detection_page.dart';
import 'package:example/presentation/widget/feature_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Face Detection Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FeatureModel> features = [
    FeatureModel(
      title: 'Face Detection',
      desc: 'Face Detection',
      key: 'FACE_DETECTION',
    ),
    FeatureModel(
      title: 'Liveness Face Detection',
      desc: 'Liveness Face Detection',
      key: 'LIVENESS_FACE_DETECTION',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection')),
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
                case "LIVENESS_FACE_DETECTION":
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LivenessFaceDetectionPage()));
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
