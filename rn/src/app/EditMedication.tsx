import React from 'react';
import { Alert, KeyboardAvoidingView, Platform } from 'react-native';
import { useAtom } from 'jotai';
import { useLocalSearchParams, useRouter } from 'expo-router';

import Header from '../components/Header';
import MedicationForm, { MedicationFormData } from '../components/MedicationForm';
import { GlobalStyles } from '../styles/theme';
import { DatabaseService } from '../database/database';
import { selectedProfileAtom, medicationsAtom } from '../store';
import { saveImageToLocal, resolveLocalImageUri } from '../utils/imageStorage';

export default function EditMedicationScreen() {
  const router = useRouter();
  const params = useLocalSearchParams();
  const medication = JSON.parse(params.medication as string);
  
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
  
  const initialData: MedicationFormData = {
    name: medication.name,
    dosage: initialDosageData.d,
    unit: initialDosageData.u,
    additionalInfo: medication.additionalInfo || '',
    currentImageUri: resolveLocalImageUri(medication.imageUrl || ''),
  };

  const handleSave = async (data: MedicationFormData) => {
    if (!profile?.id || !medication.id) return;

    const finalDosage = data.dosage.trim() ? `${data.dosage.trim()} ${data.unit === 'N/A' ? '' : data.unit}`.trim() : '';

    let permanentImageUri = data.currentImageUri;
    // only save to local if the URI changed and it's not empty
    if (permanentImageUri && permanentImageUri !== resolveLocalImageUri(medication.imageUrl || '')) {
      permanentImageUri = await saveImageToLocal(permanentImageUri);
    }

    try {
      await DatabaseService.updateMedication({
        id: medication.id,
        profile_id: profile.id,
        name: data.name,
        dosage: finalDosage,
        additionalInfo: data.additionalInfo,
        imageUrl: permanentImageUri,
      });
      
      const updated = await DatabaseService.getMedicationsForProfile(profile.id);
      setMedications(updated);
      
      router.back();
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Edit Medication" onBackPressed={() => router.back()} />
      <MedicationForm 
        initialData={initialData}
        onSubmit={handleSave}
        submitLabel="Save Changes"
      />
    </KeyboardAvoidingView>
  );
}
