part of 'create_project_cubit.dart';

class CreateProjectState {
  final LocationResult? selectedLocation;
  final ThemePreset? selectedTheme;

  const CreateProjectState({this.selectedLocation, this.selectedTheme});

  CreateProjectState copyWith({
    LocationResult? selectedLocation,
    ThemePreset? selectedTheme,
  }) {
    return CreateProjectState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }
}
