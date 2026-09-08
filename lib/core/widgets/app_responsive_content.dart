import 'package:flutter/material.dart';

/// Centers content and applies consistent responsive page spacing.
class AppResponsiveContent extends StatelessWidget {
  const AppResponsiveContent({
    super.key,
    required this.child,
    this.maximumContentWidth = 760,
    this.compactHorizontalPadding = 16,
    this.wideHorizontalPadding = 24,
    this.wideBreakpoint = 700,
    this.topPadding = 0,
    this.bottomPadding = 0,
  });

  final Widget child;
  final double maximumContentWidth;
  final double compactHorizontalPadding;
  final double wideHorizontalPadding;
  final double wideBreakpoint;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= wideBreakpoint
        ? wideHorizontalPadding
        : compactHorizontalPadding;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maximumContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
