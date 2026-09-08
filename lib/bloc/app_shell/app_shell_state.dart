part of 'app_shell_cubit.dart';

final class AppShellState {
  final int currentIndex;
  final int previousIndex;

  const AppShellState({this.currentIndex = 0, this.previousIndex = 0});

  AppShellState copyWith({int? currentIndex, int? previousIndex}) {
    return AppShellState(
      currentIndex: currentIndex ?? this.currentIndex,
      previousIndex: previousIndex ?? this.previousIndex,
    );
  }
}
