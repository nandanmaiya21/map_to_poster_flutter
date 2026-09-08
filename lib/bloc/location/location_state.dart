part of 'location_cubit.dart';

enum LocationStatus { initial, loading, success, failure }

class LocationState {
  final LocationStatus status;
  final List<LocationResult>? searchResults;
  final LocationResult? selectedLocation;
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.searchResults,
    this.selectedLocation,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    List<LocationResult>? searchResults,
    Object? selectedLocation = _undefined,
    Object? errorMessage = _undefined,
  }) {
    return LocationState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      selectedLocation: selectedLocation == _undefined
          ? this.selectedLocation
          : selectedLocation as LocationResult?,
      errorMessage: errorMessage == _undefined
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _undefined = Object();
}
