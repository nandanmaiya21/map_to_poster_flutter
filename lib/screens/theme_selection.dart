import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/bloc/create_project/create_project_cubit.dart';

import 'package:map_to_poster/bloc/theme/theme_cubit.dart';
import 'package:map_to_poster/core/responsive/responsive.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/widgets/app_loader.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';
import 'package:map_to_poster/data/models/theme_preset.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/shared/layout/layout.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          switch (state.status) {
            case ThemeStatus.initial:
            case ThemeStatus.loading:
              return const _ThemeLoading();

            case ThemeStatus.failure:
              return _ThemeError(
                message: state.errorMessage,
                onRetry: () {
                  context.read<ThemeCubit>().loadThemes();
                },
              );

            case ThemeStatus.success:
              final themes = state.themes ?? [];

              if (themes.isEmpty) {
                return _EmptyThemes(
                  onRetry: () {
                    context.read<ThemeCubit>().loadThemes();
                  },
                );
              }

              return _ThemeContent(
                themes: themes.whereType<ThemePreset>().toList(),
              );
          }
        },
      ),
    );
  }
}

class _ThemeLoading extends StatelessWidget {
  const _ThemeLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppLoader(size: AppLoaderSize.large, label: 'LOADING PRESETS'),
    );
  }
}

class _ThemeContent extends StatelessWidget {
  final List<ThemePreset> themes;

