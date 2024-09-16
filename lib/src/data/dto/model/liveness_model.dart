class LivenessModel {
  final double progress;
  final bool isComplete;

  LivenessModel({
    required this.progress,
    required this.isComplete,
  });

  Map<String, dynamic> toJson(){
    return {
      'progress': progress,
      'isComplete': isComplete,
    };
  }
}
