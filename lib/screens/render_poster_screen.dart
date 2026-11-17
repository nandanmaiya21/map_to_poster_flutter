import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:map_to_poster/bloc/render_map/render_map_cubit.dart';
import 'package:map_to_poster/constants/api_consatant.dart';
import 'package:map_to_poster/core/responsive/responsive.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';
import 'package:map_to_poster/core/toast/app_toast.dart';
import 'package:map_to_poster/core/widgets/action_button.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';
import 'package:map_to_poster/data/models/export_format.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/shared/layout/layout.dart';

class RenderPosterScreen extends StatefulWidget {
  const RenderPosterScreen({super.key});

  @override
  State<RenderPosterScreen> createState() => _RenderPosterScreenState();
}

class _RenderPosterScreenState extends State<RenderPosterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RenderMapCubit>().render(ExportFormat.png);
  }

  void _finish() {
    appShellCubit.updateIndex(2);
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      RouteNames.home,
      (route) => false,
    );
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(ApiConstants.posterAssetUrl(url));
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      AppToast.error(context, 'Could not open the file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RenderMapCubit>();

    final header = _RenderHeader(
      onBack: () => navigatorKey.currentState?.pop(),
    );

    final posterPreview = BlocBuilder<RenderMapCubit, RenderMapState>(
      builder: (context, state) {
        return _PosterPreview(
          job: state.jobFor(ExportFormat.png),
          title: cubit.title,
          subtitle: cubit.subtitle,
          coordinates: cubit.coordinates,
        );
      },
    );

    final exportSection = <Widget>[
      Text(
        'EXPORT FORMATS',
        style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
      ),

      const SizedBox(height: 12),

      BlocBuilder<RenderMapCubit, RenderMapState>(
        builder: (context, state) {
          return Column(
            children: ExportFormat.values.map((format) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FormatTile(
                  format: format,
                  job: state.jobFor(format),
                  onGenerate: () {
                    context.read<RenderMapCubit>().render(format);
                  },
                  onOpen: _openFile,
                ),
              );
            }).toList(),
          );
        },
      ),

      const SizedBox(height: 28),

      ActionButton(
        text: 'DONE',
        type: ActionButtonType.filled,
        onPressed: _finish,
      ),
    ];

    return AppLayout(
      child: ResponsiveTwoPane(
        // Mobile layout (unchanged).
        compact: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,

            const SizedBox(height: 32),

            WebMaxHeight(maxHeight: 720, child: posterPreview),

            const SizedBox(height: 28),

            ...exportSection,

            const SizedBox(height: 20),
          ],
        ),

        // Wide web: header + exports | poster.
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [header, const SizedBox(height: 40), ...exportSection],
        ),
        end: WebMaxHeight(maxHeight: 820, child: posterPreview),
      ),
    );
  }
}

class _RenderHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _RenderHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            Icon(
              Icons.auto_fix_high_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
          ],
        ),
        Text(
          'EXPORT / FINAL STEP',
          style: AppTextStyles.technical.copyWith(color: AppColors.textMuted),
        ),

        const SizedBox(height: 16),

        Text(
          'YOUR\nPOSTER',
          style: AppTextStyles.displayXL.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        Container(width: 72, height: 5, color: AppColors.neonLime),

        const SizedBox(height: 16),

        Text(
          'WE ARE PAINTING YOUR MAP INTO A POSTER.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _PosterPreview extends StatelessWidget {
  final RenderJob job;
  final String title;
  final String subtitle;
  final String coordinates;

  const _PosterPreview({
    required this.job,
    required this.title,
    required this.subtitle,
    required this.coordinates,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(color: AppColors.border, width: 2),
        ),
        clipBehavior: Clip.hardEdge,
        child: Builder(
          builder: (context) {
            switch (job.status) {
              case RenderJobStatus.success:
                final url = job.response?.url;

                if (url == null) {
                  return _GeneratingPosterAnimation(
                    title: title,
                    subtitle: subtitle,
                    coordinates: coordinates,
                  );
                }

                return Image.network(
                  ApiConstants.posterAssetUrl(url),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _GeneratingPosterAnimation(
                      title: title,
                      subtitle: subtitle,
                      coordinates: coordinates,
                    );
                  },
                  errorBuilder: (context, error, stack) {
                    return const _PosterError(
                      message: 'Rendered, but the preview failed to load.',
                    );
                  },
                );

              case RenderJobStatus.failure:
                return _PosterError(
                  message: job.error,
                  onRetry: () {
                    context.read<RenderMapCubit>().render(ExportFormat.png);
                  },
                );

              case RenderJobStatus.idle:
              case RenderJobStatus.loading:
                return _GeneratingPosterAnimation(
                  title: title,
                  subtitle: subtitle,
                  coordinates: coordinates,
                );
            }
          },
        ),
      ),
    );
  }
}

