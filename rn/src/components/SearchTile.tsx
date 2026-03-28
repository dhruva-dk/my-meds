import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppTypography } from '../styles/theme';
import { FDADrug } from '../api/fda';

interface SearchTileProps {
  drug: FDADrug;
  onTap?: () => void;
}

export default function SearchTile({ drug, onTap }: SearchTileProps) {
  return (
    <TouchableOpacity style={styles.card} onPress={onTap} activeOpacity={0.7}>
      <Text style={styles.brandName}>{drug.brandName}</Text>
      <Text style={styles.genericName} numberOfLines={2}>{drug.genericName}</Text>
      
      <View style={styles.rowLayout}>
        <View style={styles.row}>
          <Ionicons name="medical-outline" size={16} color={AppColors.textSecondary} />
          <Text style={styles.dosageText} numberOfLines={1}>{drug.dosageForm}</Text>
        </View>
        <View style={styles.row}>
          <Ionicons name="barcode-outline" size={16} color={AppColors.textSecondary} />
          <Text style={styles.dosageText}>NDC: {drug.ndc}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 16,
    padding: 16,
    marginVertical: 4,
  },
  brandName: {
    ...AppTypography.headlineSmall,
    fontWeight: 'bold',
  },
  genericName: {
    ...AppTypography.bodyLarge,
    fontWeight: '500',
    marginTop: 8,
  },
  rowLayout: {
    flexDirection: 'row',
    marginTop: 8,
    alignItems: 'center',
  },
  row: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  dosageText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    marginLeft: 4,
    flexShrink: 1,
  }
});
