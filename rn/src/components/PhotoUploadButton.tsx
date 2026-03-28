import React from "react";
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  Alert,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { AppColors } from "../styles/theme";

interface PhotoUploadButtonProps {
  onTakePhoto: () => void;
  onUploadPhoto: () => void;
  hasImage?: boolean;
  style?: ViewStyle;
}

export default function PhotoUploadButton({
  onTakePhoto,
  onUploadPhoto,
  hasImage = false,
  style,
}: PhotoUploadButtonProps) {
  const showOptions = () => {
    Alert.alert("Upload Photo", "Choose a photo source", [
      { text: "Cancel", style: "cancel" },
      { text: "Camera", onPress: onTakePhoto },
      { text: "Gallery", onPress: onUploadPhoto },
    ]);
  };

  return (
    <TouchableOpacity
      style={[styles.button, style]}
      onPress={showOptions}
      activeOpacity={0.7}
    >
      <Ionicons name="camera" size={20} color={AppColors.primary} />
      <Text style={styles.text}>
        {hasImage ? "Change Photo" : "Upload Photo"}
      </Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderRadius: 24,
    backgroundColor: "#FFFFFF",
    minHeight: 50,
  },
  text: {
    color: AppColors.primary,
    fontWeight: "600",
    marginLeft: 8,
    fontSize: 14,
  },
});