  const _ThemeContent({required this.themes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ThemeHeader(),

        const SizedBox(height: 36),

        Text(
          '${themes.length} PRESETS AVAILABLE',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: themes.length,
          gridDelegate: Responsive.gridDelegate(
            context,
            mobile: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            expandedColumns: 5,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              child: _ThemeCard(
                theme: themes[index],
                onTap: () {
                  final createProjectCubit = context.read<CreateProjectCubit>();
                  createProjectCubit.selectTheme(themes[index]);

                  navigatorKey.currentState?.pushNamed(
                    RouteNames.layoutSelection,
                    arguments: createProjectCubit,
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _ThemeHeader extends StatelessWidget {
  const _ThemeHeader();

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
              icon: Icon(Icons.arrow_back),
            ),
            Icon(Icons.palette_outlined, size: 48, color: AppColors.textMuted),
          ],
        ),
        Text(
          'STYLE PROJECT / 1 OF 2',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        Text(
          'CHOOSE\nTHEME',
          style: AppTextStyles.displayXL.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        Container(width: 72, height: 5, color: AppColors.neonLime),

        const SizedBox(height: 16),

        Text(
          'SELECT A VISUAL SYSTEM FOR YOUR MAP POSTER.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatefulWidget {
  final ThemePreset theme;
  final VoidCallback onTap;

  const _ThemeCard({required this.theme, required this.onTap});

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    final backgroundColor = _parseColor(
      theme.background,
      fallback: AppColors.surfaceDark,
    );

    final roadColor = _getPrimaryRoadColor(theme);

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
            border: Border.all(color: AppColors.border, width: 1),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: backgroundColor,

                  child: CustomPaint(
                    painter: _ThemePreviewPainter(
                      backgroundColor: backgroundColor,
                      roadColor: roadColor,
                      waterColor: _parseColor(
                        theme.waterColor,
                        fallback: Colors.transparent,
                      ),
                      parkColor: _parseColor(
                        theme.parkColor,
                        fallback: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name ?? 'UNTITLED',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      theme.slug?.toUpperCase() ?? 'CUSTOM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.technical.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
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

  Color _getPrimaryRoadColor(ThemePreset theme) {
    final colors = theme.roadColors;

    if (colors == null || colors.isEmpty) {
      return AppColors.textMuted;
    }

    final preferredKeys = [
      'primary',
      'secondary',
      'major',
      'motorway',
      'default',
    ];

    for (final key in preferredKeys) {
      if (colors.containsKey(key)) {
        return _parseColor(colors[key], fallback: AppColors.textMuted);
      }
    }

    return _parseColor(colors.values.first, fallback: AppColors.textMuted);
  }
}

class _ThemePreviewPainter extends CustomPainter {
  final Color backgroundColor;
  final Color roadColor;
  final Color waterColor;
  final Color parkColor;

  const _ThemePreviewPainter({
    required this.backgroundColor,
    required this.roadColor,
    required this.waterColor,
    required this.parkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Parks
    if (parkColor != Colors.transparent) {
      final parkPaint = Paint()..color = parkColor.withValues(alpha: 0.7);

      canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.22),
        size.width * 0.18,
        parkPaint,
      );

      canvas.drawCircle(
        Offset(size.width * 0.78, size.height * 0.72),
        size.width * 0.14,
        parkPaint,
      );
    }

    // Water
    if (waterColor != Colors.transparent) {
      final waterPaint = Paint()..color = waterColor.withValues(alpha: 0.8);

      final path = Path()
        ..moveTo(0, size.height * 0.72)
        ..quadraticBezierTo(
          size.width * 0.35,
          size.height * 0.58,
          size.width * 0.55,
          size.height * 0.78,
        )
        ..quadraticBezierTo(
          size.width * 0.8,
          size.height * 0.95,
          size.width,
          size.height * 0.8,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(path, waterPaint);
    }

    final minorRoad = Paint()
      ..color = roadColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final majorRoad = Paint()
      ..color = roadColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Minor road network
    for (double x = -40; x < size.width + 40; x += 28) {
      final path = Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + 12, size.height * 0.4, x - 8, size.height);

      canvas.drawPath(path, minorRoad);
    }

    for (double y = 20; y < size.height; y += 24) {
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.5, y - 15, size.width, y + 8);

      canvas.drawPath(path, minorRoad);
    }

    // Major roads
    final path1 = Path()
      ..moveTo(-20, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.52,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.5,
        size.width + 20,
        size.height * 0.35,
      );

    canvas.drawPath(path1, majorRoad);

    final path2 = Path()
      ..moveTo(size.width * 0.15, -20)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.4,
        size.width * 0.62,
        size.height + 20,
      );

    canvas.drawPath(path2, majorRoad);
  }

  @override
  bool shouldRepaint(covariant _ThemePreviewPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.roadColor != roadColor ||
        oldDelegate.waterColor != waterColor ||
        oldDelegate.parkColor != parkColor;
  }
}

Color _parseColor(String? hex, {required Color fallback}) {
  if (hex == null || hex.trim().isEmpty) {
    return fallback;
  }

  try {
    String value = hex.trim().replaceAll('#', '');

    // RGB shorthand
    if (value.length == 3) {
      value =
          '${value[0]}${value[0]}'
          '${value[1]}${value[1]}'
          '${value[2]}${value[2]}';
    }

    // RGB
    if (value.length == 6) {
      value = 'FF$value';
    }

    // Invalid
    if (value.length != 8) {
      return fallback;
    }

    final colorValue = int.tryParse(value, radix: 16);

    if (colorValue == null) {
      return fallback;
    }

    return Color(colorValue);
  } catch (_) {
    return fallback;
  }
}

class _EmptyThemes extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyThemes({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.palette_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),

            const SizedBox(height: 20),

            Text(
              'NO PRESETS AVAILABLE',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'WE COULDN’T FIND ANY DESIGN PRESETS.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),

            const SizedBox(height: 24),

            OutlinedButton(onPressed: onRetry, child: const Text('RETRY')),
          ],
        ),
      ),
    );
  }
}

class _ThemeError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ThemeError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.error_outline, color: AppColors.neonLime),
            ),

            const SizedBox(height: 20),

            Text(
              'FAILED TO LOAD',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message ?? 'UNABLE TO LOAD THEME PRESETS.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neonLime),
                ),
                child: Text(
                  'TRY AGAIN',
                  style: AppTextStyles.technical.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
