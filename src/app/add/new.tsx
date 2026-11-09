import { router, useLocalSearchParams } from 'expo-router';
import { addMedication } from '@/data/commands';
import { getSnapshot } from '@/data/store';
import { resetAddTab } from '@/ui/addTabReset';
import { MedicationForm } from '@/ui/MedicationForm';

/** `name` and `notes` prefill an FDA pick; `photo` attaches a picked photo. */
export default function NewMedicationScreen() {
  const params = useLocalSearchParams<{ name?: string; notes?: string; photo?: string }>();
  return (
    <MedicationForm
      initial={{
        name: params.name ?? '',
        dosage: '',
        notes: params.notes ?? '',
        photo: null,
        newPhotoUri: params.photo ?? null,
      }}
      confirmLabel="Add Medication"
      failureTitle="Couldn't Add Medication"
      onCancel={() => router.back()}
      onSave={async (fields, newPhotoUri) => {
        await addMedication(getSnapshot().activeProfile.id, fields, newPhotoUri);
      }}
      onSaved={() => {
        router.back();
        resetAddTab();
        router.navigate('/(home)');
      }}
    />
  );
}
