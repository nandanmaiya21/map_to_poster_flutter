class LocationResult {
  final String? name;
  final double? latitude;
  final double? longitude;

  const LocationResult({this.name, this.latitude, this.longitude});

  factory LocationResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LocationResult();
    }

    return LocationResult(
      name: json['display_name']?.toString(),
      latitude: double.tryParse(json['lat']?.toString() ?? ''),
      longitude: double.tryParse(json['lon']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'latitude': latitude, 'longitude': longitude};
  }

  factory LocationResult.fromReverseJson(Map<String, dynamic>? json) {
    final address = json?['address'] as Map<String, dynamic>?;

    final city =
        address?['city'] ??
        address?['town'] ??
        address?['village'] ??
        address?['municipality'] ??
        address?['county'];

    final state = address?['state'];
    final country = address?['country'];

    final locationName = [city, state, country].whereType<String>().join(', ');

    return LocationResult(
      name: locationName.isEmpty
          ? json != null
                ? json['display_name'] as String?
                : "Unknown Location"
          : locationName,
      latitude: double.tryParse(json?['lat']?.toString() ?? ''),
      longitude: double.tryParse(json?['lon']?.toString() ?? ''),
    );
  }
}
