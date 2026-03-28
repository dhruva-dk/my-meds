import * as FileSystem from 'expo-file-system';
import { Platform } from 'react-native';

/**
 * Copies a temporary image picker URI to a permanent location in the document directory.
 * Returns the new permanent file:// URI.
 */
export async function saveImageToLocal(tempUri: string): Promise<string> {
  if (!tempUri.startsWith('file://')) {
    // Already migrated or remote
    return tempUri;
  }
  
  const filename = tempUri.split('/').pop() || `image_${Date.now()}.jpg`;
  const ext = filename.split('.').pop() || 'jpg';
  // generate a unique filename to avoid collisions
  const uniqueFilename = `perma_${Date.now()}_${Math.random().toString(36).substring(7)}.${ext}`;
  // @ts-ignore
  const destUri = `${FileSystem.documentDirectory}${uniqueFilename}`;
  
  try {
    await FileSystem.copyAsync({
      from: tempUri,
      to: destUri
    });
    return destUri;
  } catch (error) {
    console.error("Failed to save image to local storage:", error);
    return tempUri; // fallback to temp if fails
  }
}

/**
 * Resolves a legacy image filename (e.g. from Flutter migration) to a valid local file URI.
 * If the provided string is already a valid URI, it returns it unchanged.
 */
export function resolveLocalImageUri(uriOrFilename: string): string {
  if (!uriOrFilename) return uriOrFilename;
  
  // If it already starts with file:// or http:// or https:// it is absolute
  if (uriOrFilename.startsWith('file://') || uriOrFilename.startsWith('http://') || uriOrFilename.startsWith('https://')) {
    return uriOrFilename;
  }

  // Legacy Flutter basename (e.g. image_picker_...jpg)
  if (Platform.OS === 'android') {
    // Flutter saves inside app_flutter on Android via path_provider
    return `file:///data/user/0/com.dhruvakumar.medication_tracker/app_flutter/${uriOrFilename}`;
  } else {
    // Flutter saves inside NSDocumentDirectory on iOS
    // @ts-ignore
    return `${FileSystem.documentDirectory}${uriOrFilename}`;
  }
}
