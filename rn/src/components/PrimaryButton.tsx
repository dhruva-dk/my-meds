import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import { AppColors, AppTypography } from '../styles/theme';

interface PrimaryButtonProps {
  title: string;
  onPress: () => void;
  style?: ViewStyle;
}

export default function PrimaryButton({ title, onPress, style }: PrimaryButtonProps) {
  return (
    <TouchableOpacity style={[styles.button, style]} onPress={onPress} activeOpacity={0.8}>
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: AppColors.primary,
    borderRadius: 24,
    minHeight: 50,
    width: '100%',
    paddingVertical: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    ...AppTypography.bodyLarge,
    color: AppColors.surface, // Assuming onPrimary is the surface color (white)
    fontWeight: '600',
  },
});
