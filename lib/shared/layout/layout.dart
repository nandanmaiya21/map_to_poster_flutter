import 'package:flutter/material.dart';
import 'package:map_to_poster/core/responsive/responsive.dart';
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
    final size = Responsive.of(context);

    // Mobile app and phone-width web: unchanged.
    if (size == ScreenSize.compact) {
      return Material(
        color: AppColors.background,
        child: SafeArea(
          child: scrollable
              ? SingleChildScrollView(padding: padding, child: child)
              : Padding(padding: padding, child: child),
        ),
      );
    }

    // Wider web windows: centred column with a max width.
    final maxWidth = size == ScreenSize.expanded
        ? Responsive.expandedContentWidth
        : Responsive.mediumContentWidth;

    final webPadding = size == ScreenSize.expanded
        ? const EdgeInsets.symmetric(horizontal: 48, vertical: 40)
        : const EdgeInsets.symmetric(horizontal: 32, vertical: 32);

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: webPadding, child: child),
      ),
    );

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: scrollable
            ? SingleChildScrollView(
                child: Align(alignment: Alignment.topCenter, child: content),
              )
            : content,
      ),
    );
  }
}
