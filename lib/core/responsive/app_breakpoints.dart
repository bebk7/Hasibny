/// Device breakpoint thresholds and device category classification
class AppBreakpoints {
  AppBreakpoints._();

  /// Devices with width < 340 (e.g. iPhone SE 1st gen, tiny feature phones)
  static const double extraCompact = 340.0;

  /// Devices with width < 360 (small Android phones)
  static const double compact = 360.0;

  /// Standard phone breakpoint upper limit (under 600dp)
  static const double standard = 600.0;

  /// Medium screens / Tablets portrait / Large foldables (600 - 899dp)
  static const double medium = 600.0;

  /// Large screens / Tablets landscape / Small desktop (900 - 1199dp)
  static const double large = 900.0;

  /// Expanded screens / Desktop / Wide screens (>= 1200dp)
  static const double expanded = 1200.0;

  /// Max content width for readability on wide screens
  static const double maxContentWidth = 680.0;

  /// Max dialog width for tablet and desktop
  static const double maxDialogWidth = 460.0;

  /// Max form container width
  static const double maxFormWidth = 540.0;

  /// Max card width
  static const double maxCardWidth = 600.0;
}

/// Device classification categories based on viewport width
enum DeviceScreenType {
  extraCompact,
  compact,
  standard,
  tablet,
  desktop,
  expanded,
}
