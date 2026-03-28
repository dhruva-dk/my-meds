import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Image, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Medication } from '../types';
import { AppColors, AppTypography } from '../styles/theme';
import { DatabaseService } from '../database/database';

interface Props {
  medication: Medication;
  onEdit: () => void;
  onDeleteSuccess: () => void;
}

export default function MedicationTile({ medication, onEdit, onDeleteSuccess }: Props) {
  const hasImage = medication.imageUrl && medication.imageUrl.length > 0;
  
  const handleDelete = () => {
    Alert.alert('Delete Medication', 'Are you sure you want to delete this medication?', [
      { text: 'Cancel', style: 'cancel' },
      { 
        text: 'Delete', 
        style: 'destructive',
        onPress: async () => {
          if (medication.id) {
             await DatabaseService.deleteMedication(medication.id);
             onDeleteSuccess();
          }
        }
      }
    ]);
  };

  return (
    <TouchableOpacity 
      style={styles.card} 
      onPress={onEdit}
      activeOpacity={0.7}
    >
      <View style={styles.row}>
        {hasImage && (
          <Image 
            source={{ uri: medication.imageUrl }} 
            style={styles.image} 
          />
        )}
        <View style={styles.details}>
          <Text style={styles.name} numberOfLines={2}>{medication.name}</Text>
          
          {medication.dosage ? (
            <View style={styles.infoRow}>
              <Ionicons name="medical-outline" size={16} color={AppColors.textSecondary} />
              <Text style={styles.infoText} numberOfLines={1}>{medication.dosage}</Text>
            </View>
          ) : null}

          {medication.additionalInfo ? (
            <View style={[styles.infoRow, { marginTop: 4 }]}>
              <Ionicons name="information-circle-outline" size={16} color={AppColors.textSecondary} />
              <Text style={styles.infoText} numberOfLines={1}>{medication.additionalInfo}</Text>
            </View>
          ) : null}
        </View>

        <TouchableOpacity style={styles.menuIcon} onPress={handleDelete}>
          <Ionicons name="ellipsis-vertical" size={24} color={AppColors.textSecondary} />
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    padding: 16,
    marginVertical: 4,
    marginHorizontal: 16,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  image: {
    width: 64,
    height: 64,
    borderRadius: 12,
    marginRight: 16,
    backgroundColor: '#e0e0e0', // Placeholder
  },
  details: {
    flex: 1,
  },
  name: {
    ...AppTypography.headlineSmall,
    fontWeight: 'bold',
    color: AppColors.text, // onSecondaryContainer
    marginBottom: 8,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infoText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    marginLeft: 8,
    flex: 1,
  },
  menuIcon: {
    padding: 8,
  }
});
