import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';

enum AppLoaderSize { small, medium, large }

class AppLoader extends StatefulWidget {
  final String label;
  final AppLoaderSize size;

  const AppLoader({
    super.key,
    this.label = 'PROCESSING...',
    this.size = AppLoaderSize.medium,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  double get _size {
    switch (widget.size) {
      case AppLoaderSize.small:
        return 36;
      case AppLoaderSize.medium:
        return 64;
      case AppLoaderSize.large:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LoaderPainter(progress: _controller.value),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.technical.copyWith(
              color: AppColors.textMuted,
              fontSize: widget.size == AppLoaderSize.small ? 9 : 11,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          _LoadingBars(animation: _controller, width: _size * 1.6),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _LoadingBars extends StatelessWidget {
  final Animation<double> animation;
  final double width;

  const _LoadingBars({required this.animation, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 3,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(width: width, height: 2, color: AppColors.border),

              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animation.value,
                  child: Container(height: 2, color: AppColors.neonLime),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;

  _LoaderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2;

    final primaryPaint = Paint()
      ..color = AppColors.neonLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final mutedPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Outer technical circle
    canvas.drawCircle(center, radius - 2, mutedPaint);

    // Rotating arc
    final rect = Rect.fromCircle(center: center, radius: radius - 2);

    canvas.drawArc(
      rect,
      progress * math.pi * 2,
      math.pi * 0.75,
      false,
      primaryPaint,
    );

    // Crosshair
    final lineLength = radius * 0.65;

    canvas.drawLine(
      Offset(center.dx - lineLength, center.dy),
      Offset(center.dx + lineLength, center.dy),
      mutedPaint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - lineLength),
      Offset(center.dx, center.dy + lineLength),
      mutedPaint,
    );

    // Pulsing center
    final pulse = 3 + math.sin(progress * math.pi * 2) * 2;

    canvas.drawCircle(center, pulse, Paint()..color = AppColors.neonLime);

    // Four corner markers
    final markerPaint = Paint()
      ..color = AppColors.neonLime
      ..strokeWidth = 2;

    const markerLength = 8.0;

    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius * 0.5),
      Offset(center.dx - radius + markerLength, center.dy - radius * 0.5),
      markerPaint,
    );

    canvas.drawLine(
      Offset(center.dx + radius, center.dy + radius * 0.5),
      Offset(center.dx + radius - markerLength, center.dy + radius * 0.5),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
