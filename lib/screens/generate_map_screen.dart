import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:map_to_poster/bloc/generate_map/generate_map_cubit.dart';
import 'package:map_to_poster/core/responsive/responsive.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/toast/app_toast.dart';
import 'package:map_to_poster/core/widgets/action_button.dart';
import 'package:map_to_poster/core/widgets/app_loader.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';
import 'package:map_to_poster/data/models/generate_map_request.dart';
import 'package:map_to_poster/data/models/generate_map_response.dart';
import 'package:map_to_poster/data/models/location_result.dart';
import 'package:map_to_poster/data/models/project_entry.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/screens/layout_selection.dart';
import 'package:map_to_poster/services/project_storage_service.dart';
import 'package:map_to_poster/shared/layout/layout.dart';

class GenerateMapScreen extends StatefulWidget {
  final LocationResult location;

  const GenerateMapScreen({super.key, required this.location});

  @override
  State<GenerateMapScreen> createState() => _GenerateMapScreenState();
}

class _GenerateMapScreenState extends State<GenerateMapScreen> {
  double _radius = 1500;
  final ProjectStorageService _storage = ProjectStorageService();

  String _extractCountry(String? locationName) {
    if (locationName == null || locationName.trim().isEmpty) {
      return 'UNKNOWN';
    }

    final country = locationName.split(',').last.trim();

    return country.isEmpty ? 'UNKNOWN' : country;
  }

  Future<void> _handleSuccess(GenerateMapResponse response) async {
    final location = widget.location;

    // Theme and layout aren't chosen yet at this point — they're picked
    // later from the Projects section, once the poster exists.
    await _storage.addProject(
      ProjectEntry(
        mapId: response.mapId,
        locationName: location.name ?? 'UNKNOWN LOCATION',
        latitude: location.latitude ?? 0,
        longitude: location.longitude ?? 0,
        country: _extractCountry(location.name),
        posterLayout: PosterLayout.full,
        themeSlug: '',
      ),
    );

    if (!mounted) return;

    AppToast.success(
      context,
      'Your poster is being generated. Check the Projects section shortly.',
    );

    appShellCubit.updateIndex(2);

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      RouteNames.home,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: BlocConsumer<GenerateMapCubit, GenerateMapState>(
        listener: (context, state) {
          if (state.status == GenerateMapStatus.success &&
              state.response != null) {
            _handleSuccess(state.response!);
          } else if (state.status == GenerateMapStatus.failure) {
            AppToast.error(
              context,
              state.errorMessage ?? 'Failed to generate poster.',
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == GenerateMapStatus.loading;

          return WebMaxWidth(
            maxWidth: 720,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GenerateHeader(),

                const SizedBox(height: 36),

                _SummaryTile(
                  icon: Icons.location_on_outlined,
                  label: 'LOCATION',
                  value: widget.location.name ?? '--',
                ),

                const SizedBox(height: 32),

                Text(
                  'MAP RADIUS: ${_radius.round()} M',
                  style: AppTextStyles.technical.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.neonLime,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: AppColors.textPrimary,
                    overlayColor: AppColors.neonLime.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 500,
                    max: 5000,
                    divisions: 45,
                    onChanged: isLoading
                        ? null
                        : (value) => setState(() => _radius = value),
                  ),
                ),

                const SizedBox(height: 20),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: AppLoader(label: 'GENERATING POSTER...'),
                    ),
                  )
                else
                  ActionButton(
                    text: 'GENERATE POSTER',
                    type: ActionButtonType.filled,
                    onPressed: () {
                      final location = widget.location;

                      if (location.latitude == null ||
                          location.longitude == null) {
                        AppToast.error(
                          context,
                          'Please select a location before generating.',
                        );
                        return;
                      }

                      context.read<GenerateMapCubit>().generate(
                        GenerateMapRequest(
                          latitude: location.latitude!,
                          longitude: location.longitude!,
                          radius: _radius.round(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GenerateHeader extends StatelessWidget {
  const _GenerateHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => navigatorKey.currentState?.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
          ],
        ),
        Text(
          '02 / GENERATE POSTER',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        Text(
          'GENERATE\nPOSTER',
          style: AppTextStyles.displayXL.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        Container(width: 72, height: 5, color: AppColors.neonLime),

        const SizedBox(height: 16),

        Text(
          'SET A SEARCH RADIUS AND GENERATE YOUR MAP POSTER.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
