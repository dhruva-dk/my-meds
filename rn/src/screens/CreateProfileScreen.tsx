import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, ScrollView, Alert, KeyboardAvoidingView, Platform, TouchableOpacity, Modal, Button } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useAtom } from 'jotai';

import Header from '../components/Header';
import PrimaryButton from '../components/PrimaryButton';
import { AppColors, AppTypography, GlobalStyles } from '../styles/theme';
import { DatabaseService } from '../database/database';
import { profilesAtom, selectedProfileAtom } from '../store';

export default function CreateProfileScreen({ navigation }: any) {
  const [, setProfiles] = useAtom(profilesAtom);
  const [, setSelectedProfile] = useAtom(selectedProfileAtom);

  const [name, setName] = useState('');
  const [dob, setDob] = useState(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [pcp, setPcp] = useState('');
  const [healthConditions, setHealthConditions] = useState('');
  const [pharmacy, setPharmacy] = useState('');

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Validation Error', 'Please enter a profile name');
      return;
    }

    try {
      const newId = await DatabaseService.insertProfile({
        name: name.trim(),
        dob: dob.toISOString(),
        pcp: pcp.trim(),
        healthConditions: healthConditions.trim(),
        pharmacy: pharmacy.trim()
      });

      const updated = await DatabaseService.getAllProfiles();
      setProfiles(updated);

      const insertedProfile = updated.find(p => p.id === newId);
      if (insertedProfile) setSelectedProfile(insertedProfile);

      navigation.replace('Home');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  return (
    <KeyboardAvoidingView style={GlobalStyles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Header title="Add Profile" onBackPressed={() => navigation.goBack()} />
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        <Text style={styles.heading}>Profile Details</Text>
        
        <Text style={styles.label}>Name</Text>
        <TextInput 
          style={styles.input} 
          value={name} 
          onChangeText={setName} 
        />

        <Text style={styles.label}>Date of Birth</Text>
        <TouchableOpacity style={styles.datePickerBtn} onPress={() => setShowDatePicker(true)}>
          <Text style={{ fontSize: 16 }}>{dob.toLocaleDateString()}</Text>
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

        <Text style={styles.label}>Primary Care Physician (optional)</Text>
        <TextInput 
          style={styles.input} 
          value={pcp} 
          onChangeText={setPcp} 
        />

        <Text style={styles.label}>Health Conditions (optional)</Text>
        <TextInput 
          style={styles.input} 
          value={healthConditions} 
          onChangeText={setHealthConditions} 
          multiline
        />

        <Text style={styles.label}>Pharmacy Preference (optional)</Text>
        <TextInput 
          style={styles.input} 
          value={pharmacy} 
          onChangeText={setPharmacy} 
        />

        <View style={{ height: 24 }} />
        <PrimaryButton title="Create Profile" onPress={handleSave} />
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
  datePickerBtn: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    height: 56,
    justifyContent: 'center',
    paddingHorizontal: 16,
    marginBottom: 16,
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
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  }
});
