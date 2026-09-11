import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:map_to_poster/bloc/app_shell/app_shell_cubit.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/toast/app_toast.dart';
import 'package:map_to_poster/core/widgets/action_button.dart';
import 'package:map_to_poster/core/widgets/app_loader.dart';
import 'package:map_to_poster/data/models/project_entry.dart';
import 'package:map_to_poster/repository/repository.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/screens/layout_selection.dart';
import 'package:map_to_poster/services/project_storage_service.dart';
import 'package:map_to_poster/shared/layout/layout.dart';

const _kMapStatusCompleted = 'completed';
const _kMapStatusFailed = 'failed';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final ProjectStorageService _storage = ProjectStorageService();
  late final Future<List<ProjectEntry>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _storage.getProjects();
  }

  void _goToCreateProject() {
    context.read<AppShellCubit>().updateIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: FutureBuilder<List<ProjectEntry>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState != ConnectionState.done;
          final projects = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '03 / MAP POSTER PROJECTS',
                style: AppTextStyles.technical.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              const _ProjectsHero(),

              const SizedBox(height: 32),

              const _ProjectsHeader(),

              const SizedBox(height: 16),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: AppLoader(label: 'LOADING PROJECTS')),
                )
              else if (projects.isEmpty)
                _EmptyProjects(onCreate: _goToCreateProject)
              else
                _ProjectsGrid(
                  projects: projects,
                  onCreateNew: _goToCreateProject,
                ),

              const SizedBox(height: 20),
            ],
          );
        },
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

class _EmptyProjects extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyProjects({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.map_outlined, size: 48, color: AppColors.textMuted),

          const SizedBox(height: 20),

          Text(
            'NO PROJECTS YET',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'GENERATE YOUR FIRST MAP POSTER TO SEE IT HERE.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),

          const SizedBox(height: 24),

          ActionButton(
            text: 'CREATE NEW PROJECT',
            onPressed: onCreate,
            type: ActionButtonType.filled,
            prefixIcon: const Icon(
              Icons.add,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  final List<ProjectEntry> projects;
  final VoidCallback onCreateNew;

  const _ProjectsGrid({required this.projects, required this.onCreateNew});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CreateProjectCard(onTap: onCreateNew);
        }

        return _ProjectCard(project: projects[index - 1]);
      },
    );
  }
}

class _CreateProjectCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateProjectCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 32,
                color: AppColors.textPrimary,
              ),

              const SizedBox(height: 10),

              Text(
                'NEW PROJECT',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectEntry project;

  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  final Repository _repository = Repository();
  bool _isCheckingStatus = false;

  Future<void> _handleTap() async {
    if (_isCheckingStatus) return;

    setState(() => _isCheckingStatus = true);

    try {
      final status = await _repository.getMapGenerationStatus(
        widget.project.mapId,
      );

      if (!mounted) return;

      if (status.status == _kMapStatusCompleted) {
        Navigator.of(context).pushNamed(
          RouteNames.themeSelection,
          arguments: widget.project,
        );
      } else if (status.status == _kMapStatusFailed) {
        AppToast.error(context, 'Poster generation failed for this project.');
      } else {
        AppToast.info(
          context,
          'Your poster is still generating. Try styling it again shortly.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Unable to check poster status. Please try again.');
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    final title = (project.locationName.isEmpty
            ? 'MAP POSTER'
            : project.locationName)
        .toUpperCase();

    final shortId = (project.mapId.length > 8
            ? project.mapId.substring(0, 8)
            : project.mapId)
        .toUpperCase();

    final isStyled = project.themeSlug.isNotEmpty;

    final secondaryLine = isStyled
        ? '${project.country} · ${project.posterLayout.label}'
        : '${project.country} · ID $shortId';

    return InkWell(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
            // Status
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                isStyled ? 'STYLED' : 'TAP TO STYLE',
                style: AppTextStyles.label.copyWith(
                  color: isStyled ? AppColors.neonLime : AppColors.textMuted,
                ),
              ),
            ),

            // Decorative map lines placeholder
            const Positioned.fill(child: _MapPattern()),

            // Location name
            Positioned(
              left: 12,
              right: 12,
              bottom: 28,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textInverse,
                  fontSize: 26,
                ),
              ),
            ),

            // Country + style/id
            Positioned(
              left: 12,
              right: 28,
              bottom: 12,
              child: Text(
                secondaryLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

            // Checking overlay
            if (_isCheckingStatus)
              Positioned.fill(
                child: Container(
                  color: AppColors.surfaceDark.withValues(alpha: 0.85),
                  child: const Center(
                    child: AppLoader(
                      size: AppLoaderSize.small,
                      label: 'CHECKING...',
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
