import { updateProfile } from '@/data/commands';
import { useSnapshot } from '@/data/useSnapshot';
import { ProfileForm } from '@/ui/ProfileForm';

export default function ProfileScreen() {
  const { activeProfile } = useSnapshot();
  return (
    <ProfileForm
      key={activeProfile.id}
      initial={activeProfile}
      confirmLabel="Save Profile"
      failureTitle="Couldn't Save Profile"
      onSave={(fields) => updateProfile(activeProfile.id, fields)}
      showPrivacyPolicy
    />
  );
}
