import 'package:flutter/material.dart';
import '../responsive/app_screen_info.dart';
import '../responsive/app_breakpoints.dart';

/// Central spacing design tokens and dynamic responsive spacing calculations
class AppSpacing {
  AppSpacing._();

  // Static Standard Spacing Tokens
  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 40.0;
  static const double space3xl = 48.0;

  // Backward-compatible dynamic responsive tokens
  static double xs(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 4.0 : 6.0;
  }

  static double sm(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 8.0 : 10.0;
  }

  static double md(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 12.0 : 16.0;
  }

  static double lg(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 18.0 : 24.0;
  }

  static double xl(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 24.0 : 32.0;
  }

  /// Adaptive page padding that clamps on wide screens and respects safe areas
  static EdgeInsets page(
    BuildContext context, {
    bool includeBottomSafe = true,
    double additionalBottom = 0,
  }) {
    final info = AppScreenInfo.fromContext(context);
    final w = info.screenWidth;
    final safeB = includeBottomSafe ? info.safeBottom : 0.0;
    final baseBottom = info.isExtraCompact
        ? 12.0
        : (info.isCompact ? 14.0 : (info.isStandard ? 16.0 : 24.0));
    final totalBottom = baseBottom + safeB + additionalBottom;

    if (info.isExtraCompact) {
      return EdgeInsets.only(
        left: 10,
        right: 10,
        top: 12,
        bottom: totalBottom,
      );
    }
    if (info.isCompact) {
      return EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: totalBottom,
      );
    }
    if (info.isStandard) {
      return EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: totalBottom,
      );
    }

    // Tablet & Desktop layout: center content with symmetric margins
    final horizontalPadding =
        ((w - AppBreakpoints.maxContentWidth) / 2).clamp(24.0, 160.0);
    return EdgeInsets.only(
      left: horizontalPadding,
      right: horizontalPadding,
      top: 20,
      bottom: totalBottom,
    );
  }

  /// Tab bar padding with extra bottom clearance for the docked FAB
  static EdgeInsets tab(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return page(
      context,
      includeBottomSafe: true,
      additionalBottom: info.isSmall ? 72.0 : 80.0,
    );
  }

  /// Card internal padding
  static EdgeInsets card(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return const EdgeInsets.all(10);
    if (info.isCompact) return const EdgeInsets.all(12);
    return const EdgeInsets.all(16);
  }

  /// Dialog internal padding
  static EdgeInsets dialog(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return const EdgeInsets.all(16);
    if (info.isCompact) return const EdgeInsets.all(18);
    return const EdgeInsets.all(22);
  }
}

