import 'package:bloc/bloc.dart';
part 'app_shell_state.dart';

class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit() : super(AppShellState());

  void updateIndex(int newIndex) {
    if (newIndex == state.currentIndex) return;

    emit(
      state.copyWith(previousIndex: state.currentIndex, currentIndex: newIndex),
    );
  }
}
