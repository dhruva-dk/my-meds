import { router } from 'expo-router';
import { addProfile } from '@/data/commands';
import { ProfileForm } from '@/ui/ProfileForm';

const BLANK = { name: '', dob: '', pcp: '', healthConditions: '', pharmacy: '' };

export default function AddProfileScreen() {
  return (
    <ProfileForm
      initial={BLANK}
      confirmLabel="Continue"
      failureTitle="Couldn't Add Profile"
      onCancel={() => router.back()}
      onSave={(fields) => {
        addProfile(fields);
      }}
      onSaved={() => router.back()}
    />
  );
}
