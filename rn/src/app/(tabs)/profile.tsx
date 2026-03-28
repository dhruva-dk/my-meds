import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TextInput, ScrollView, Alert, KeyboardAvoidingView, Platform, TouchableOpacity, Modal, Button, Linking } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useAtom } from 'jotai';
import { useRouter } from 'expo-router';

import Header from '../../components/Header';
import PrimaryButton from '../../components/PrimaryButton';
import { AppColors, AppTypography, GlobalStyles } from '../../styles/theme';
import { DatabaseService } from '../../database/database';
import { profilesAtom, selectedProfileAtom } from '../../store';

export default function EditProfileScreen() {
  const router = useRouter();
  const [, setProfiles] = useAtom(profilesAtom);
  const [selectedProfile, setSelectedProfile] = useAtom(selectedProfileAtom);

  const [name, setName] = useState('');
  const [dob, setDob] = useState(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [pcp, setPcp] = useState('');
  const [healthConditions, setHealthConditions] = useState('');
  const [pharmacy, setPharmacy] = useState('');

  useEffect(() => {
    if (selectedProfile) {
      setName(selectedProfile.name);
      setDob(new Date(selectedProfile.dob));
      setPcp(selectedProfile.pcp || '');
      setHealthConditions(selectedProfile.healthConditions || '');
      setPharmacy(selectedProfile.pharmacy || '');
    }
  }, [selectedProfile]);

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Validation Error', 'Please enter a profile name');
      return;
    }
    if (!selectedProfile?.id) return;

    try {
      const updatedProfile = {
        id: selectedProfile.id,
        name: name.trim(),
        dob: dob.toISOString(),
        pcp: pcp.trim(),
        healthConditions: healthConditions.trim(),
        pharmacy: pharmacy.trim()
      };
      await DatabaseService.updateProfile(updatedProfile);

      const updated = await DatabaseService.getAllProfiles();
      setProfiles(updated);
      setSelectedProfile(updatedProfile);

      router.back();
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Your Profile" showBackButton={false} />
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        <Text style={styles.subHeading}>Personal Information</Text>
        
        <TextInput 
          style={styles.input} 
          value={name} 
          placeholder="Name"
          onChangeText={setName} 
        />

        <TouchableOpacity style={styles.datePickerBtn} onPress={() => setShowDatePicker(true)}>
          <Text style={{ fontSize: 16, color: AppColors.text }}>{dob ? dob.toLocaleDateString() : "Date of Birth"}</Text>
        </TouchableOpacity>

        {showDatePicker && Platform.OS === 'ios' && (
          <Modal visible={true} transparent animationType="slide">
            <View style={styles.modalOverlay}>
              <View style={styles.modalContent}>
                <View style={styles.modalHeader}>
                  <Button title="Done" onPress={() => setShowDatePicker(false)} />
                </View>
                <DateTimePicker
                  value={dob}
                  mode="date"
                  display="spinner"
                  onChange={(event, date) => {
                    if (date) setDob(date);
                  }}
                />
              </View>
            </View>
          </Modal>
        )}

        {showDatePicker && Platform.OS === 'android' && (
          <DateTimePicker
            value={dob}
            mode="date"
            display="default"
            onChange={(event, date) => {
              setShowDatePicker(false);
              if (date) setDob(date);
            }}
          />
        )}

        {showDatePicker && Platform.OS === 'android' && (
          <DateTimePicker
            value={dob}
            mode="date"
            display="default"
            onChange={(event, date) => {
              setShowDatePicker(false);
              if (date) setDob(date);
            }}
          />
        )}

        <Text style={[styles.subHeading, { marginTop: 16 }]}>Health Information</Text>

        <TextInput 
          style={styles.input} 
          value={pcp} 
          placeholder="Primary Care Physician (optional)"
          onChangeText={setPcp} 
        />

        <TextInput 
          style={styles.input} 
          value={pharmacy} 
          placeholder="Pharmacy Phone (optional)"
          keyboardType="phone-pad"
          onChangeText={setPharmacy} 
        />

        <TextInput 
          style={[styles.input, { minHeight: 120, paddingTop: 16 }]} 
          value={healthConditions} 
          placeholder="Health Conditions (optional)"
          onChangeText={setHealthConditions} 
          multiline
        />

        <View style={{ height: 24 }} />
        <TouchableOpacity 
          style={styles.secondaryButton} 
          onPress={() => Linking.openURL('https://sites.google.com/view/mymedsapp/home')}
        >
          <Text style={styles.secondaryButtonText}>Privacy Policy</Text>
        </TouchableOpacity>

        <PrimaryButton title="Save Profile" onPress={handleSave} style={{ marginTop: 8 }} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  subHeading: {
    ...AppTypography.headlineSmall,
    marginBottom: 16,
  },
  input: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    minHeight: 56,
    paddingHorizontal: 16,
    fontSize: 16,
    marginBottom: 8,
  },
  datePickerBtn: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    height: 56,
    justifyContent: 'center',
    paddingHorizontal: 16,
    marginBottom: 8,
  },
  modalOverlay: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  modalContent: {
    backgroundColor: '#FFFFFF',
    paddingBottom: 20,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    borderBottomColor: '#EEEEEE',
  },
  secondaryButton: {
    backgroundColor: '#FFFFFF',
    borderRadius: 24,
    height: 56,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 4,
  },
  secondaryButtonText: {
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: '600',
  }
});
