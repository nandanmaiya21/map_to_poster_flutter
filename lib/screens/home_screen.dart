import 'package:flutter/material.dart';

import 'package:map_to_poster/core/responsive/responsive.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/widgets/action_button.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';

import 'package:map_to_poster/shared/layout/layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final createButton = ActionButton(
      text: "CREATE NEW POSTER",
      onPressed: () => appShellCubit.updateIndex(1),
      prefixIcon: const Icon(Icons.add, color: AppColors.textPrimary, size: 24),
    );

    return AppLayout(
      child: ResponsiveTwoPane(
        // Mobile layout (unchanged).
        compact: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroSection(),

            SizedBox(height: 28),

            WebMaxHeight(maxHeight: 640, child: _PosterPreview()),

            SizedBox(height: 20),

            createButton,
            SizedBox(height: 40),

            _RecentProjects(),
          ],
        ),

        // Wide web: intro + projects | poster preview.
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroSection(),
            const SizedBox(height: 32),
            createButton,
            const SizedBox(height: 48),
            const _RecentProjects(),
          ],
        ),
        end: const WebMaxHeight(maxHeight: 720, child: _PosterPreview()),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '01 / MAP DESIGN STUDIO',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        Text(
          'MAP\nTO\nPOSTER',
          style: AppTextStyles.displayXL.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        Container(width: 72, height: 5, color: AppColors.neonLime),

        const SizedBox(height: 16),

        Text(
          'TURN ANY CITY INTO A UNIQUE\nPIECE OF ART.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Stack(
            children: [
              // Technical label
              Positioned(
                top: 14,
                left: 14,
                child: Text(
                  'MAP PREVIEW',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.neonLime,
                  ),
                ),
              ),

              // Decorative grid
              const Positioned.fill(child: _PosterGrid()),

              // City title
              Center(
                child: Text(
                  'TORONTO',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textInverse,
                    fontSize: 56,
                  ),
                ),
              ),

              // Coordinates
              Positioned(
                bottom: 14,
                left: 14,
                child: Text(
                  '43.6532° N',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              Positioned(
                bottom: 14,
                right: 14,
                child: Text(
                  '79.3832° W',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterGrid extends StatelessWidget {
  const _PosterGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PosterGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _PosterGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PosterGridPainter oldDelegate) {
    return false;
  }
}

class _RecentProjects extends StatelessWidget {
  const _RecentProjects();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT PROJECTS',
          style: AppTextStyles.technical.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 10),

        const Divider(color: AppColors.border),

        const SizedBox(height: 4),

        const _ProjectItem(index: '01', city: 'TORONTO', country: 'CANADA'),

        const _ProjectItem(index: '02', city: 'NEW YORK', country: 'USA'),

        const _ProjectItem(index: '03', city: 'TOKYO', country: 'JAPAN'),
      ],
    );
  }
}

class _ProjectItem extends StatelessWidget {
  final String index;
  final String city;
  final String country;

  const _ProjectItem({
    required this.index,
    required this.city,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                index,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headingMedium,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    country,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            const Icon(
              Icons.arrow_forward,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
