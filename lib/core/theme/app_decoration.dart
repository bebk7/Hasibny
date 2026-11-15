import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_shadows.dart';
import '../dimensions/app_radius.dart';

/// Central reusable BoxDecoration presets for cards, dialogs, inputs, and badges
class AppDecoration {
  AppDecoration._();

  static BoxDecoration card(
    BuildContext context, {
    Color? color,
    Border? border,
    Color? borderColor,
    double borderWidth = 1.0,
    double? borderRadius,
    List<BoxShadow>? shadows,
    Gradient? gradient,
  }) {
    final isDark = AppColors.isDark(context);
    final radius = borderRadius ?? AppRadius.card(context);
    final bg = color ?? AppColors.cardBg(context);
    final borderCol = borderColor ?? AppColors.borderCol(context);

    return BoxDecoration(
      color: gradient == null ? bg : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: border ??
          Border.all(
            color: borderCol,
            width: borderWidth,
          ),
      boxShadow: shadows ?? AppShadows.card(isDark),
    );
  }

  static BoxDecoration badge(
    BuildContext context, {
    required Color color,
    double? radius,
  }) {
    final isDark = AppColors.isDark(context);
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.22 : 0.12),
      borderRadius: BorderRadius.circular(radius ?? AppRadius.xs),
      border: Border.all(
        color: color.withValues(alpha: isDark ? 0.35 : 0.20),
        width: 1.0,
      ),
    );
  }

  static BoxDecoration dialog(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return BoxDecoration(
      color: AppColors.cardBg(context),
      borderRadius: BorderRadius.circular(AppRadius.dialog(context)),
      boxShadow: AppShadows.elevated(isDark),
    );
  }

  static BoxDecoration bottomSheet(BuildContext context) {
    return BoxDecoration(
      color: AppColors.surfaceBg(context),
      borderRadius: AppRadius.bottomSheetRadius(context),
    );
  }
}

