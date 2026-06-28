import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600
  static const Color secondaryColor = Color(0xFF10B981); // Emerald 500
  static const Color giveColor = Color(0xFFEF4444); // Red 500
  static const Color gotColor = Color(0xFF10B981); // Emerald 500
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  static const Color darkBackgroundColor = Color(0xFF0F172A); // Slate 900
  static const Color darkSurfaceColor = Color(0xFF1E293B); // Slate 800
  static const Color darkPrimaryColor = Color(0xFF818CF8); // Indigo 400

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    // تطبيق خط Cairo للثيم الفاتح
    fontFamily: 'Cairo',
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Cairo'),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9), // Slate 100
      labelStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF64748B)),
      hintStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF757575),
      selectedLabelStyle:
          TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      secondary: secondaryColor,
      surface: darkSurfaceColor,
      error: errorColor,
    ),
    // تطبيق خط Cairo للثيم المظلم
    fontFamily: 'Cairo',
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Cairo'),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155), width: 1), // Slate 700
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor,
        textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F172A), // Slate 900
      labelStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF64748B)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkPrimaryColor,
      foregroundColor: darkBackgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: darkPrimaryColor,
      unselectedItemColor: Color(0xFF9E9E9E),
      selectedLabelStyle:
          TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