// A little theatre for the wait: roads trace themselves in at the top while
// the poster's own title/subtitle/coordinates decode into view below —
// previewing the exact piece being painted rather than a generic spinner.
class _GeneratingPosterAnimation extends StatefulWidget {
  final String title;
  final String subtitle;
  final String coordinates;

  const _GeneratingPosterAnimation({
    required this.title,
    required this.subtitle,
    required this.coordinates,
  });

  @override
  State<_GeneratingPosterAnimation> createState() =>
      _GeneratingPosterAnimationState();
}

class _GeneratingPosterAnimationState extends State<_GeneratingPosterAnimation>
    with TickerProviderStateMixin {
  static const _captions = [
    'PLOTTING THE STREETS',
    'MIXING THE INK',
    'STRETCHING THE CANVAS',
    'ALIGNING THE GRID',
    'SIGNING THE CORNER',
  ];

  late final AnimationController _roadController;
  late final AnimationController _pulseController;
  late final AnimationController _captionController;
  late final AnimationController _cursorController;
  int _captionIndex = 0;

  @override
  void initState() {
    super.initState();

    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _captionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();

    _captionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _captionIndex = (_captionIndex + 1) % _captions.length);
        _captionController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _roadController.dispose();
    _pulseController.dispose();
    _captionController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upper zone: the map tracing itself into existence.
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _AnimationGrid(),

              AnimatedBuilder(
                animation: _roadController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RoadDrawPainter(progress: _roadController.value),
                    size: Size.infinite,
                  );
                },
              ),

              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = 0.25 + _pulseController.value * 0.3;
                    final scale = 0.88 + (_pulseController.value * 0.18);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neonLime,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonLime.withValues(alpha: glow),
                              blurRadius: 22,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.neonLime,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                top: 14,
                left: 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GENERATING',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.neonLime,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedBuilder(
                      animation: _cursorController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _cursorController.value,
                          child: Container(
                            width: 6,
                            height: 10,
                            color: AppColors.neonLime,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lower zone: the poster's own text materializing.
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DecodeText(
                  text: widget.title.isEmpty ? 'UNTITLED' : widget.title,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textInverse,
                    fontSize: 34,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),

                const SizedBox(height: 4),

                _DecodeText(
                  text: widget.subtitle,
                  style: AppTextStyles.technical.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  startDelay: const Duration(milliseconds: 350),
                ),

                const SizedBox(height: 10),

                _DecodeText(
                  text: widget.coordinates,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.neonLime,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  startDelay: const Duration(milliseconds: 650),
                ),

                const SizedBox(height: 16),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _captions[_captionIndex],
                    key: ValueKey(_captionIndex),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.technical.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Scrambles random characters into the real text, left to right, then holds
// before looping — like a terminal decoding a transmission.
class _DecodeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;
  final Duration startDelay;

  static const _decodeDuration = Duration(milliseconds: 900);
  static const _holdDuration = Duration(milliseconds: 3400);

  const _DecodeText({
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.startDelay = Duration.zero,
  });

  @override
  State<_DecodeText> createState() => _DecodeTextState();
}

class _DecodeTextState extends State<_DecodeText>
    with SingleTickerProviderStateMixin {
  static const _charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  late final AnimationController _controller;
  final math.Random _random = math.Random();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _DecodeText._decodeDuration,
    );
    _loop();
  }

  Future<void> _loop() async {
    await Future.delayed(widget.startDelay);

    while (!_disposed) {
      await _controller.forward(from: 0);
      if (_disposed) return;
      await Future.delayed(_DecodeText._holdDuration);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  String _scramble(double progress) {
    if (widget.text.isEmpty) return '';

    final revealCount = (widget.text.length * progress).ceil();
    final chars = widget.text.split('');

    return List.generate(chars.length, (i) {
      final char = chars[i];

      if (i < revealCount || char.trim().isEmpty || !_isLetterOrDigit(char)) {
        return char;
      }

      return _charset[_random.nextInt(_charset.length)];
    }).join();
  }

  bool _isLetterOrDigit(String char) {
    return RegExp(r'[A-Za-z0-9]').hasMatch(char);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          _scramble(_controller.value),
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
          style: widget.style,
        );
      },
    );
  }
}

