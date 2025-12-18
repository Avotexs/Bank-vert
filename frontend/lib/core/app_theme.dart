import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF00A86B);
  static const Color darkGreen = Color(0xFF0D4D2C);
  static const Color lightGreen = Color(0xFFB8E6D0);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color backgroundDark = Color(0xFF0A1A14);
  static const Color backgroundLight = Color(0xFFF5FBF8);
  static const Color cardDark = Color(0xFF1A2F26);
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color textMuted = Color(0xFF8A9A93);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGold,
        surface: AppColors.cardDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.primaryGreen,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
        ),
      ),
    );
  }
}
