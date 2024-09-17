import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// This class provides methods to detect faces in images using various input sources
/// such as [InputImage], [File], and file paths. It also includes utility methods to
/// check for the presence of a single face in an image.
abstract class FaceDetectionRepository {
  /// Detects faces in the given [InputImage].
  ///
  /// Returns a list of detected [Face] objects.
  Future<List<Face>> detectFace(InputImage inputImage);

  /// Detects faces in the image [File].
  ///
  /// Returns a list of detected [Face] objects.
  Future<List<Face>> detectFaceFromFile(File file);

  /// Detects faces in the image at the specified file [path].
  ///
  /// Returns a list of detected [Face] objects.
  Future<List<Face>> detectFaceFromFilePath(String path);

  /// Checks if exactly one face is detected in the given [InputImage].
  ///
  /// Returns `true` if exactly one face is detected, `false` otherwise.
  Future<bool> isSingleFaceDetected(InputImage inputImage);

  /// Checks if exactly one face is detected in the image [File].
  ///
  /// Returns `true` if exactly one face is detected, `false` otherwise.
  Future<bool> isSingleFaceDetectedFromFile(File file);

  /// Checks if exactly one face is detected in the image at the specified file [path].
  ///
  /// Returns `true` if exactly one face is detected, `false` otherwise.
  Future<bool> isSingleFaceDetectedFromFilePath(String path);

  /// Closes the face detector and releases associated resources.
  Future<void> close();
}
