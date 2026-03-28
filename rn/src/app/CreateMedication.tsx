import React, { useRef } from 'react';
import { Alert, KeyboardAvoidingView, Platform, TouchableOpacity, Text } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAtom } from 'jotai';
import { useLocalSearchParams, useRouter } from 'expo-router';

import Header from '../components/Header';
import MedicationForm, { MedicationFormData, MedicationFormRef } from '../components/MedicationForm';
import { GlobalStyles } from '../styles/theme';
import { DatabaseService } from '../database/database';
import { selectedProfileAtom, medicationsAtom } from '../store';
import { saveImageToLocal } from '../utils/imageStorage';

export default function CreateMedicationScreen() {
  const router = useRouter();
  const params = useLocalSearchParams();
  const initialDrug = params.medication ? JSON.parse(params.medication as string) : null;
  const imageUri = params.imageUri as string | undefined;
  
  const [profile] = useAtom(selectedProfileAtom);
  const [, setMedications] = useAtom(medicationsAtom);

  const formRef = useRef<MedicationFormRef>(null);

  const rightWidget = (
    <TouchableOpacity onPress={() => formRef.current?.submit()} style={GlobalStyles.headerButton} activeOpacity={0.8}>
      <Ionicons name="save-outline" size={22} color="#000" />
      <Text style={GlobalStyles.headerButtonText}>Save</Text>
    </TouchableOpacity>
  );

  const initialData: MedicationFormData | undefined = initialDrug || imageUri ? {
    name: initialDrug ? `Brand: ${initialDrug.brandName}\nGeneric: ${initialDrug.genericName}` : (imageUri ? 'Image' : ''),
    dosage: '',
    unit: 'N/A',
    additionalInfo: initialDrug ? `Dosage type: ${initialDrug.dosageForm}` : '',
    currentImageUri: imageUri || '',
  } : undefined;

  const handleSave = async (data: MedicationFormData) => {
    if (!profile?.id) {
      Alert.alert('Error', 'No profile selected');
      return;
    }

    const finalDosage = data.dosage.trim() ? `${data.dosage.trim()} ${data.unit === 'N/A' ? '' : data.unit}`.trim() : '';
    
    let permanentImageUri = data.currentImageUri;
    if (permanentImageUri) {
      permanentImageUri = await saveImageToLocal(permanentImageUri);
    }

    try {
      await DatabaseService.insertMedication({
        profile_id: profile.id,
        name: data.name,
        dosage: finalDosage,
        additionalInfo: data.additionalInfo,
        imageUrl: permanentImageUri,
      });
      
      const updated = await DatabaseService.getMedicationsForProfile(profile.id);
      setMedications(updated);
      
      router.replace('/(tabs)');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Add Medication" onBackPressed={() => router.back()} rightWidget={rightWidget} />
      <MedicationForm 
        ref={formRef}
        initialData={initialData}
        onSubmit={handleSave}
        submitLabel="Add Medication"
        hideSubmitButton
      />
    </KeyboardAvoidingView>
  );
}
