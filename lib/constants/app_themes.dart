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
/*  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Inter",
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      onPrimary: AppColors.darkTextPrimary,
      surface: AppColors.darkBackgroundPrimary,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.darkError,
      onError: AppColors.darkTextPrimary,
      secondary: AppColors.darkAccentSecondary,
      onSecondary: AppColors.darkTextPrimary,
      secondaryContainer: AppColors.darkBackgroundSecondary,
      onSecondaryContainer: AppColors.darkTextPrimary,
      tertiaryContainer:
          AppColors.darkAccentSecondary, //headers / nav bars are tertiary
      onTertiaryContainer: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackgroundPrimary,
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.darkBackgroundSecondary,
      textStyle: TextStyle(color: AppColors.darkTextPrimary),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.darkBackgroundSecondary,
    ),
    textTheme: const TextTheme(
      // Headings
      headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary),
      headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary),
      headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary),

      // Body Text
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextPrimary),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextPrimary),

      // Labels (for buttons, form fields, etc.)
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary),
    ),
  );
}8*/
