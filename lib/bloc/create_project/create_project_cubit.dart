import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/data/models/project_entry.dart';
import 'package:map_to_poster/data/models/theme_preset.dart';
import 'package:map_to_poster/screens/layout_selection.dart';

part 'create_project_state.dart';

// Drives the theme + layout styling flow for an already-generated project
// (entered from the Projects section), keyed to that stored project.
class CreateProjectCubit extends Cubit<CreateProjectState> {
  final ProjectEntry project;

  CreateProjectCubit({required this.project}) : super(const CreateProjectState());

  void selectTheme(ThemePreset theme) {
    emit(state.copyWith(selectedTheme: theme));
  }

  void selectLayout(PosterLayout layout) {
    emit(state.copyWith(selectedLayout: layout));
  }
}
