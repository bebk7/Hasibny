import 'package:flutter/material.dart';
import '../responsive/app_screen_info.dart';

/// Central border radius design tokens and responsive corner radius calculators
class AppRadius {
  AppRadius._();

  // Static standard radius tokens
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double full = 999.0;

  // Responsive dynamic corner radius
  static double card(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 10.0;
    if (info.isCompact || info.isStandard) return 14.0;
    return 18.0;
  }

  static double button(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 10.0;
    if (info.isCompact) return 12.0;
    return 14.0;
  }

  static double input(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 10.0;
    return 14.0;
  }

  static double dialog(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 18.0;
    return 22.0;
  }

  static double bottomSheet(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 20.0;
    return 24.0;
  }

  static double chip(BuildContext context) {
    return 10.0;
  }

  // Pre-built BorderRadius objects
  static BorderRadius cardRadius(BuildContext context) =>
      BorderRadius.circular(card(context));

  static BorderRadius buttonRadius(BuildContext context) =>
      BorderRadius.circular(button(context));

  static BorderRadius inputRadius(BuildContext context) =>
      BorderRadius.circular(input(context));

  static BorderRadius dialogRadius(BuildContext context) =>
      BorderRadius.circular(dialog(context));

  static BorderRadius bottomSheetRadius(BuildContext context) =>
      BorderRadius.vertical(top: Radius.circular(bottomSheet(context)));
}

