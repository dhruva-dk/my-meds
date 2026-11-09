import * as ImagePicker from 'expo-image-picker';
import { showCameraDenied, showFailure } from './alerts';

export type PhotoSource = 'camera' | 'library';

/** The URI of a photo the user chose, or null if they cancelled or it failed. */
export async function pickPhoto(source: PhotoSource): Promise<string | null> {
  try {
    if (source === 'camera') {
      const permission = await ImagePicker.requestCameraPermissionsAsync();
      if (!permission.granted) {
        showCameraDenied();
        return null;
      }
    }
    const options: ImagePicker.ImagePickerOptions = { mediaTypes: ['images'], quality: 1 };
    const result =
      source === 'camera'
        ? await ImagePicker.launchCameraAsync(options)
        : await ImagePicker.launchImageLibraryAsync(options);
    return result.canceled ? null : (result.assets[0]?.uri ?? null);
  } catch (error) {
    showFailure(source === 'camera' ? "Couldn't Open the Camera" : "Couldn't Open Photos", error);
    return null;
  }
}
