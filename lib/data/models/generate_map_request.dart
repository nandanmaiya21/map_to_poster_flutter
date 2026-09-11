class GenerateMapRequest {
  final num latitude;
  final num longitude;
  final int radius;

  GenerateMapRequest({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  Map<String, dynamic> toJson() {
    return {"latitude": latitude, "longitude": longitude, "radius": radius};
  }
}
