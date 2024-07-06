import 'dart:io';

import 'package:flutter_feature_face_detection/src/data/repository/face_detection_repository.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionRepositoryImpl extends FaceDetectionRepository {
  FaceDetector faceDetector;

  FaceDetectionRepositoryImpl({required this.faceDetector});

  @override
  Future<List<Face>> detectFace(InputImage inputImage) {
    return faceDetector.processImage(inputImage);
  }

  @override
  Future<List<Face>> detectFaceFromFile(File file) {
    return faceDetector.processImage(InputImage.fromFile(file));
  }

  @override
  Future<List<Face>> detectFaceFromFilePath(String path) {
    return faceDetector.processImage(InputImage.fromFilePath(path));
  }

  @override
  Future<bool> isSingleFaceDetected(InputImage inputImage) async {
    final faces = await detectFace(inputImage);
    return faces.isNotEmpty && faces.length == 1;
  }

  @override
  Future<bool> isSingleFaceDetectedFromFile(File file) async {
    final faces = await detectFaceFromFile(file);
    return faces.isNotEmpty && faces.length == 1;
  }

  @override
  Future<bool> isSingleFaceDetectedFromFilePath(String path) async {
    final faces = await detectFaceFromFilePath(path);
    return faces.isNotEmpty && faces.length == 1;
  }
}
