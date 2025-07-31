// lib/core/theme/app_theme.dart

// Import packages/modules
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1C1C4B);
  static const secondary = Color(0xFF3A3A8B);
  static const accent = Color(0xFFE91E63);
  static const lightBackground = Color(0xFFF5F5F5);
  static const darkBackground = Color(0xFF121212);
  static const textPrimary = Color(0xFF1E1E1E);
  static const textSecondary = Color(0xFF757575);
  static const buttonColor = Color(0xFF4646C2);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}