part of 'theme_cubit.dart';

enum ThemeStatus { initial, loading, success, failure }

class ThemeState {
  final ThemeStatus status;
  final List<ThemePreset?>? themes;
  final String? errorMessage;

  const ThemeState({
    this.status = ThemeStatus.initial,
    this.themes,
    this.errorMessage,
  });

  ThemeState copyWith({
    ThemeStatus? status,
    List<ThemePreset?>? themes,
    String? errorMessage,
  }) {
    return ThemeState(
      status: status ?? this.status,
      themes: themes ?? this.themes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
