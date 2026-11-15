import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../typography/app_typography.dart';

/// Central text styles with responsive font sizing and theme color adaptation
class AppTextStyles {
  AppTextStyles._();

  static TextStyle pageTitle(BuildContext context, {Color? color}) {
    final isDark = AppColors.isDark(context);
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.heading1(context),
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
    );
  }

  static TextStyle sectionTitle(BuildContext context, {Color? color}) {
    final isDark = AppColors.isDark(context);
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.heading2(context),
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
    );
  }

  static TextStyle cardTitle(BuildContext context, {Color? color}) {
    final isDark = AppColors.isDark(context);
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.heading3(context),
      fontWeight: FontWeight.w700,
      color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
    );
  }

  static TextStyle body(BuildContext context, {Color? color, FontWeight? fontWeight}) {
    final isDark = AppColors.isDark(context);
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.body(context),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
    );
  }

  static TextStyle secondary(BuildContext context, {Color? color}) {
    final isDark = AppColors.isDark(context);
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.bodySmall(context),
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
    );
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    final isDark = AppColors.isDark(context);
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.captionSize(context),
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
    );
  }

  static TextStyle amount(
    BuildContext context, {
    required Color color,
    double? fontSize,
    FontWeight fontWeight = FontWeight.w900,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize ?? AppTypography.heading2(context),
      fontWeight: fontWeight,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle button(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.body(context),
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color ?? Colors.white,
    );
  }
}

