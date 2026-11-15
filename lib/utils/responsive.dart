import 'package:flutter/material.dart';
import '../core/core.dart';
export '../core/core.dart';

/// Backward-compatible proxy to AppResponsive and AppScreenInfo
class Responsive {
  Responsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isExtraSmall(BuildContext context) =>
      AppScreenInfo.fromContext(context).isExtraCompact;

  static bool isSmall(BuildContext context) =>
      AppScreenInfo.fromContext(context).isSmall;

  static bool isMedium(BuildContext context) =>
      AppScreenInfo.fromContext(context).isStandard;

  static bool isTablet(BuildContext context) =>
      AppScreenInfo.fromContext(context).isTablet;

  static bool isDesktop(BuildContext context) =>
      AppScreenInfo.fromContext(context).isDesktop;

  static bool isLarge(BuildContext context) =>
      AppScreenInfo.fromContext(context).isLarge;

  static bool isLandscape(BuildContext context) =>
      AppScreenInfo.fromContext(context).isLandscape;

  static bool isShort(BuildContext context) =>
      AppScreenInfo.fromContext(context).isShort;

  static bool isRtl(BuildContext context) =>
      AppScreenInfo.fromContext(context).isRtl;

  static IconData forwardIcon(BuildContext context) =>
      AppScreenInfo.fromContext(context).forwardIcon;

  static IconData backIcon(BuildContext context) =>
      AppScreenInfo.fromContext(context).backIcon;

  static double textScale(BuildContext context) =>
      AppScreenInfo.fromContext(context).textScaleFactor;

  static double safeBottom(BuildContext context) =>
      AppScreenInfo.fromContext(context).safeBottom;

  static double safeTop(BuildContext context) =>
      AppScreenInfo.fromContext(context).safeTop;

  static double safeLeft(BuildContext context) =>
      AppScreenInfo.fromContext(context).safeLeft;

  static double safeRight(BuildContext context) =>
      AppScreenInfo.fromContext(context).safeRight;

  static double keyboardInset(BuildContext context) =>
      AppScreenInfo.fromContext(context).keyboardInset;

  static bool isKeyboardOpen(BuildContext context) =>
      AppScreenInfo.fromContext(context).isKeyboardOpen;

  static double bottomPaddingWithSafe(BuildContext context,
          [double additional = 16]) =>
      additional + safeBottom(context);

  static double sp(BuildContext context, double size) {
    final w = width(context);
    if (w < 340) return size * 0.85;
    if (w < 360) return size * 0.90;
    if (w < 600) return size;
    return size * 1.10;
  }

  static double responsiveFontSize(
    BuildContext context,
    double baseSize, {
    double? min,
    double? max,
  }) {
    final scale = textScale(context);
    final widthFactor =
        width(context) < 340 ? 0.85 : (width(context) < 360 ? 0.92 : 1.0);
    final calculated = baseSize * widthFactor * scale;
    final minBound = min ?? (baseSize * 0.78);
    final maxBound = max ?? (baseSize * 1.25);
    return calculated.clamp(minBound, maxBound);
  }

  static double hp(BuildContext context, double percent) =>
      height(context) * percent;

  static double wp(BuildContext context, double percent) =>
      width(context) * percent;

  static const double maxContentWidth = AppBreakpoints.maxContentWidth;
  static const double maxDialogWidth = AppBreakpoints.maxDialogWidth;

  static EdgeInsets pagePadding(
    BuildContext context, {
    bool includeBottomSafe = true,
    double additionalBottom = 0,
  }) =>
      AppSpacing.page(
        context,
        includeBottomSafe: includeBottomSafe,
        additionalBottom: additionalBottom,
      );

  static EdgeInsets tabPadding(BuildContext context) =>
      AppSpacing.tab(context);

  static BoxConstraints dialogConstraints(BuildContext context) =>
      AppComponentSizes.dialogConstraints(context);

  static int gridColumns(BuildContext context, {double minItemWidth = 170}) {
    final w = width(context);
    final count = (w / minItemWidth).floor();
    return count.clamp(1, 4);
  }

  static double cardRadius(BuildContext context) =>
      AppRadius.card(context);

  static double avatarRadius(BuildContext context) =>
      AppComponentSizes.avatarRadius(context);

  static double iconSize(BuildContext context) =>
      AppIconSizes.standard(context);

  static double fabSize(BuildContext context) =>
      AppComponentSizes.fabSize(context);

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? extraSmall,
    T? small,
    T? tablet,
    T? desktop,
  }) {
    final w = width(context);
    if (w >= AppBreakpoints.large && desktop != null) return desktop;
    if (w >= AppBreakpoints.standard && tablet != null) return tablet;
    if (w < AppBreakpoints.extraCompact && extraSmall != null) return extraSmall;
    if (w < AppBreakpoints.compact && small != null) return small;
    return mobile;
  }
}
