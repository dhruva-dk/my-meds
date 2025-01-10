import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Inter",
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccent,
      onPrimary: AppColors.lightBackgroundSecondary,
      secondary: AppColors.lightAccentSecondary,
      onSecondary: AppColors.lightBackgroundSecondary,
      surface: AppColors.lightBackgroundPrimary,
      onSurface: AppColors.lightTextPrimary,
      secondaryContainer: AppColors.lightBackgroundSecondary,
      onSecondaryContainer: AppColors.lightTextPrimary,
      error: AppColors.lightError,
      onError: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackgroundPrimary,
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.lightBackgroundSecondary,
      textStyle: TextStyle(color: AppColors.lightTextPrimary),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.lightBackgroundSecondary,
    ),
    textTheme: const TextTheme(
      // Headings
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      // Body Text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
