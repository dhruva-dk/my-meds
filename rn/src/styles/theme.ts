import { StyleSheet } from 'react-native';

export const AppColors = {
  lightAccent: '#85CC17',
  lightAccentSecondary: '#2F3A33',
  lightBackgroundPrimary: '#F6F6F6',
  lightBackgroundSecondary: '#FFFFFF',
  lightTextPrimary: '#000000',
  lightTextSecondary: '#7d837f',
  lightError: '#A11821',

  // Equivalents for ease of use
  primary: '#85CC17',
  background: '#F6F6F6',
  surface: '#FFFFFF',
  text: '#000000',
  textSecondary: '#7d837f',
  error: '#A11821',
};

export const AppTypography = {
  headlineLarge: {
    fontSize: 32,
    fontWeight: 'bold' as const,
    color: AppColors.text,
  },
  headlineMedium: {
    fontSize: 24,
    fontWeight: 'bold' as const,
    color: AppColors.text,
  },
  headlineSmall: {
    fontSize: 18,
    fontWeight: 'bold' as const,
    color: AppColors.text,
  },
  bodyLarge: {
    fontSize: 16,
    fontWeight: 'normal' as const,
    color: AppColors.text,
  },
  bodyMedium: {
    fontSize: 14,
    fontWeight: 'normal' as const,
    color: AppColors.text,
  },
  bodySmall: {
    fontSize: 12,
    fontWeight: 'normal' as const,
    color: AppColors.text,
  },
};

export const GlobalStyles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.background,
  },
  surface: {
    backgroundColor: AppColors.surface,
    padding: 16,
    borderRadius: 8,
  },
  button: {
    backgroundColor: AppColors.primary,
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    color: AppColors.surface, // Assuming onPrimary is white/surface
    fontSize: 16,
    fontWeight: '600',
  },
  input: {
    backgroundColor: AppColors.surface,
    borderColor: '#e0e0e0',
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: AppColors.text,
    marginBottom: 16,
  }
});
