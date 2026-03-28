import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TextInput, ScrollView, Alert, KeyboardAvoidingView, Platform, TouchableOpacity, Image } from 'react-native';
import { useAtom } from 'jotai';

import Header from '../components/Header';
import PrimaryButton from '../components/PrimaryButton';
import PhotoUploadButton from '../components/PhotoUploadButton';
import { AppColors, AppTypography, GlobalStyles } from '../styles/theme';
import { DatabaseService } from '../database/database';
import { selectedProfileAtom, medicationsAtom } from '../store';
import * as ImagePicker from 'expo-image-picker';

export default function EditMedicationScreen({ route, navigation }: any) {
  const { medication } = route.params;
  const [profile] = useAtom(selectedProfileAtom);
  const [, setMedications] = useAtom(medicationsAtom);

  const extractDosageAndUnit = (rawDosage: string) => {
    if (!rawDosage) return { d: '', u: 'N/A' };
    const parts = rawDosage.split(' ');
    if (parts.length >= 2) {
      const u = parts.pop() || 'N/A';
      return { d: parts.join(' '), u };
    }
    return { d: rawDosage, u: 'N/A' };
  };

  const initialDosageData = extractDosageAndUnit(medication.dosage || '');

  const [name, setName] = useState(medication.name);
  const [dosage, setDosage] = useState(initialDosageData.d);
  const [unit, setUnit] = useState(initialDosageData.u);
  const [additionalInfo, setAdditionalInfo] = useState(medication.additionalInfo || '');
  const [currentImageUri, setCurrentImageUri] = useState(medication.imageUrl || '');

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
    if (!profile?.id || !medication.id) return;

    const finalDosage = dosage.trim() ? `${dosage.trim()} ${unit === 'N/A' ? '' : unit}`.trim() : '';

    try {
      await DatabaseService.updateMedication({
        id: medication.id,
        profile_id: profile.id,
        name,
        dosage: finalDosage,
        additionalInfo,
        imageUrl: currentImageUri,
      });
      // Refresh list
      const updated = await DatabaseService.getMedicationsForProfile(profile.id);
      setMedications(updated);
      
      navigation.goBack();
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Edit Medication" onBackPressed={() => navigation.goBack()} />
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
        <PrimaryButton title="Save Changes" onPress={handleSave} />
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
