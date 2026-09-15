import 'package:flutter/material.dart';

class AppTheme {
  // Sacred Devotional Color Palette
  static const Color primaryNavy = Color(0xFF101D2D);
  static const Color primaryNavyLight = Color(0xFF1B2E46);
  static const Color saffronAccent = Color(0xFFB45309);
  static const Color warmGold = Color(0xFFD97706);
  static const Color warmGoldLight = Color(0xFFFDE68A);
  static const Color saffronLight = Color(0xFFFEF3C7);
  static const Color parchmentBackground = Color(0xFFF9F7F2);
  static const Color surfaceWhite = Colors.white;
  static const Color cardBorder = Color(0xFFE8E2D5);
  static const Color dividerColor = Color(0xFFE5DECE);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Functional Colors
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color errorRed = Color(0xFFC53030);
  static const Color errorLight = Color(0xFFFFEBEE);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'TiroDevanagariHindi',
      scaffoldBackgroundColor: parchmentBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: saffronAccent,
        surface: surfaceWhite,
        error: errorRed,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        toolbarHeight: 62,
        titleTextStyle: TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: textSecondary,
          fontSize: 15,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: textMuted,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: saffronAccent, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'TiroDevanagariHindi',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavy,
          textStyle: const TextStyle(
            fontFamily: 'TiroDevanagariHindi',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryNavy,
        selectedItemColor: warmGold,
        unselectedItemColor: Colors.white70,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: textSecondary,
          fontSize: 15,
          height: 1.4,
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        tileColor: surfaceWhite,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'TiroDevanagariHindi',
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
