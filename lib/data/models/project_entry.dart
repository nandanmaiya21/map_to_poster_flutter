import 'package:map_to_poster/screens/layout_selection.dart';

class ProjectEntry {
  final String mapId;
  final String locationName;
  final num latitude;
  final num longitude;
  final String country;
  final PosterLayout posterLayout;
  final String themeSlug;

  const ProjectEntry({
    required this.mapId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.posterLayout,
    required this.themeSlug,
  });

  // Derived text for the render API — the city ("BRANTFORD"-style) portion
  // of the location name, falling back to the full name if it can't split.
  String get posterTitle {
    final city = locationName.split(',').first.trim();
    return (city.isEmpty ? locationName : city).toUpperCase();
  }

  String get posterSubtitle => country.toUpperCase();

  // e.g. "43.1394° N • 80.2644° W"
  String get posterCoordinates {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';

    return '${latitude.abs().toStringAsFixed(4)}° $latDir • '
        '${longitude.abs().toStringAsFixed(4)}° $lngDir';
  }

  factory ProjectEntry.fromJson(Map<String, dynamic> json) {
    return ProjectEntry(
      mapId: json['map_id'] as String,
      locationName: json['location_name'] as String,
      latitude: json['latitude'] as num,
      longitude: json['longitude'] as num,
      country: json['country'] as String,
      posterLayout: PosterLayout.values.byName(json['poster_layout'] as String),
      themeSlug: json['theme_slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'map_id': mapId,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'poster_layout': posterLayout.name,
      'theme_slug': themeSlug,
    };
  }

  ProjectEntry copyWith({
    String? mapId,
    String? locationName,
    num? latitude,
    num? longitude,
    String? country,
    PosterLayout? posterLayout,
    String? themeSlug,
  }) {
    return ProjectEntry(
      mapId: mapId ?? this.mapId,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      posterLayout: posterLayout ?? this.posterLayout,
      themeSlug: themeSlug ?? this.themeSlug,
    );
  }
}
