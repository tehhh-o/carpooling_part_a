import 'package:flutter/material.dart';

class AppTheme {
  // Brand palette (clean “green product” feel)
  static const _seed = Color(0xFF2E7D32); // primary seed

  // Spacing tokens
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;

  // Radius tokens
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      // Big titles (screens)
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: cs.onSurface,
      ),
      // Section headers
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: cs.onSurface,
      ),
      // Smaller titles / list titles
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      // Labels (form labels, chips)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      // Body paragraph
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      // Helper/caption text
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme(
      ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
    ),

    scaffoldBackgroundColor: Colors.white,

    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      toolbarHeight: 64,
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: s8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(r12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r12),
        borderSide: const BorderSide(width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r12),
        borderSide: BorderSide(width: 2, color: _seed),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: s16,
        vertical: s16,
      ),
      filled: true,
      fillColor: const Color(0xFFF7FAF7),
      hintStyle: const TextStyle(fontSize: 14),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),

    // SnackBar (consistent, floating)
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Bottom nav
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _seed,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // Dividers
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: Colors.grey.shade300,
      space: s24,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme(
      ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      toolbarHeight: 64,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: s8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(r12)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: s16,
        vertical: s16,
      ),
      filled: true,
      fillColor: const Color(0xFF1B1F1B),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _seed,
      unselectedItemColor: Colors.grey.shade400,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static const List<Color> gradientLight = [
    Color.fromARGB(255, 251, 255, 248),
    Color.fromRGBO(220, 237, 200, 1),
  ];

  static const List<Color> gradientDark = [
    Color.fromARGB(255, 30, 35, 28),
    Color.fromARGB(255, 45, 55, 38),
  ];

  static List<Color> gradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? gradientDark
        : gradientLight;
  }
}
