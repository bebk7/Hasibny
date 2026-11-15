import 'package:flutter/material.dart';
import 'app_breakpoints.dart';
import 'app_screen_info.dart';
import '../dimensions/app_spacing.dart';
import '../dimensions/app_radius.dart';
import '../dimensions/app_icon_sizes.dart';
import '../dimensions/app_component_sizes.dart';
import '../typography/app_typography.dart';

/// Intelligent responsive design engine and context accessor
class AppResponsive {
  final BuildContext context;
  final AppScreenInfo info;

  AppResponsive._(this.context, this.info);

  /// Access the responsive data for the given [BuildContext]
  factory AppResponsive.of(BuildContext context) {
    return AppResponsive._(context, AppScreenInfo.fromContext(context));
  }

  // ── A. Screen Information ──
  double get screenWidth => info.screenWidth;
  double get screenHeight => info.screenHeight;
  double get availableWidth => info.availableWidth;
  double get availableHeight => info.availableHeight;

  bool get isExtraCompact => info.isExtraCompact;
  bool get isCompact => info.isCompact;
  bool get isSmall => info.isSmall;
  bool get isStandard => info.isStandard;
  bool get isMedium => info.isMedium;
  bool get isTablet => info.isTablet;
  bool get isDesktop => info.isDesktop;
  bool get isExpanded => info.isExpanded;
  bool get isLarge => info.isLarge;

  bool get isLandscape => info.isLandscape;
  bool get isPortrait => info.isPortrait;
  bool get isShort => info.isShort;

  bool get isRtl => info.isRtl;
  bool get isLtr => info.isLtr;
  IconData get forwardIcon => info.forwardIcon;
  IconData get backIcon => info.backIcon;

  double get safeTop => info.safeTop;
  double get safeBottom => info.safeBottom;
  double get safeLeft => info.safeLeft;
  double get safeRight => info.safeRight;

  double get keyboardInset => info.keyboardInset;
  bool get isKeyboardOpen => info.isKeyboardOpen;
  double get textScaleFactor => info.textScaleFactor;

  // ── B. Dynamic Spacing ──
  double get spacing2XS => AppSpacing.space2xs;
  double get spacingXS => isSmall ? 4.0 : 6.0;
  double get spacingSM => isSmall ? 8.0 : 10.0;
  double get spacingMD => isSmall ? 12.0 : 16.0;
  double get spacingLG => isSmall ? 18.0 : 24.0;
  double get spacingXL => isSmall ? 24.0 : 32.0;
  double get spacing2XL => isSmall ? 32.0 : 40.0;

  double get pagePadding =>
      isExtraCompact ? 10.0 : (isCompact ? 12.0 : (isStandard ? 16.0 : 24.0));
  EdgeInsets get pageInsets => AppSpacing.page(context);
  EdgeInsets get pagePaddingInsets => AppSpacing.page(context);
  EdgeInsets get tabPadding => AppSpacing.tab(context);
  EdgeInsets get cardPadding => AppSpacing.card(context);
  EdgeInsets get dialogPadding => AppSpacing.dialog(context);

  double get sectionSpacing => isSmall ? 16.0 : 22.0;
  double get cardSpacing => isSmall ? 8.0 : 12.0;
  double get listSpacing => isSmall ? 8.0 : 10.0;
  double get bottomInset => safeBottom;

  // ── C. Dynamic Dimensions ──
  double get cardRadius => AppRadius.card(context);
  double get buttonRadius => AppRadius.button(context);
  double get inputRadius => AppRadius.input(context);
  double get dialogRadius => AppRadius.dialog(context);
  double get bottomSheetRadius => AppRadius.bottomSheet(context);

  double get radiusXS => AppRadius.xs;
  double get radiusSM => AppRadius.sm;
  double get radiusMD => AppRadius.md;
  double get radiusLG => AppRadius.lg;
  double get radiusXL => AppRadius.xl;
  double get radiusFull => AppRadius.full;

  double get buttonHeight => AppComponentSizes.buttonHeight(context);
  double get inputHeight => AppComponentSizes.inputHeight(context);
  double get avatarRadius => AppComponentSizes.avatarRadius(context);
  double get fabSize => AppComponentSizes.fabSize(context);

  double get iconSize => AppIconSizes.standard(context);
  double get smallIconSize => AppIconSizes.small(context);
  double get largeIconSize => AppIconSizes.large(context);

  double get iconXS => AppIconSizes.extraSmall(context);
  double get iconSM => AppIconSizes.small(context);
  double get iconMD => AppIconSizes.standard(context);
  double get iconLG => AppIconSizes.large(context);
  double get iconXL => AppIconSizes.extraLarge(context);

  double get dialogWidth =>
      (screenWidth - 32.0).clamp(280.0, AppBreakpoints.maxDialogWidth);
  double get cardMaxWidth => AppBreakpoints.maxCardWidth;
  double get maxContentWidth => AppBreakpoints.maxContentWidth;

  BoxConstraints get dialogConstraints =>
      AppComponentSizes.dialogConstraints(context);
  BoxConstraints get bottomSheetConstraints =>
      AppComponentSizes.bottomSheetConstraints(context);

  // ── D. Dynamic Typography (Scales safely with min/max bounds) ──
  double get displayTitle => AppTypography.display(context);
  double get pageTitle => AppTypography.heading1(context);
  double get sectionTitle => AppTypography.heading2(context);
  double get cardTitle => AppTypography.heading3(context);
  double get bodyText => AppTypography.body(context);
  double get secondaryText => AppTypography.bodySmall(context);
  double get captionText => AppTypography.captionSize(context);
  double get tinyText => AppTypography.tiny(context);

  double get font2XS => fontSize(10.0, min: 8.5, max: 11.5);
  double get fontXS => fontSize(11.0, min: 9.5, max: 13.0);
  double get fontSM => fontSize(12.0, min: 10.5, max: 14.5);
  double get fontMD => fontSize(14.0, min: 12.0, max: 17.0);
  double get fontLG => fontSize(16.0, min: 14.0, max: 19.0);
  double get fontXL => fontSize(20.0, min: 17.0, max: 24.0);
  double get font2XL => fontSize(24.0, min: 20.0, max: 28.0);
  double get font3XL => fontSize(28.0, min: 24.0, max: 34.0);

  /// Helper to calculate bounded dynamic font size
  double fontSize(double base, {double? min, double? max}) =>
      AppTypography.responsive(context, base, min: min, max: max);

  /// Height percentage of available or screen height
  double hp(double percentage) => screenHeight * percentage;

  /// Width percentage of available or screen width
  double wp(double percentage) => screenWidth * percentage;

  /// Adaptive value selector based on device breakpoint
  T value<T>({
    required T mobile,
    T? extraSmall,
    T? small,
    T? tablet,
    T? desktop,
  }) {
    if (screenWidth >= AppBreakpoints.large && desktop != null) return desktop;
    if (screenWidth >= AppBreakpoints.standard && tablet != null) return tablet;
    if (screenWidth < AppBreakpoints.extraCompact && extraSmall != null) {
      return extraSmall;
    }
    if (screenWidth < AppBreakpoints.compact && small != null) return small;
    return mobile;
  }

  /// Calculates dynamic grid columns based on minimum item width
  int gridColumns({double minItemWidth = 170}) {
    final count = (screenWidth / minItemWidth).floor();
    return count.clamp(1, 4);
  }
}

/// Convenient extension on BuildContext to access AppResponsive anywhere
extension AppResponsiveExtension on BuildContext {
  AppResponsive get responsive => AppResponsive.of(this);
}
