import 'package:flutter/material.dart';
import '../responsive/app_screen_info.dart';
import '../responsive/app_scaling.dart';
import '../theme/app_text_styles.dart';

/// Central typography system tailored for the Arabic & English 'Cairo' font
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo';

  // Base Font Sizes (Refined and slightly reduced for optimal readability and zero overflow)
  static const double sizeDisplay = 26.0;
  static const double sizeHeading1 = 21.0;
  static const double sizeHeading2 = 17.5;
  static const double sizeHeading3 = 15.0;
  static const double sizeBodyLarge = 14.0;
  static const double sizeBody = 13.5;
  static const double sizeBodySmall = 12.0;
  static const double sizeCaption = 11.0;
  static const double sizeTiny = 9.5;

  // Responsive dynamic font size calculators
  static double responsive(
    BuildContext context,
    double baseSize, {
    double? min,
    double? max,
  }) {
    final info = AppScreenInfo.fromContext(context);
    return AppScaling.scaleFont(
      baseSize,
      widthFactor: info.widthFactor,
      textScaleFactor: info.textScaleFactor,
      min: min,
      max: max,
    );
  }

  static double display(BuildContext context) =>
      responsive(context, sizeDisplay, min: 21, max: 32);

  static double heading1(BuildContext context) =>
      responsive(context, sizeHeading1, min: 18.0, max: 25);

  static double heading2(BuildContext context) =>
      responsive(context, sizeHeading2, min: 15.0, max: 21);

  static double heading3(BuildContext context) =>
      responsive(context, sizeHeading3, min: 13.0, max: 18);

  static double bodyLarge(BuildContext context) =>
      responsive(context, sizeBodyLarge, min: 12.5, max: 17);

  static double body(BuildContext context) =>
      responsive(context, sizeBody, min: 12.0, max: 16);

  static double bodySmall(BuildContext context) =>
      responsive(context, sizeBodySmall, min: 11.0, max: 14.5);

  static double captionSize(BuildContext context) =>
      responsive(context, sizeCaption, min: 9.5, max: 12.5);

  static double tiny(BuildContext context) =>
      responsive(context, sizeTiny, min: 8.5, max: 11.5);

  // Ergonomic static TextStyle helpers forwarding to AppTextStyles
  static TextStyle pageTitle(BuildContext context, {Color? color}) =>
      AppTextStyles.pageTitle(context, color: color);

  static TextStyle sectionTitle(BuildContext context, {Color? color}) =>
      AppTextStyles.sectionTitle(context, color: color);

  static TextStyle cardTitle(BuildContext context, {Color? color}) =>
      AppTextStyles.cardTitle(context, color: color);

  static TextStyle bodyStyle(BuildContext context, {Color? color, FontWeight? fontWeight}) =>
      AppTextStyles.body(context, color: color, fontWeight: fontWeight);

  static TextStyle caption(BuildContext context, {Color? color}) =>
      AppTextStyles.caption(context, color: color);
}

