import 'package:map_to_poster/constants/api_consatant.dart';
import 'package:map_to_poster/data/models/generate_map_request.dart';
import 'package:map_to_poster/data/models/generate_map_response.dart';
import 'package:map_to_poster/data/models/location_result.dart';
import 'package:map_to_poster/data/models/render_map_request.dart';
import 'package:map_to_poster/data/models/render_map_response.dart';
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

  Future<GenerateMapResponse> generateMap(GenerateMapRequest request) async {
    return _client.post(
      "/api/maps/generate",
      body: request.toJson(),
      fromJson: (data) => GenerateMapResponse.fromJson(data),
    );
  }

  Future<GenerateMapResponse> getMapGenerationStatus(String mapId) async {
    return _client.get(
      "/api/maps/maps/$mapId",
      fromJson: (data) => GenerateMapResponse.fromJson(data),
    );
  }

  Future<RenderMapResponse> renderMap(
    String mapId,
    RenderMapRequest request,
  ) async {
    return _client.post(
      "/api/posters/render/$mapId",
      body: request.toJson(),
      fromJson: (data) => RenderMapResponse.fromJson(data),
    );
  }
}
