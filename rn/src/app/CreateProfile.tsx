import React from 'react';
import { KeyboardAvoidingView, Platform, Alert, ScrollView, StyleSheet } from 'react-native';
import { useAtom } from 'jotai';
import { useRouter } from 'expo-router';

import Header from '../components/Header';
import ProfileForm, { ProfileFormData } from '../components/ProfileForm';
import { GlobalStyles } from '../styles/theme';
import { DatabaseService } from '../database/database';
import { profilesAtom, selectedProfileAtom } from '../store';

export default function CreateProfileScreen() {
  const router = useRouter();
  const [, setProfiles] = useAtom(profilesAtom);
  const [, setSelectedProfile] = useAtom(selectedProfileAtom);

  const handleSave = async (data: ProfileFormData) => {
    if (!data.name.trim()) {
      Alert.alert('Validation Error', 'Please enter a profile name');
      return;
    }

    try {
      const newId = await DatabaseService.insertProfile({
        name: data.name.trim(),
        dob: data.dob.toISOString(),
        pcp: data.pcp.trim(),
        healthConditions: data.healthConditions.trim(),
        pharmacy: data.pharmacy.trim()
      });

      const updated = await DatabaseService.getAllProfiles();
      setProfiles(updated);

      const insertedProfile = updated.find(p => p.id === newId);
      if (insertedProfile) setSelectedProfile(insertedProfile);

      router.replace('/(tabs)');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Add Profile" onBackPressed={() => router.back()} />
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        <ProfileForm onSubmit={handleSave} submitLabel="Create Profile" />
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
