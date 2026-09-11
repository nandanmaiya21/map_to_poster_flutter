import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/bloc/create_project/create_project_cubit.dart';
import 'package:map_to_poster/bloc/layout/layout_cubit.dart';

import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/toast/app_toast.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/services/project_storage_service.dart';
import 'package:map_to_poster/shared/layout/layout.dart';

enum PosterLayout { full, bottom, top, center }

extension PosterLayoutX on PosterLayout {
  String get label {
    switch (this) {
      case PosterLayout.full:
        return 'FULL';
      case PosterLayout.bottom:
        return 'BOTTOM';
      case PosterLayout.top:
        return 'TOP';
      case PosterLayout.center:
        return 'CENTER';
    }
  }

  String get description {
    switch (this) {
      case PosterLayout.full:
        return 'MAP FILLS THE ENTIRE POSTER.';
      case PosterLayout.bottom:
        return 'MAP ON TOP, DETAILS ANCHORED BELOW.';
      case PosterLayout.top:
        return 'DETAILS ON TOP, MAP ANCHORED BELOW.';
      case PosterLayout.center:
        return 'MAP FRAMED WITH MARGIN ON ALL SIDES.';
    }
  }
}

class LayoutSelectionScreen extends StatelessWidget {
  const LayoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LayoutHeader(),

          const SizedBox(height: 36),

          Text(
            '${PosterLayout.values.length} LAYOUTS AVAILABLE',
            style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: PosterLayout.values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final layout = PosterLayout.values[index];

              return BlocBuilder<LayoutCubit, LayoutState>(
                builder: (context, state) {
                  return _LayoutCard(
                    layout: layout,
                    isSelected: layout == state.layout,
                    onTap: () {
                      context.read<LayoutCubit>().setLayout(layout);
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),

          _ContinueButton(
            onTap: () async {
              final layout = context.read<LayoutCubit>().state.layout;

              if (layout == null) {
                AppToast.error(context, 'Please select a layout to continue.');
                return;
              }

              final createProjectCubit = context.read<CreateProjectCubit>();
              createProjectCubit.selectLayout(layout);

              final theme = createProjectCubit.state.selectedTheme;
              final themeSlug = theme?.slug ?? '';
              final project = createProjectCubit.project;

              await ProjectStorageService().updateProjectStyle(
                mapId: project.mapId,
                themeSlug: themeSlug,
                posterLayout: layout,
              );

              if (!context.mounted) return;

              navigatorKey.currentState?.pushNamed(
                RouteNames.renderPoster,
                arguments: project.copyWith(
                  themeSlug: themeSlug,
                  posterLayout: layout,
                ),
              );
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _LayoutHeader extends StatelessWidget {
  const _LayoutHeader();

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
              Icons.dashboard_customize_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
          ],
        ),
        Text(
          'STYLE PROJECT / 2 OF 2',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        Text(
          'ARRANGE\nPOSTER',
          style: AppTextStyles.displayXL.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        Container(width: 72, height: 5, color: AppColors.neonLime),

        const SizedBox(height: 16),

        Text(
          'CHOOSE HOW THE MAP SITS ON YOUR POSTER.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _LayoutCard extends StatefulWidget {
  final PosterLayout layout;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayoutCard({
    required this.layout,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LayoutCard> createState() => _LayoutCardState();
}

class _LayoutCardState extends State<_LayoutCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,

      onTapDown: (_) {
        setState(() => _isPressed = true);
      },

      onTapUp: (_) {
        setState(() => _isPressed = false);
      },

      onTapCancel: () {
        setState(() => _isPressed = false);
      },

      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _isPressed ? 0.97 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border.all(
              color: widget.isSelected ? AppColors.neonLime : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: AppColors.surfaceLight,
                  padding: const EdgeInsets.all(10),
                  child: _LayoutPreview(layout: widget.layout),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.layout.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),

                    if (widget.isSelected)
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.neonLime,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayoutPreview extends StatelessWidget {
  final PosterLayout layout;

  const _LayoutPreview({required this.layout});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: AppColors.divider.withValues(alpha: 0.3)),
            ),
            _buildMapBlock(),
          ],
        );
      },
    );
  }

  Widget _buildMapBlock() {
    const mapColor = AppColors.textMuted;

    switch (layout) {
      case PosterLayout.full:
        return Positioned.fill(child: Container(color: mapColor));

      case PosterLayout.bottom:
        return Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.62,
            child: Container(color: mapColor),
          ),
        );

      case PosterLayout.top:
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.62,
            child: Container(color: mapColor),
          ),
        );

      case PosterLayout.center:
        return Center(
          child: FractionallySizedBox(
            widthFactor: 0.66,
            heightFactor: 0.66,
            child: Container(color: mapColor),
          ),
        );
    }
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.textPrimary),
        child: Text(
          'CONTINUE',
          style: AppTextStyles.technical.copyWith(
            color: AppColors.textInverse,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
