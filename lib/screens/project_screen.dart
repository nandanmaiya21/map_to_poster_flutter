import 'package:flutter/material.dart';

import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/widgets/action_button.dart';
import 'package:map_to_poster/shared/layout/layout.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '03 / MAP POSTER PROJECTS',
            style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          _ProjectsHero(),

          SizedBox(height: 32),

          _ProjectsHeader(),

          SizedBox(height: 16),

          _ProjectsGrid(),

          SizedBox(height: 24),

          ActionButton(
            text: "CREATE NEW PROJECT",
            onPressed: () {},
            type: ActionButtonType.outlined,
            prefixIcon: const Icon(
              Icons.add,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProjectsHero extends StatelessWidget {
  const _ProjectsHero();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'YOUR\nPROJECTS',
            style: AppTextStyles.displayXL.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '03',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.neonLime,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR MAP POSTERS',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 10),

        Container(height: 1, width: double.infinity, color: AppColors.border),
      ],
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  const _ProjectsGrid();

  @override
  Widget build(BuildContext context) {
    final projects = [
      const _ProjectData(index: '01', city: 'TORONTO', country: 'CANADA'),
      const _ProjectData(index: '02', city: 'NEW YORK', country: 'USA'),
      const _ProjectData(index: '03', city: 'TOKYO', country: 'JAPAN'),
      const _ProjectData(index: '04', city: 'LONDON', country: 'UK'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        return _ProjectCard(project: projects[index]);
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final _ProjectData project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Open project
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
            // Index
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                project.index,
                style: AppTextStyles.label.copyWith(color: AppColors.neonLime),
              ),
            ),

            // Decorative map lines placeholder
            const Positioned.fill(child: _MapPattern()),

            // City name
            Positioned(
              left: 12,
              right: 12,
              bottom: 28,
              child: Text(
                project.city,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textInverse,
                  fontSize: 30,
                ),
              ),
            ),

            // Country
            Positioned(
              left: 12,
              bottom: 12,
              child: Text(
                project.country,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
            ),

            // Neon corner marker
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 20,
                height: 20,
                color: AppColors.neonLime,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPattern extends StatelessWidget {
  const _MapPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPatternPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textInverse.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.35)
      ..lineTo(size.width * 0.15, size.height * 0.55)
      ..lineTo(size.width * 0.65, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height);

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _MapPatternPainter oldDelegate) {
    return false;
  }
}

class _ProjectData {
  final String index;
  final String city;
  final String country;

  const _ProjectData({
    required this.index,
    required this.city,
    required this.country,
  });
}
