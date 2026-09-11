class GenerateMapResponse {
  final String mapId;
  final String status;

  const GenerateMapResponse({required this.mapId, required this.status});

  factory GenerateMapResponse.fromJson(Map<String, dynamic> json) {
    return GenerateMapResponse(
      mapId: json['map_id'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'map_id': mapId, 'status': status};
  }
}
