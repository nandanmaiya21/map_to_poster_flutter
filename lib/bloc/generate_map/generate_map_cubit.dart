import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/data/models/generate_map_request.dart';
import 'package:map_to_poster/data/models/generate_map_response.dart';

import 'package:map_to_poster/repository/repository.dart';

part 'generate_map_state.dart';

class GenerateMapCubit extends Cubit<GenerateMapState> {
  final Repository repository;

  GenerateMapCubit({required this.repository})
    : super(const GenerateMapState());

  Future<void> generate(GenerateMapRequest request) async {
    emit(const GenerateMapState(status: GenerateMapStatus.loading));

    try {
      final response = await repository.generateMap(request);

      emit(
        GenerateMapState(status: GenerateMapStatus.success, response: response),
      );
    } catch (e) {
      emit(
        GenerateMapState(
          status: GenerateMapStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
