class FaceDetectionModel {
  final String base64Image;

  double leftEyeOpenProbability;
  double rightEyeOpenProbability;
  double smilingProbability;

  FaceDetectionModel({
    required this.base64Image,
    required this.leftEyeOpenProbability,
    required this.smilingProbability,
    required this.rightEyeOpenProbability,
  });
}
