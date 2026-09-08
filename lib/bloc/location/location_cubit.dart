import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/data/models/location_result.dart';

import 'package:map_to_poster/repository/repository.dart';
import 'package:map_to_poster/services/location_service.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final Repository repository;
  final LocationService locationService;
  Timer? _debounce;

  LocationCubit({required this.repository, required this.locationService})
    : super(const LocationState());

  void searchLocations(String? query) {
    // Cancel previous pending search
    _debounce?.cancel();

    if (query == null || query.trim().isEmpty) {
      emit(state.copyWith(status: LocationStatus.initial, searchResults: []));
      return;
    }

    // Wait before making API request
    _debounce = Timer(const Duration(seconds: 1), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String? query) async {
    if (query == null || query.trim().isEmpty) return;

    emit(state.copyWith(status: LocationStatus.loading));

    try {
      final results = await repository.searchLocations(query);

      emit(
        state.copyWith(status: LocationStatus.success, searchResults: results),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectLocation(LocationResult? location) {
    _debounce?.cancel();

    emit(
      state.copyWith(
        selectedLocation: location,
        searchResults: [],
        status: LocationStatus.success,
      ),
    );
  }

  void clearSearch() {
    _debounce?.cancel();

    emit(state.copyWith(status: LocationStatus.initial, searchResults: []));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> getCurrentLocation() async {
    emit(state.copyWith(status: LocationStatus.loading, errorMessage: null));

    try {
      // 1. GPS coordinates
      final position = await locationService.getCurrentPosition();

      // 2. Convert coordinates → city
      final location = await repository.getLocationFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (location == null) {
        throw Exception('Unable to determine your location');
      }

      // 3. Select location
      emit(
        state.copyWith(
          status: LocationStatus.success,
          selectedLocation: location,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearSelectedLocation() {
    emit(
      state.copyWith(
        selectedLocation: null,
        status: LocationStatus.initial,
        errorMessage: null,
      ),
    );
  }
}
