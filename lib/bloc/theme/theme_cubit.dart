import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/data/models/theme_preset.dart';

import 'package:map_to_poster/repository/repository.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final Repository repository;

  ThemeCubit({required this.repository}) : super(const ThemeState());

  Future<void> loadThemes() async {
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      final themes = await repository.getThemes();

      emit(state.copyWith(status: ThemeStatus.success, themes: themes));
    } catch (e) {
      emit(
        state.copyWith(status: ThemeStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
