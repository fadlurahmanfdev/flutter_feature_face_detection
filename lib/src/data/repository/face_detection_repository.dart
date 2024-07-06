import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class FaceDetectionRepository {
  Future<List<Face>> detectFace(InputImage inputImage);

  Future<List<Face>> detectFaceFromFile(File file);

  Future<List<Face>> detectFaceFromFilePath(String path);

  Future<bool> isSingleFaceDetected(InputImage inputImage);

  Future<bool> isSingleFaceDetectedFromFile(File file);

  Future<bool> isSingleFaceDetectedFromFilePath(String path);
}
