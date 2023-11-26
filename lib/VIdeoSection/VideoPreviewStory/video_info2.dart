class VideoInfo2 {
  final String videoUrl;
  final double latitude;
  final double longitude;

  VideoInfo2({
    required this.videoUrl,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
