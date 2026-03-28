import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { AppColors } from '../styles/theme';

interface NavBarProps {
  onProfile: () => void;
  onExport: () => void;
  onSwitch: () => void;
}

export default function NavBar({ onProfile, onExport, onSwitch }: NavBarProps) {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingBottom: Math.max(insets.bottom, 16) }]}>
      <View style={styles.navRow}>
        <NavItem icon="person" label="Profile" onPress={onProfile} />
        <NavItem icon="share-outline" label="Export" onPress={onExport} />
        <NavItem icon="people" label="Switch" onPress={onSwitch} />
      </View>
    </View>
  );
}

function NavItem({ icon, label, onPress }: { icon: any, label: string, onPress: () => void }) {
  return (
    <TouchableOpacity style={styles.item} onPress={onPress}>
      <Ionicons name={icon} size={28} color="#FFFFFF" />
      <Text style={styles.label}>{label}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: AppColors.lightAccentSecondary, // theme.colorScheme.secondary
  },
  navRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingTop: 8,
    paddingBottom: 4,
  },
  item: {
    alignItems: 'center',
    padding: 8,
  },
  label: {
    color: '#FFFFFF',
    fontSize: 10,
    marginTop: 2,
  }
});
