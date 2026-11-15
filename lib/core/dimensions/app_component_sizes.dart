import 'package:flutter/material.dart';
import '../responsive/app_screen_info.dart';
import '../responsive/app_breakpoints.dart';

/// Central component sizes for buttons, inputs, avatars, dialogs, and navigation
class AppComponentSizes {
  AppComponentSizes._();

  /// Accessible button height
  static double buttonHeight(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 48.0 : 52.0;
  }

  /// Text field height
  static double inputHeight(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return info.isSmall ? 48.0 : 52.0;
  }

  /// Avatar radius (backward-compatible with Responsive.avatarRadius)
  static double avatarRadius(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 22.0;
    if (info.isCompact) return 28.0;
    if (info.isStandard) return 36.0;
    return 40.0;
  }

  /// Floating Action Button size (backward-compatible with Responsive.fabSize)
  static double fabSize(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    if (info.isExtraCompact) return 48.0;
    if (info.isCompact) return 50.0;
    return 56.0;
  }

  /// Dialog constraints adapting to screen size
  static BoxConstraints dialogConstraints(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    final maxW = (info.screenWidth - 32.0).clamp(280.0, AppBreakpoints.maxDialogWidth);
    final maxH = info.screenHeight * 0.85;
    return BoxConstraints(
      maxWidth: maxW,
      maxHeight: maxH,
    );
  }

  /// Bottom sheet maximum height constraint
  static BoxConstraints bottomSheetConstraints(BuildContext context) {
    final info = AppScreenInfo.fromContext(context);
    return BoxConstraints(
      maxWidth: AppBreakpoints.maxContentWidth,
      maxHeight: info.screenHeight * 0.90,
    );
  }

  /// Bottom sheet drag handle
  static const Size dragHandleSize = Size(40.0, 4.0);
}

