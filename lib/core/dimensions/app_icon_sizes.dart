import 'package:flutter/material.dart';
import '../responsive/app_screen_info.dart';

/// Central icon size tokens and dynamic responsive sizing
class AppIconSizes {
  AppIconSizes._();

  // Static standard icon size tokens
  static const double xs = 14.0;
  static const double sm = 18.0;
  static const double md = 22.0;
  static const double lg = 28.0;
  static const double xl = 36.0;
  static const double xxl = 48.0;

  // Context-aware responsive icon size (matches Responsive.iconSize for backwards-compatibility)
  static double standard(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 18.0;
    if (info.isCompact) return 20.0;
    if (info.isStandard) return 24.0;
    return 26.0;
  }

  static double small(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 14.0;
    if (info.isCompact) return 16.0;
    return 18.0;
  }

  static double extraSmall(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 12.0;
    return 14.0;
  }

  static double large(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 24.0;
    if (info.isCompact) return 28.0;
    return 32.0;
  }

  static double extraLarge(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 28.0;
    if (info.isCompact) return 32.0;
    return 36.0;
  }
}

