import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/data/models/export_format.dart';
import 'package:map_to_poster/data/models/render_map_request.dart';
import 'package:map_to_poster/data/models/render_map_response.dart';
import 'package:map_to_poster/repository/repository.dart';

part 'render_map_state.dart';

class RenderMapCubit extends Cubit<RenderMapState> {
  final Repository repository;
  final String mapId;
  final String theme;
  final String title;
  final String subtitle;
  final String coordinates;
  final String layout;

  RenderMapCubit({
    required this.repository,
    required this.mapId,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.coordinates,
    required this.layout,
  }) : super(const RenderMapState());

  Future<void> render(ExportFormat format) async {
    emit(state.withJob(format, const RenderJob(status: RenderJobStatus.loading)));

    try {
      final response = await repository.renderMap(
        mapId,
        RenderMapRequest(
          theme: theme,
          title: title,
          subtitle: subtitle,
          coordinates: coordinates,
          layout: layout,
          exportFormat: format.value,
        ),
      );

      if (!response.isCompleted) {
        emit(
          state.withJob(
            format,
            RenderJob(
              status: RenderJobStatus.failure,
              error: response.message ?? 'Poster is not ready yet.',
            ),
          ),
        );
        return;
      }

      emit(
        state.withJob(
          format,
          RenderJob(status: RenderJobStatus.success, response: response),
        ),
      );
    } catch (e) {
      emit(
        state.withJob(
          format,
          RenderJob(status: RenderJobStatus.failure, error: e.toString()),
        ),
      );
    }
  }
}
