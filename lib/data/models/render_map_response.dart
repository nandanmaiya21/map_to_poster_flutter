class RenderMapResponse {
  final String status;
  final String mapId;
  final String? theme;
  final String? title;
  final String? subtitle;
  final String? coordinates;
  final String? file;
  final String? url;
  final String? message;

  const RenderMapResponse({
    required this.status,
    required this.mapId,
    this.theme,
    this.title,
    this.subtitle,
    this.coordinates,
    this.file,
    this.url,
    this.message,
  });

  bool get isCompleted => status == 'completed' && url != null;

  factory RenderMapResponse.fromJson(Map<String, dynamic> json) {
    return RenderMapResponse(
      status: json['status'] as String,
      mapId: json['map_id'] as String,
      theme: json['theme'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      coordinates: json['coordinates'] as String?,
      file: json['file'] as String?,
      url: json['url'] as String?,
      message: json['message'] as String?,
    );
  }
}