class _AnimationGrid extends StatelessWidget {
  const _AnimationGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AnimationGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _AnimationGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
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
  bool shouldRepaint(covariant _AnimationGridPainter oldDelegate) => false;
}

// Draws two winding "roads" tracing themselves in on a loop, each with a
// glowing pen tip at the growing end — the map sketching itself.
class _RoadDrawPainter extends CustomPainter {
  final double progress;

  _RoadDrawPainter({required this.progress});

  Path _majorRoad(Size size) {
    return Path()
      ..moveTo(-10, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.04,
        size.width * 0.55,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.68,
        size.width + 10,
        size.height * 0.46,
      );
  }

  Path _minorRoad(Size size) {
    return Path()
      ..moveTo(size.width * 0.12, -10)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.32,
        size.width * 0.34,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.88,
        size.width * 0.62,
        size.height + 10,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawAnimatedPath(
      canvas,
      _majorRoad(size),
      progress,
      AppColors.neonLime,
      3,
    );

    final minorProgress = (progress + 0.5) % 1.0;
    _drawAnimatedPath(
      canvas,
      _minorRoad(size),
      minorProgress,
      AppColors.neonLimeSoft,
      2,
    );
  }

  void _drawAnimatedPath(
    Canvas canvas,
    Path path,
    double t,
    Color color,
    double width,
  ) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final drawLength = metric.length * Curves.easeInOut.transform(t);
    final extracted = metric.extractPath(0, drawLength);

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(extracted, paint);

    if (drawLength > 0 && drawLength < metric.length) {
      final tangent = metric.getTangentForOffset(drawLength);

      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          width + 6,
          Paint()..color = color.withValues(alpha: 0.22),
        );
        canvas.drawCircle(
          tangent.position,
          width + 2,
          Paint()..color = color.withValues(alpha: 0.95),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadDrawPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PosterError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const _PosterError({this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.neonLime,
              size: 40,
            ),

            const SizedBox(height: 14),

            Text(
              'RENDER FAILED',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textInverse,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message ?? 'Something went wrong while rendering the poster.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neonLime),
                  ),
                  child: Text(
                    'RETRY',
                    style: AppTextStyles.technical.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  final ExportFormat format;
  final RenderJob job;
  final VoidCallback onGenerate;
  final ValueChanged<String> onOpen;

  const _FormatTile({
    required this.format,
    required this.job,
    required this.onGenerate,
    required this.onOpen,
  });

  String _statusText() {
    switch (job.status) {
      case RenderJobStatus.idle:
        return 'NOT GENERATED YET';
      case RenderJobStatus.loading:
        return 'RENDERING...';
      case RenderJobStatus.success:
        return 'READY TO OPEN';
      case RenderJobStatus.failure:
        return job.error ?? 'FAILED TO RENDER';
    }
  }

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
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              format.label,
              style: AppTextStyles.label.copyWith(color: AppColors.textInverse),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              _statusText(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 10),

          _Trailing(
            format: format,
            job: job,
            onGenerate: onGenerate,
            onOpen: onOpen,
          ),
        ],
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  final ExportFormat format;
  final RenderJob job;
  final VoidCallback onGenerate;
  final ValueChanged<String> onOpen;

  const _Trailing({
    required this.format,
    required this.job,
    required this.onGenerate,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    switch (job.status) {
      case RenderJobStatus.loading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.neonLime,
          ),
        );

      case RenderJobStatus.success:
        return GestureDetector(
          onTap: () {
            final url = job.response?.url;
            if (url != null) onOpen(url);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(color: AppColors.neonLime),
            child: Text(
              'OPEN',
              style: AppTextStyles.technical.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );

      case RenderJobStatus.idle:
      case RenderJobStatus.failure:
        return GestureDetector(
          onTap: onGenerate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'GENERATE',
              style: AppTextStyles.technical.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
    }
  }
}
