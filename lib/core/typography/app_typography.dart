import 'package:flutter/material.dart';
import '../responsive/app_screen_info.dart';
import '../responsive/app_scaling.dart';
import '../theme/app_text_styles.dart';

/// Central typography system tailored for the Arabic & English 'Cairo' font
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo';

  // Base Font Sizes
  static const double sizeDisplay = 28.0;
  static const double sizeHeading1 = 22.0;
  static const double sizeHeading2 = 18.0;
  static const double sizeHeading3 = 16.0;
  static const double sizeBodyLarge = 15.0;
  static const double sizeBody = 14.0;
  static const double sizeBodySmall = 13.0;
  static const double sizeCaption = 11.0;
  static const double sizeTiny = 10.0;

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
      responsive(context, sizeDisplay, min: 22, max: 34);

  static double heading1(BuildContext context) =>
      responsive(context, sizeHeading1, min: 18, max: 26);

  static double heading2(BuildContext context) =>
      responsive(context, sizeHeading2, min: 15, max: 22);

  static double heading3(BuildContext context) =>
      responsive(context, sizeHeading3, min: 14, max: 19);

  static double bodyLarge(BuildContext context) =>
      responsive(context, sizeBodyLarge, min: 13, max: 18);

  static double body(BuildContext context) =>
      responsive(context, sizeBody, min: 12, max: 17);

  static double bodySmall(BuildContext context) =>
      responsive(context, sizeBodySmall, min: 11, max: 15);

  static double captionSize(BuildContext context) =>
      responsive(context, sizeCaption, min: 9.5, max: 13);

  static double tiny(BuildContext context) =>
      responsive(context, sizeTiny, min: 9, max: 12);

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

