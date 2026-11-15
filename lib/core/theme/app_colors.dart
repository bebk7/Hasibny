import 'package:flutter/material.dart';

/// Central application palette, semantic tokens, and brand gradients
class AppColors {
  AppColors._();

  // Brand & Semantic Colors
  static const Color primaryColor = Color(0xFF2563EB); // Royal Electric Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);

  static const Color secondaryColor = Color(0xFF0D9488); // Modern Teal
  static const Color secondaryLight = Color(0xFF14B8A6);

  static const Color giveColor = Color(0xFFEF4444); // Crimson Coral (Debit/Outflow)
  static const Color giveLight = Color(0xFFFEE2E2);
  static const Color giveDark = Color(0xFFDC2626);

  static const Color gotColor = Color(0xFF10B981); // Emerald Mint (Credit/Inflow)
  static const Color gotLight = Color(0xFFD1FAE5);
  static const Color gotDark = Color(0xFF059669);

  static const Color warningColor = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color infoColor = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  // Surface & Neutral Colors - Light Mode
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400
  static const Color dividerLight = Color(0xFFF1F5F9); // Slate 100

  // Surface & Neutral Colors - Dark Mode
  static const Color darkBackgroundColor = Color(0xFF0B0F19); // Deep Slate Navy
  static const Color darkSurfaceColor = Color(0xFF111827); // Deep Gray 900
  static const Color darkCardColor = Color(0xFF1E293B); // Slate 800
  static const Color darkPrimaryColor = Color(0xFF60A5FA); // Soft Blue 400
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500
  static const Color dividerDark = Color(0xFF1F2937); // Gray 800

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient giveGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gotGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic Context Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color cardBg(BuildContext context) =>
      isDark(context) ? darkCardColor : cardColor;

  static Color surfaceBg(BuildContext context) =>
      isDark(context) ? darkSurfaceColor : surfaceColor;

  static Color borderCol(BuildContext context) =>
      isDark(context) ? borderDark : borderLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? textMutedDark : textMutedLight;

  static Color primaryOf(BuildContext context) =>
      isDark(context) ? darkPrimaryColor : primaryColor;

  // Shorthand static color aliases for design system ergonomics
  static const Color primary = primaryColor;
  static const Color secondary = secondaryColor;
  static const Color give = giveColor;
  static const Color got = gotColor;
  static const Color warning = warningColor;
  static const Color info = infoColor;
  static const Color error = errorColor;
  static const Color success = successColor;
  static const Color background = backgroundColor;
  static const Color surface = surfaceColor;
  static const Color card = cardColor;
  static const Color darkCard = darkCardColor;
  static const Color darkPrimary = darkPrimaryColor;
  static const Color darkBackground = darkBackgroundColor;
  static const Color darkSurface = darkSurfaceColor;
}

