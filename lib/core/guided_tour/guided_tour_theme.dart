import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../dimensions/app_radius.dart';

/// Styling configurations for the Elite Guided Tour System.
class GuidedTourTheme {
  const GuidedTourTheme._();

  // Glassmorphic Card Styling
  static const double cardBlurSigma = 12.0;
  static const double cardRadius = AppRadius.lg; // 16.0
  static const double cardBorderWidth = 1.2;

  // Colors - Adaptive Glass
  static Color cardBackground(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return isDark
        ? const Color(0xEE0F172A) // Rich deep slate with high opacity
        : const Color(0xFA1E293B); // Sleek dark surface in light mode for max contrast & focus
  }

  static Color cardBorderColor(BuildContext context) {
    return Colors.white.withValues(alpha: 0.16);
  }

  static List<BoxShadow> cardShadows(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 28,
        spreadRadius: -2,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: AppColors.primaryColor.withValues(alpha: 0.18),
        blurRadius: 16,
        spreadRadius: -4,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Spotlight Styling
  static const double defaultSpotlightRadius = 14.0;
  static const EdgeInsets defaultSpotlightPadding = EdgeInsets.all(8.0);
  static const double defaultOverlayOpacity = 0.65;
  static const double defaultOverlayBlur = 1.5;

  static Color spotlightGlowColor(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
  }

  // Header & Icon Badges
  static const double iconBadgeSize = 38.0;
  static const double iconBadgeRadius = 10.0;

  static BoxDecoration iconBadgeDecoration(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primary = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    return BoxDecoration(
      color: primary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(iconBadgeRadius),
      border: Border.all(
        color: primary.withValues(alpha: 0.4),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Step Counter Badge
  static BoxDecoration stepBadgeDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.full),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1,
      ),
    );
  }

  // Progress Bar
  static const double progressBarHeight = 4.0;
  static Color progressBarTrackColor = Colors.white.withValues(alpha: 0.1);
  static LinearGradient progressBarGradient(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primary = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    return LinearGradient(
      colors: [
        primary,
        primary.withValues(alpha: 0.85),
        const Color(0xFF10B981), // Emerald accent highlight
      ],
    );
  }

  // Buttons
  static ButtonStyle nextButtonStyle(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primary = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 3,
      shadowColor: primary.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(0, 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static ButtonStyle prevButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white.withValues(alpha: 0.85),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: const Size(0, 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static ButtonStyle skipButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: Colors.white.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      minimumSize: const Size(0, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
