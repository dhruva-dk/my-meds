import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Inter",
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccentSecondary,
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
    dialogTheme: const DialogThemeData(
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      contentTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.lightTextPrimary,
      contentTextStyle: TextStyle(
        color: AppColors.lightBackgroundSecondary,
        fontFamily: "Inter",
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightTextPrimary,
      ),
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

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Inter",
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lightAccentSecondary, // Keeping high-brand consistency
      onPrimary: Colors.white,
      secondary: AppColors.lightAccentSecondary,
      onSecondary: Colors.white,
      surface: AppColors.darkBackgroundPrimary,
      onSurface: AppColors.darkTextPrimary,
      secondaryContainer: AppColors.darkBackgroundSecondary,
      onSecondaryContainer: AppColors.darkTextPrimary,
      error: AppColors.darkError,
      onError: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackgroundPrimary,
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.darkBackgroundSecondary,
      textStyle: TextStyle(color: AppColors.darkTextPrimary),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.darkBackgroundSecondary,
    ),
    dialogTheme: const DialogThemeData(
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.darkTextPrimary,
      contentTextStyle: TextStyle(
        color: AppColors.darkBackgroundPrimary,
        fontFamily: "Inter",
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkTextPrimary,
      ),
    ),
    textTheme: lightTheme.textTheme.apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
  );
}
