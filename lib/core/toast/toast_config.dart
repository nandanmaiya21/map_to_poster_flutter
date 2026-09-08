import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

enum ToastPosition {
  top,
  topLeft,
  topRight,
  center,
  bottom,
  bottomLeft,
  bottomRight,
}

enum ToastAnimation { fade, slide, scale, slideFade }

class ToastConfig {
  final String message;
  final String? title;

  final ToastType type;
  final ToastPosition position;
  final ToastAnimation animation;

  final Duration duration;

  final bool showIcon;

  const ToastConfig({
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.position = ToastPosition.bottom,
    this.animation = ToastAnimation.slideFade,
    this.duration = const Duration(seconds: 3),
    this.showIcon = true,
  });
}
