import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feature_camera/flutter_feature_camera.dart';

class PreviewImagePage extends StatefulWidget {
  final String base64Image;

  const PreviewImagePage({
    super.key,
    required this.base64Image,
  });

  @override
  State<PreviewImagePage> createState() => _PreviewImagePageState();
}

class _PreviewImagePageState extends State<PreviewImagePage> {
  @override
  void initState() {
    super.initState();
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
      body: Stack(
        children: [
          Image.memory(base64.decode(widget.base64Image), fit: BoxFit.cover),
          IgnorePointer(
            child: ClipPath(
              clipper: CircleClipper(),
              child: CustomPaint(
                painter: CirclePainter(),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
