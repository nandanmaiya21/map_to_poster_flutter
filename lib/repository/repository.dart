import 'package:map_to_poster/constants/api_consatant.dart';
import 'package:map_to_poster/data/models/location_result.dart';
import 'package:map_to_poster/data/models/theme_preset.dart';
import 'package:map_to_poster/network/network.dart';

class Repository {
  final HttpClientConnection _openStreetMapClient = HttpClientConnection(
    baseUrl: ApiConstants.getOpenStreetMapBaseUrl(),
  );

  final HttpClientConnection _client = HttpClientConnection(
    baseUrl: ApiConstants.getBaseUrl(),
  );

  Future<List<LocationResult>?> searchLocations(String? query) async {
    if (query == null || query.trim().isEmpty) {
      return [];
    }

    return await _openStreetMapClient.getList<LocationResult>(
      '/search',
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "MapToPoster/1.0 (Flutter mobile application; contact: nandanmaiya21@gmail.com)",
      },
      queryParameters: {
        'q': query.trim(),
        'format': 'json',
        'limit': 5,
        'addressdetails': 1,
      },

      fromJson: (data) {
        return LocationResult.fromJson(data as Map<String, dynamic>?);
      },
    );
  }

  Future<LocationResult?> getLocationFromCoordinates({
    double? latitude,
    double? longitude,
  }) async {
    if (latitude == null || longitude == null) {
      return null;
    }

    return _openStreetMapClient.get<LocationResult?>(
      '/reverse',
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "MapToPoster/1.0 (Flutter mobile application; contact: nandanmaiya21@gmail.com)",
      },
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'format': 'json',
        'addressdetails': 1,
      },
      fromJson: (data) {
        return LocationResult.fromReverseJson(data as Map<String, dynamic>?);
      },
    );
  }

  Future<List<ThemePreset?>?> getThemes() async {
    return _client.getList<ThemePreset>(
      '/api/posters/themes',
      fromJson: (data) {
        return ThemePreset.fromJson(data as Map<String, dynamic>?);
      },
    );
  }
}
