import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  Platform,
  TouchableOpacity,
  Modal,
  Button,
  Linking,
} from "react-native";
import DateTimePicker from "@react-native-community/datetimepicker";
import PrimaryButton from "./PrimaryButton";
import { AppColors, AppTypography } from "../styles/theme";

export interface ProfileFormData {
  name: string;
  dob: Date;
  pcp: string;
  healthConditions: string;
  pharmacy: string;
}

interface ProfileFormProps {
  initialData?: Partial<ProfileFormData>;
  onSubmit: (data: ProfileFormData) => Promise<void>;
  submitLabel: string;
}

export default function ProfileForm({
  initialData,
  onSubmit,
  submitLabel,
}: ProfileFormProps) {
  const [name, setName] = useState("");
  const [dob, setDob] = useState(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [pcp, setPcp] = useState("");
  const [healthConditions, setHealthConditions] = useState("");
  const [pharmacy, setPharmacy] = useState("");

  useEffect(() => {
    if (initialData) {
      if (initialData.name) setName(initialData.name);
      if (initialData.dob) setDob(initialData.dob);
      if (initialData.pcp) setPcp(initialData.pcp);
      if (initialData.healthConditions)
        setHealthConditions(initialData.healthConditions);
      if (initialData.pharmacy) setPharmacy(initialData.pharmacy);
    }
  }, [initialData]);

  const handleSave = () => {
    onSubmit({
      name,
      dob,
      pcp,
      healthConditions,
      pharmacy,
    });
  };

  return (
    <View>
      <Text style={styles.subHeading}>Personal Information</Text>

      <TextInput
        style={styles.input}
        value={name}
        placeholder="Name"
        onChangeText={setName}
      />

      <TouchableOpacity
        style={styles.datePickerBtn}
        onPress={() => setShowDatePicker(true)}
      >
        <Text style={{ fontSize: 16, color: AppColors.text }}>
          {dob ? dob.toLocaleDateString() : "Date of Birth"}
        </Text>
      </TouchableOpacity>

      {showDatePicker && Platform.OS === "ios" && (
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

      {showDatePicker && Platform.OS === "android" && (
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

      <Text style={[styles.subHeading, { marginTop: 16 }]}>
        Health Information
      </Text>

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
        style={[styles.input, { paddingVertical: 16 }]}
        value={healthConditions}
        placeholder="Health Conditions (optional)"
        onChangeText={setHealthConditions}
        multiline
      />
      <TouchableOpacity
        style={styles.secondaryButton}
        onPress={() =>
          Linking.openURL("https://sites.google.com/view/mymedsapp/home")
        }
      >
        <Text style={styles.secondaryButtonText}>Privacy Policy</Text>
      </TouchableOpacity>

      <PrimaryButton
        title={submitLabel}
        onPress={handleSave}
        style={{ marginTop: 8 }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
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
    justifyContent: "center",
    paddingHorizontal: 16,
    marginBottom: 8,
  },
  modalOverlay: {
    flex: 1,
    justifyContent: "flex-end",
    backgroundColor: "rgba(0,0,0,0.5)",
  },
  modalContent: {
    backgroundColor: "#FFFFFF",
    paddingBottom: 20,
  },
  modalHeader: {
    flexDirection: "row",
    justifyContent: "flex-end",
    borderBottomColor: "#EEEEEE",
  },
  secondaryButton: {
    backgroundColor: "#FFFFFF",
    borderRadius: 24,
    height: 56,
    justifyContent: "center",
    alignItems: "center",
    marginTop: 16,
    elevation: 1,
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 4,
  },
  secondaryButtonText: {
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: "600",
  },
});
