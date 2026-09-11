part of 'create_project_cubit.dart';

class CreateProjectState {
  final ThemePreset? selectedTheme;
  final PosterLayout? selectedLayout;

  const CreateProjectState({this.selectedTheme, this.selectedLayout});

  CreateProjectState copyWith({
    ThemePreset? selectedTheme,
    PosterLayout? selectedLayout,
  }) {
    return CreateProjectState(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedLayout: selectedLayout ?? this.selectedLayout,
    );
  }
}
