import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_shadows.dart';
import '../typography/app_typography.dart';

/// Central theme configuration for the application
class AppTheme {
  AppTheme._();

  // Color aliases for backward-compatibility
  static const Color primaryColor = AppColors.primaryColor;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color secondaryColor = AppColors.secondaryColor;
  static const Color secondaryLight = AppColors.secondaryLight;
  static const Color giveColor = AppColors.giveColor;
  static const Color giveLight = AppColors.giveLight;
  static const Color giveDark = AppColors.giveDark;
  static const Color gotColor = AppColors.gotColor;
  static const Color gotLight = AppColors.gotLight;
  static const Color gotDark = AppColors.gotDark;
  static const Color warningColor = AppColors.warningColor;
  static const Color warningLight = AppColors.warningLight;
  static const Color infoColor = AppColors.infoColor;
  static const Color infoLight = AppColors.infoLight;
  static const Color errorColor = AppColors.errorColor;
  static const Color successColor = AppColors.successColor;

  static const Color backgroundColor = AppColors.backgroundColor;
  static const Color surfaceColor = AppColors.surfaceColor;
  static const Color cardColor = AppColors.cardColor;
  static const Color borderLight = AppColors.borderLight;
  static const Color textPrimaryLight = AppColors.textPrimaryLight;
  static const Color textSecondaryLight = AppColors.textSecondaryLight;
  static const Color textMutedLight = AppColors.textMutedLight;
  static const Color dividerLight = AppColors.dividerLight;

  static const Color darkBackgroundColor = AppColors.darkBackgroundColor;
  static const Color darkSurfaceColor = AppColors.darkSurfaceColor;
  static const Color darkCardColor = AppColors.darkCardColor;
  static const Color darkPrimaryColor = AppColors.darkPrimaryColor;
  static const Color borderDark = AppColors.borderDark;
  static const Color textPrimaryDark = AppColors.textPrimaryDark;
  static const Color textSecondaryDark = AppColors.textSecondaryDark;
  static const Color textMutedDark = AppColors.textMutedDark;
  static const Color dividerDark = AppColors.dividerDark;

  // Gradients
  static const LinearGradient primaryGradient = AppColors.primaryGradient;
  static const LinearGradient giveGradient = AppColors.giveGradient;
  static const LinearGradient gotGradient = AppColors.gotGradient;
  static const LinearGradient heroGradient = AppColors.heroGradient;
  static const LinearGradient darkCardGradient = AppColors.darkCardGradient;

  // Shadows
  static List<BoxShadow> get subtleShadow => AppShadows.subtle(false);
  static List<BoxShadow> get cardShadow => AppShadows.card(false);
  static List<BoxShadow> get elevatedShadow => AppShadows.elevated(false);
  static List<BoxShadow> primaryGlow([double opacity = 0.25]) =>
      AppShadows.primaryGlow(opacity);
  static List<BoxShadow> giveGlow([double opacity = 0.25]) =>
      AppShadows.giveGlow(opacity);
  static List<BoxShadow> gotGlow([double opacity = 0.25]) =>
      AppShadows.gotGlow(opacity);

  // Dynamic context helpers
  static bool isDark(BuildContext context) => AppColors.isDark(context);
  static Color cardBg(BuildContext context) => AppColors.cardBg(context);
  static Color surfaceBg(BuildContext context) => AppColors.surfaceBg(context);
  static Color borderCol(BuildContext context) => AppColors.borderCol(context);
  static Color textPrimary(BuildContext context) => AppColors.textPrimary(context);
  static Color textSecondary(BuildContext context) => AppColors.textSecondary(context);

  // ThemeData - Light
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimaryLight,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: backgroundColor,
      surfaceContainer: const Color(0xFFF1F5F9),
      error: errorColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: AppTypography.fontFamily,
          bodyColor: textPrimaryLight,
          displayColor: textPrimaryLight,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: textPrimaryLight,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight, size: 22),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderLight, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: borderLight, width: 1.2),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: textSecondaryLight,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: textMutedLight,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor, width: 1.8),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      splashColor: Colors.white24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimaryLight,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // ThemeData - Dark
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      onPrimary: const Color(0xFF0B0F19),
      secondary: secondaryLight,
      onSecondary: Colors.black,
      surface: darkSurfaceColor,
      onSurface: textPrimaryDark,
      surfaceContainerLowest: const Color(0xFF0B0F19),
      surfaceContainerLow: darkSurfaceColor,
      surfaceContainer: darkCardColor,
      error: errorColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: AppTypography.fontFamily,
          bodyColor: textPrimaryDark,
          displayColor: textPrimaryDark,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: textPrimaryDark, size: 22),
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPrimaryColor,
        side: const BorderSide(color: borderDark, width: 1.2),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimaryColor,
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: textSecondaryDark,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: textMutedDark,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor, width: 1.8),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      splashColor: Colors.white24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkCardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardColor,
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

