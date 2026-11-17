import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// Screen size classes for the web build.
///
/// The native mobile app is ALWAYS [ScreenSize.compact], so its layout is
/// untouched. On the web, a phone-width window is also compact and renders
/// exactly like the app; only wider browser windows get the medium/expanded
/// layouts.
enum ScreenSize { compact, medium, expanded }

class Responsive {
  Responsive._();

  /// Browser windows narrower than this look exactly like the mobile app.
  static const double mediumBreakpoint = 600;

  /// From here on: side navigation and two-column screens.
  static const double expandedBreakpoint = 1024;

  /// Max content width for medium windows (single column, centred).
  static const double mediumContentWidth = 720;

  /// Max content width for expanded windows.
  static const double expandedContentWidth = 1200;

  static ScreenSize of(BuildContext context) {
    if (!kIsWeb) return ScreenSize.compact;

    final width = MediaQuery.sizeOf(context).width;

    if (width >= expandedBreakpoint) return ScreenSize.expanded;
    if (width >= mediumBreakpoint) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static bool isCompact(BuildContext context) =>
      of(context) == ScreenSize.compact;

  static bool isExpanded(BuildContext context) =>
      of(context) == ScreenSize.expanded;

  /// Grid delegate for card grids. Compact returns [mobile] unchanged;
  /// wider web windows get more columns with the same card proportions.
  static SliverGridDelegate gridDelegate(
    BuildContext context, {
    required SliverGridDelegateWithFixedCrossAxisCount mobile,
    int mediumColumns = 3,
    int expandedColumns = 4,
  }) {
    switch (of(context)) {
      case ScreenSize.compact:
        return mobile;
      case ScreenSize.medium:
        return SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: mediumColumns,
          crossAxisSpacing: mobile.crossAxisSpacing,
          mainAxisSpacing: mobile.mainAxisSpacing,
          childAspectRatio: mobile.childAspectRatio,
        );
      case ScreenSize.expanded:
        return SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: expandedColumns,
          crossAxisSpacing: mobile.crossAxisSpacing + 6,
          mainAxisSpacing: mobile.mainAxisSpacing + 6,
          childAspectRatio: mobile.childAspectRatio,
        );
    }
  }
}

/// Two side-by-side panes on expanded web windows; on everything else
/// (including the mobile app) it returns [compact] untouched.
class ResponsiveTwoPane extends StatelessWidget {
  final Widget compact;
  final Widget start;
  final Widget end;
  final int startFlex;
  final int endFlex;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveTwoPane({
    super.key,
    required this.compact,
    required this.start,
    required this.end,
    this.startFlex = 1,
    this.endFlex = 1,
    this.gap = 48,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isExpanded(context)) return compact;

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(flex: startFlex, child: start),
        SizedBox(width: gap),
        Expanded(flex: endFlex, child: end),
      ],
    );
  }
}

/// Caps the width of [child] on medium/expanded web windows (e.g. a form
/// or a full-width button that would otherwise stretch across a monitor).
/// On compact it's just the child.
class WebMaxWidth extends StatelessWidget {
  final double maxWidth;
  final AlignmentGeometry alignment;
  final Widget child;

  const WebMaxWidth({
    super.key,
    required this.maxWidth,
    this.alignment = Alignment.topLeft,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isCompact(context)) return child;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A poster-shaped (2:3) box that never grows taller than [maxHeight] on
/// wide web windows, so a full-width poster doesn't become 2000px tall.
/// On compact it's just the child.
class WebMaxHeight extends StatelessWidget {
  final double maxHeight;
  final Widget child;

  const WebMaxHeight({super.key, required this.maxHeight, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isCompact(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: child,
      ),
    );
  }
}
