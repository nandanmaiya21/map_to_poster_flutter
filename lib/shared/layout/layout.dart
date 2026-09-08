import 'package:flutter/material.dart';
import 'package:map_to_poster/core/theme/app_color.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  const AppLayout({
    super.key,
    required this.child,
    this.scrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: scrollable
            ? SingleChildScrollView(padding: padding, child: child)
            : Padding(padding: padding, child: child),
      ),
    );
  }
}
