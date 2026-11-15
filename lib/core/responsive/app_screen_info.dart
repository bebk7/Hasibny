import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

/// Comprehensive snapshot of the device screen, safe areas, insets, and orientation
class AppScreenInfo {
  final Size screenSize;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;
  final Orientation orientation;
  final double textScaleFactor;
  final TextDirection textDirection;

  const AppScreenInfo({
    required this.screenSize,
    required this.padding,
    required this.viewInsets,
    required this.orientation,
    required this.textScaleFactor,
    required this.textDirection,
  });

  factory AppScreenInfo.fromContext(BuildContext context) {
    return AppScreenInfo(
      screenSize: MediaQuery.sizeOf(context),
      padding: MediaQuery.paddingOf(context),
      viewInsets: MediaQuery.viewInsetsOf(context),
      orientation: MediaQuery.orientationOf(context),
      textScaleFactor: MediaQuery.textScalerOf(context).scale(1.0),
      textDirection: Directionality.of(context),
    );
  }

  // Screen Dimensions
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Available space excluding system safe areas and view insets
  double get availableWidth =>
      (screenWidth - padding.left - padding.right).clamp(0.0, double.infinity);
  double get availableHeight => (screenHeight -
          padding.top -
          padding.bottom -
          viewInsets.top -
          viewInsets.bottom)
      .clamp(0.0, double.infinity);

  // Safe area insets
  double get safeTop => padding.top;
  double get safeBottom => padding.bottom;
  double get safeLeft => padding.left;
  double get safeRight => padding.right;

  // Keyboard insets
  double get keyboardInset => viewInsets.bottom;
  bool get isKeyboardOpen => viewInsets.bottom > 0;

  // Orientation
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isShort => screenHeight < 600.0;

  // Device Classification
  DeviceScreenType get deviceType {
    if (screenWidth < AppBreakpoints.extraCompact) {
      return DeviceScreenType.extraCompact;
    }
    if (screenWidth < AppBreakpoints.compact) {
      return DeviceScreenType.compact;
    }
    if (screenWidth < AppBreakpoints.standard) {
      return DeviceScreenType.standard;
    }
    if (screenWidth < AppBreakpoints.large) {
      return DeviceScreenType.tablet;
    }
    if (screenWidth < AppBreakpoints.expanded) {
      return DeviceScreenType.desktop;
    }
    return DeviceScreenType.expanded;
  }

  bool get isExtraCompact => screenWidth < AppBreakpoints.extraCompact;
  bool get isCompact => screenWidth < AppBreakpoints.compact;
  bool get isSmall => screenWidth < AppBreakpoints.compact;
  bool get isStandard =>
      screenWidth >= AppBreakpoints.compact &&
      screenWidth < AppBreakpoints.standard;
  bool get isMedium =>
      screenWidth >= AppBreakpoints.compact &&
      screenWidth < AppBreakpoints.standard;
  bool get isTablet =>
      screenWidth >= AppBreakpoints.standard &&
      screenWidth < AppBreakpoints.large;
  bool get isDesktop => screenWidth >= AppBreakpoints.large;
  bool get isExpanded => screenWidth >= AppBreakpoints.expanded;
  bool get isLarge => screenWidth >= AppBreakpoints.standard;

  // RTL & Localization
  bool get isRtl => textDirection == TextDirection.rtl;
  bool get isLtr => textDirection == TextDirection.ltr;

  IconData get forwardIcon =>
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
  IconData get backIcon =>
      isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded;

  // Width factor used for proportional typography scaling
  double get widthFactor {
    if (isExtraCompact) return 0.85;
    if (isCompact) return 0.92;
    if (isTablet) return 1.05;
    if (isDesktop) return 1.10;
    return 1.0;
  }
}

