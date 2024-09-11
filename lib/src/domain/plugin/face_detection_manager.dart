import 'package:flutter_feature_face_detection/flutter_feature_face_detection.dart';

class FlutterFaceDetection {
  static FaceDetector getStreamingFaceDetector() {
    return FaceDetector(
      options: FaceDetectorOptions(
        enableTracking: true,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        minFaceSize: .5,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  static FaceDetector getCaptureFaceDetector() {
    return FaceDetector(
      options: FaceDetectorOptions(
        enableTracking: true,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        minFaceSize: .5,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }
}
