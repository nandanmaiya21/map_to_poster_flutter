import 'package:flutter/material.dart';

import 'app_toast_widget.dart';
import 'toast_config.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
    ToastAnimation animation = ToastAnimation.slideFade,
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
  }) {
    dismiss();

    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return AppToastWidget(
          config: ToastConfig(
            message: message,
            title: title,
            type: type,
            position: position,
            animation: animation,
            duration: duration,
            showIcon: showIcon,
          ),
          onDismissed: () {
            overlayEntry.remove();

            if (_currentToast == overlayEntry) {
              _currentToast = null;
            }
          },
        );
      },
    );

    _currentToast = overlayEntry;

    overlay.insert(overlayEntry);
  }

  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }

  static void success(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.success,
      position: position,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.error,
      position: position,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.warning,
      position: position,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    String? title,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.info,
      position: position,
    );
  }
}
