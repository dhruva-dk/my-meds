import { Alert, Linking } from 'react-native';

export function showFailure(title: string, error?: unknown) {
  if (error) console.error(title, error);
  Alert.alert(title, 'Please try again.');
}

export function confirmDelete(title: string, message: string, onDelete: () => void) {
  Alert.alert(title, message, [
    { text: 'Cancel', style: 'cancel' },
    { text: 'Delete', style: 'destructive', onPress: onDelete },
  ]);
}

export function confirmLeave(onLeave: () => void) {
  Alert.alert('Leave without saving?', undefined, [
    { text: 'Keep Editing', style: 'cancel' },
    { text: 'Discard Changes', style: 'destructive', onPress: onLeave },
  ]);
}

export function showCameraDenied() {
  Alert.alert('Camera Access Is Off', 'Turn on camera access in Settings to take a photo.', [
    { text: 'Cancel', style: 'cancel' },
    { text: 'Open Settings', onPress: () => void Linking.openSettings() },
  ]);
}
