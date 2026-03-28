import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, ScrollView, Alert, KeyboardAvoidingView, Platform, TouchableOpacity, Image } from 'react-native';
import { useAtom } from 'jotai';

import Header from '../components/Header';
import PrimaryButton from '../components/PrimaryButton';
import PhotoUploadButton from '../components/PhotoUploadButton';
import { AppColors, AppTypography, GlobalStyles } from '../styles/theme';
import { DatabaseService } from '../database/database';
import { selectedProfileAtom, medicationsAtom } from '../store';
import * as ImagePicker from 'expo-image-picker';
import { useLocalSearchParams, useRouter } from 'expo-router';

export default function CreateMedicationScreen() {
  const router = useRouter();
  const params = useLocalSearchParams();
  const initialDrug = params.medication ? JSON.parse(params.medication as string) : null;
  const imageUri = params.imageUri as string | undefined;
  const [profile] = useAtom(selectedProfileAtom);
  const [, setMedications] = useAtom(medicationsAtom);

  const [name, setName] = useState(initialDrug ? `Brand: ${initialDrug.brandName}\nGeneric: ${initialDrug.genericName}` : (imageUri ? 'Image' : ''));
  const [dosage, setDosage] = useState('');
  const [unit, setUnit] = useState('N/A');
  const [additionalInfo, setAdditionalInfo] = useState(initialDrug ? `Dosage type: ${initialDrug.dosageForm}` : '');
  const [currentImageUri, setCurrentImageUri] = useState(imageUri || '');

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

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Validation Error', 'Please enter a medication name');
      return;
    }
    if (!profile?.id) {
      Alert.alert('Error', 'No profile selected');
      return;
    }

    const finalDosage = dosage.trim() ? `${dosage.trim()} ${unit === 'N/A' ? '' : unit}`.trim() : '';

    try {
      await DatabaseService.insertMedication({
        profile_id: profile.id,
        name,
        dosage: finalDosage,
        additionalInfo,
        imageUrl: currentImageUri,
      });
      // Refresh list
      const updated = await DatabaseService.getMedicationsForProfile(profile.id);
      setMedications(updated);
      
      router.replace('/(tabs)');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Add Medication" onBackPressed={() => router.back()} />
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
        <PrimaryButton title="Add Medication" onPress={handleSave} />
      </ScrollView>
    </KeyboardAvoidingView>
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
