import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/data/models/location_result.dart';
import 'package:map_to_poster/data/models/theme_preset.dart';

part 'create_project_state.dart';

class CreateProjectCubit extends Cubit<CreateProjectState> {
  CreateProjectCubit({LocationResult? initialLocation})
    : super(CreateProjectState(selectedLocation: initialLocation));

  void selectTheme(ThemePreset theme) {
    emit(state.copyWith(selectedTheme: theme));
  }
}
