import 'package:flutter/material.dart';
import 'package:map_to_poster/bloc/location/location_cubit.dart';

import 'package:map_to_poster/core/responsive/responsive.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/toast/app_toast.dart';
import 'package:map_to_poster/core/widgets/action_button.dart';
import 'package:map_to_poster/core/widgets/app_loader.dart';
import 'package:map_to_poster/data/models/location_result.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/shared/layout/layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchSection = <Widget>[
      Text(
        'SELECT A LOCATION',
        style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
      ),

      const SizedBox(height: 12),
      _LocationSearchField(
        controller: _locationController,
        onChanged: (value) {
          context.read<LocationCubit>().searchLocations(value);
        },
      ),

      BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state.status == LocationStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: AppLoader()),
            );
          }

          final locations = state.searchResults;

          if (locations == null || locations.isEmpty) {
            return const SizedBox.shrink();
          }

          return _LocationSearchResults(
            locations: locations,
            onSelected: (location) {
              _locationController.text = location.name ?? '';

              context.read<LocationCubit>().selectLocation(location);

              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
      const SizedBox(height: 20),

      const _OrDivider(),

      const SizedBox(height: 20),

      BlocConsumer<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state.status == LocationStatus.success) {
            _locationController.text = state.selectedLocation?.name ?? '';
          }
        },
        builder: (context, state) {
          final isLoading = state.status == LocationStatus.loading;

          return ActionButton(
            onPressed: isLoading
                ? () {}
                : () {
                    context.read<LocationCubit>().getCurrentLocation();
                  },
            text: isLoading ? 'LOCATING...' : 'USE CURRENT LOCATION',
            type: ActionButtonType.outlined,
            fontSize: 16,
            prefixIcon: Icon(
              Icons.my_location,
              color: isLoading ? AppColors.textMuted : AppColors.textPrimary,
              size: 20,
            ),
          );
        },
      ),
    ];

    final mapPreview = BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        return _MapPreviewPlaceholder(location: state.selectedLocation);
      },
    );

    final continueButton = ActionButton(
      text: "CONTINUE",
      type: ActionButtonType.filled,
      onPressed: () {
        final location = context.read<LocationCubit>().state.selectedLocation;

        if (location == null) {
          AppToast.error(
            context,
            'Please select a location before continuing.',
          );
          return;
        }

        Navigator.pushNamed(
          context,
          RouteNames.generateMap,
          arguments: location,
        );
      },
    );

    return AppLayout(
      child: ResponsiveTwoPane(
        // Mobile layout (unchanged).
        compact: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CreateHero(),

            const SizedBox(height: 40),

            ...searchSection,

            const SizedBox(height: 36),

            mapPreview,

            const SizedBox(height: 24),
            continueButton,
            const SizedBox(height: 20),
          ],
        ),

        // Wide web: search | map preview + continue, bottoms aligned.
        crossAxisAlignment: CrossAxisAlignment.end,
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CreateHero(),
            const SizedBox(height: 40),
            ...searchSection,
          ],
        ),
        end: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 360, child: mapPreview),
            const SizedBox(height: 24),
            continueButton,
          ],
        ),
      ),
    );
  }
}

class _CreateHero extends StatelessWidget {
  const _CreateHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '02 / NEW PROJECT',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        Text(
          'CREATE\nPOSTER',
          style: AppTextStyles.displayXL.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        Container(width: 72, height: 5, color: AppColors.neonLime),
      ],
    );
  }
}

class _LocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _LocationSearchField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,

      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),

      decoration: InputDecoration(
        hintText: 'SEARCH CITY OR PLACE',
        hintStyle: AppTextStyles.label.copyWith(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.neonLime, width: 2),
        ),
      ),
    );
  }
}

class _LocationSearchResults extends StatelessWidget {
  final List<LocationResult> locations;
  final ValueChanged<LocationResult> onSelected;

  const _LocationSearchResults({
    required this.locations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: locations.length,
        separatorBuilder: (_, _) {
          return const Divider(height: 1, color: AppColors.divider);
        },
        itemBuilder: (context, index) {
          final location = locations[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(location),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        location.name ?? 'UNKNOWN LOCATION',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
        ),

        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _MapPreviewPlaceholder extends StatelessWidget {
  final LocationResult? location;

  const _MapPreviewPlaceholder({this.location});

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        location?.latitude != null && location?.longitude != null;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _MapGrid()),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasLocation ? Icons.location_on : Icons.map_outlined,
                  color: AppColors.neonLime,
                  size: 42,
                ),

                const SizedBox(height: 12),

                Text(
                  hasLocation ? 'LOCATION SELECTED' : 'MAP PREVIEW',
                  style: AppTextStyles.technical.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Text(
              location?.name ?? 'LOCATION / --',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
          ),

          if (hasLocation)
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                '${location!.latitude!.toStringAsFixed(4)}, '
                '${location!.longitude!.toStringAsFixed(4)}',
                style: AppTextStyles.label.copyWith(color: AppColors.neonLime),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapGrid extends StatelessWidget {
  const _MapGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textInverse.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 28.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return false;
  }
}
