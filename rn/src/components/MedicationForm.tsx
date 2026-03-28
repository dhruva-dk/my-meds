import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, ScrollView, Alert, TouchableOpacity, Image } from 'react-native';
import * as ImagePicker from 'expo-image-picker';

import PrimaryButton from './PrimaryButton';
import PhotoUploadButton from './PhotoUploadButton';
import { AppColors, AppTypography } from '../styles/theme';

export interface MedicationFormData {
  name: string;
  dosage: string;
  unit: string;
  additionalInfo: string;
  currentImageUri: string;
}

interface Props {
  initialData?: MedicationFormData;
  onSubmit: (data: MedicationFormData) => void;
  submitLabel: string;
}

export default function MedicationForm({ initialData, onSubmit, submitLabel }: Props) {
  const [name, setName] = useState(initialData?.name || '');
  const [dosage, setDosage] = useState(initialData?.dosage || '');
  const [unit, setUnit] = useState(initialData?.unit || 'N/A');
  const [additionalInfo, setAdditionalInfo] = useState(initialData?.additionalInfo || '');
  const [currentImageUri, setCurrentImageUri] = useState(initialData?.currentImageUri || '');

  const units = ['N/A', 'mg', 'mL', 'g', 'mcg', 'IU', '%'];

  const handleUnitSelect = () => {
    Alert.alert('Select Unit', '', units.map(u => ({
      text: u,
      onPress: () => setUnit(u)
    })));
  };

  const handleTakePhoto = async () => {
    const perm = await ImagePicker.requestCameraPermissionsAsync();
    if (!perm.granted) return;
    const result = await ImagePicker.launchCameraAsync({ allowsEditing: true, quality: 0.8 });
    if (!result.canceled && result.assets[0]) {
      setCurrentImageUri(result.assets[0].uri);
    }
  };

  const handleUploadPhoto = async () => {
    const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) return;
    const result = await ImagePicker.launchImageLibraryAsync({ allowsEditing: true, quality: 0.8 });
    if (!result.canceled && result.assets[0]) {
      setCurrentImageUri(result.assets[0].uri);
    }
  };

  const handleSave = () => {
    if (!name.trim()) {
      Alert.alert('Validation Error', 'Please enter a medication name');
      return;
    }
    onSubmit({ name, dosage, unit, additionalInfo, currentImageUri });
  };

  return (
    <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
      <Text style={styles.heading}>Medication Details</Text>
      
      <Text style={styles.label}>Name</Text>
      <TextInput 
        style={styles.input} 
        value={name} 
        onChangeText={setName} 
        multiline 
      />

      <View style={styles.row}>
        <View style={{ flex: 2, marginRight: 8 }}>
          <Text style={styles.label}>Dosage (optional)</Text>
          <TextInput 
            style={styles.input} 
            value={dosage} 
            onChangeText={setDosage} 
            keyboardType="numeric" 
          />
        </View>
        <View style={{ flex: 1 }}>
          <Text style={styles.label}>Unit</Text>
          <TouchableOpacity style={styles.dropdown} onPress={handleUnitSelect}>
            <Text style={{ fontSize: 16 }}>{unit}</Text>
          </TouchableOpacity>
        </View>
      </View>

      <Text style={styles.label}>Additional Info (optional)</Text>
      <TextInput 
        style={styles.input} 
        value={additionalInfo} 
        onChangeText={setAdditionalInfo} 
        multiline 
      />

      {currentImageUri ? (
        <View style={{ marginTop: 24, marginBottom: 16 }}>
          <Text style={styles.heading}>Medication Image</Text>
          <Image source={{ uri: currentImageUri }} style={styles.imagePreview} />
        </View>
      ) : <View style={{ height: 24 }} />}

      <PhotoUploadButton 
        onTakePhoto={handleTakePhoto} 
        onUploadPhoto={handleUploadPhoto} 
        hasImage={!!currentImageUri} 
      />

      <View style={{ height: 24 }} />
      <PrimaryButton title={submitLabel} onPress={handleSave} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  heading: {
    ...AppTypography.headlineSmall,
    marginBottom: 16,
  },
  label: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    marginBottom: 4,
    marginLeft: 4,
  },
  input: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    minHeight: 56,
    paddingHorizontal: 16,
    paddingVertical: 16,
    fontSize: 16,
    marginBottom: 16,
  },
  dropdown: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    height: 56,
    justifyContent: 'center',
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  row: {
    flexDirection: 'row',
  },
  imagePreview: {
    width: '100%',
    height: 200,
    borderRadius: 24,
    marginTop: 8,
  }
});
