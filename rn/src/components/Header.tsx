import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppTypography } from '../styles/theme';

interface HeaderProps {
  title: string;
  showBackButton?: boolean;
  onBackPressed?: () => void;
  rightWidget?: React.ReactNode;
}

export default function Header({ title, showBackButton = true, onBackPressed, rightWidget }: HeaderProps) {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: Math.max(insets.top, 20) + 8 }]}>
      <View style={styles.row}>
        {showBackButton && (
          <TouchableOpacity style={styles.backButton} onPress={onBackPressed} activeOpacity={0.7}>
            <Ionicons name="chevron-back" size={28} color="#FFFFFF" />
          </TouchableOpacity>
        )}
        <Text style={[styles.title, { marginLeft: showBackButton ? 16 : 0 }]} numberOfLines={1} adjustsFontSizeToFit>
          {title}
        </Text>
        {rightWidget && <View style={styles.rightWidget}>{rightWidget}</View>}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: AppColors.lightAccentSecondary,
    borderBottomLeftRadius: 48,
    borderBottomRightRadius: 48,
    paddingLeft: 20,
    paddingRight: 20,
    paddingBottom: 32,
    width: '100%',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  title: {
    ...AppTypography.headlineLarge,
    color: '#FFFFFF',
    flex: 1,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  rightWidget: {
    marginLeft: 16,
  }
});
