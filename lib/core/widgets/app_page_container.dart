import 'package:flutter/material.dart';
import '../responsive/app_breakpoints.dart';
import '../dimensions/app_spacing.dart';

/// Central responsive page wrapper that centers content on wide screens
/// and applies adaptive padding with safe insets
class AppPageContainer extends StatelessWidget {
  final Widget child;
  final bool isScrollable;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool includeBottomSafe;
  final double additionalBottom;

  const AppPageContainer({
    super.key,
    required this.child,
    this.isScrollable = false,
    this.physics,
    this.padding,
    this.maxWidth,
    this.includeBottomSafe = true,
    this.additionalBottom = 0,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        AppSpacing.page(
          context,
          includeBottomSafe: includeBottomSafe,
          additionalBottom: additionalBottom,
        );

    final constrainedChild = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.maxContentWidth,
        ),
        child: child,
      ),
    );

    if (isScrollable) {
      return SingleChildScrollView(
        physics: physics ??
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
        padding: effectivePadding,
        child: constrainedChild,
      );
    }

    return Padding(
      padding: effectivePadding,
      child: constrainedChild,
    );
  }
}
