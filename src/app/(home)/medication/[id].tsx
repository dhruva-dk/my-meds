import { useLocalSearchParams, useNavigation } from 'expo-router';
import { useEffect } from 'react';
import { updateMedication } from '@/data/commands';
import { useSnapshot } from '@/data/useSnapshot';
import { MedicationForm } from '@/ui/MedicationForm';

export default function ViewMedicationScreen() {
  const params = useLocalSearchParams<{ id: string }>();
  const id = Number(params.id);
  const medication = useSnapshot().medications.find((item) => item.id === id);
  const navigation = useNavigation();

  // Switching profile resets the tabs from another screen, so only close when still showing.
  const gone = !medication;
  useEffect(() => {
    if (gone && navigation.isFocused() && navigation.canGoBack()) navigation.goBack();
  }, [gone, navigation]);

  if (!medication) return null;
  return (
    <MedicationForm
      key={medication.id}
      initial={{
        name: medication.name,
        dosage: medication.dosage,
        notes: medication.notes,
        photo: medication.photo,
        newPhotoUri: null,
      }}
      confirmLabel="Update Medication"
      failureTitle="Couldn't Update Medication"
      onSave={(fields, newPhotoUri) => updateMedication(id, fields, newPhotoUri)}
      onSaved={() => navigation.goBack()}
    />
  );
}
