import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_text_styles.dart';
import 'toast_config.dart';

class AppToastWidget extends StatefulWidget {
  final ToastConfig config;
  final VoidCallback onDismissed;

  const AppToastWidget({
    super.key,
    required this.config,
    required this.onDismissed,
  });

  @override
  State<AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<AppToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(begin: _getSlideBegin(), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();

    _timer = Timer(widget.config.duration, _dismiss);
  }

  Offset _getSlideBegin() {
    switch (widget.config.position) {
      case ToastPosition.top:
      case ToastPosition.topLeft:
      case ToastPosition.topRight:
        return const Offset(0, -0.3);

      case ToastPosition.bottom:
      case ToastPosition.bottomLeft:
      case ToastPosition.bottomRight:
        return const Offset(0, 0.3);

      case ToastPosition.center:
        return const Offset(0.15, 0);
    }
  }

  Future<void> _dismiss() async {
    if (!mounted) return;

    await _controller.reverse();

    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _getTop(),
      bottom: _getBottom(),
      left: _getLeft(),
      right: _getRight(),
      child: SafeArea(
        child: IgnorePointer(ignoring: false, child: _buildAnimatedToast()),
      ),
    );
  }

  Widget _buildAnimatedToast() {
    Widget child = _ToastContent(config: widget.config, onClose: _dismiss);

    switch (widget.config.animation) {
      case ToastAnimation.fade:
        return FadeTransition(opacity: _fadeAnimation, child: child);

      case ToastAnimation.slide:
        return SlideTransition(position: _slideAnimation, child: child);

      case ToastAnimation.scale:
        return ScaleTransition(scale: _scaleAnimation, child: child);

      case ToastAnimation.slideFade:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
    }
  }

  double? _getTop() {
    switch (widget.config.position) {
      case ToastPosition.top:
      case ToastPosition.topLeft:
      case ToastPosition.topRight:
        return 16;

      case ToastPosition.center:
        return null;

      default:
        return null;
    }
  }

  double? _getBottom() {
    switch (widget.config.position) {
      case ToastPosition.bottom:
      case ToastPosition.bottomLeft:
      case ToastPosition.bottomRight:
        return 24;

      case ToastPosition.center:
        return null;

      default:
        return null;
    }
  }

  double? _getLeft() {
    switch (widget.config.position) {
      case ToastPosition.topLeft:
      case ToastPosition.bottomLeft:
        return 16;

      case ToastPosition.center:
        return 20;

      case ToastPosition.top:
      case ToastPosition.bottom:
        return 20;

      default:
        return null;
    }
  }

  double? _getRight() {
    switch (widget.config.position) {
      case ToastPosition.topRight:
      case ToastPosition.bottomRight:
        return 16;

      case ToastPosition.center:
        return 20;

      case ToastPosition.top:
      case ToastPosition.bottom:
        return 20;

      default:
        return null;
    }
  }
}

class _ToastContent extends StatelessWidget {
  final ToastConfig config;
  final VoidCallback onClose;

  const _ToastContent({required this.config, required this.onClose});

  Color get _accentColor {
    switch (config.type) {
      case ToastType.success:
        return AppColors.neonLime;

      case ToastType.error:
        return const Color(0xFFFF4D4D);

      case ToastType.warning:
        return const Color(0xFFFFC700);

      case ToastType.info:
        return AppColors.textInverse;
    }
  }

  IconData get _icon {
    switch (config.type) {
      case ToastType.success:
        return Icons.check;

      case ToastType.error:
        return Icons.close;

      case ToastType.warning:
        return Icons.warning_amber_rounded;

      case ToastType.info:
        return Icons.info_outline;
    }
  }

  String get _label {
    switch (config.type) {
      case ToastType.success:
        return 'SUCCESS';

      case ToastType.error:
        return 'ERROR';

      case ToastType.warning:
        return 'WARNING';

      case ToastType.info:
        return 'SYSTEM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(color: _accentColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent bar
              Container(width: 6, color: _accentColor),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      if (config.showIcon) ...[
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            _icon,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),
                      ],

                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  config.title ?? _label,
                                  style: AppTextStyles.technical.copyWith(
                                    color: _accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            Text(
                              config.message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textInverse,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      InkWell(
                        onTap: onClose,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
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
