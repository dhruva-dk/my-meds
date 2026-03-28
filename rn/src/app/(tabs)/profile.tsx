import React from 'react';
import { ScrollView, Alert, KeyboardAvoidingView, Platform, StyleSheet } from 'react-native';
import { useAtom } from 'jotai';
import { useRouter } from 'expo-router';

import Header from '../../components/Header';
import ProfileForm, { ProfileFormData } from '../../components/ProfileForm';
import { GlobalStyles } from '../../styles/theme';
import { DatabaseService } from '../../database/database';
import { profilesAtom, selectedProfileAtom } from '../../store';

export default function EditProfileScreen() {
  const router = useRouter();
  const [, setProfiles] = useAtom(profilesAtom);
  const [selectedProfile, setSelectedProfile] = useAtom(selectedProfileAtom);

  const handleSave = async (data: ProfileFormData) => {
    if (!data.name.trim()) {
      Alert.alert('Validation Error', 'Please enter a profile name');
      return;
    }
    if (!selectedProfile?.id) return;

    try {
      const updatedProfile = {
        id: selectedProfile.id,
        name: data.name.trim(),
        dob: data.dob.toISOString(),
        pcp: data.pcp.trim(),
        healthConditions: data.healthConditions.trim(),
        pharmacy: data.pharmacy.trim()
      };
      await DatabaseService.updateProfile(updatedProfile);

      const updated = await DatabaseService.getAllProfiles();
      setProfiles(updated);
      setSelectedProfile(updatedProfile);

      router.push('/');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  const initialData = selectedProfile ? {
    name: selectedProfile.name,
    dob: new Date(selectedProfile.dob),
    pcp: selectedProfile.pcp || '',
    healthConditions: selectedProfile.healthConditions || '',
    pharmacy: selectedProfile.pharmacy || '',
  } : undefined;

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Your Profile" showBackButton={false} />
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        {initialData && (
          <ProfileForm 
            initialData={initialData} 
            onSubmit={handleSave} 
            submitLabel="Save Profile" 
          />
        )}
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  }
});
