import { File, Paths } from 'expo-file-system';

/** Resolves a stored photo path against the current Documents directory; null if it is gone. */
export function photoUri(photo: string | null): string | null {
  if (!photo) return null;
  const file = new File(Paths.document, photo);
  return file.exists ? file.uri : null;
}
