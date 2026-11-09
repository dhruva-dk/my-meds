import type { Db } from './db';

/** The folder inside Documents that 2.0 owns. Photos from 1.2.0 sit directly in Documents. */
export const PHOTOS_FOLDER = 'images';

/** The device's photo storage. Paths are relative to Documents, as saved in the database. */
export type PhotoFiles = {
  /** Compresses a picked photo into the app-owned folder and returns its relative path. */
  store(sourceUri: string): Promise<string>;
  /** Every file in the app-owned folder. */
  list(): string[];
  remove(path: string): void;
};

/** True only for a file directly inside the app-owned folder. */
export function isAppOwnedPhoto(path: string | null): path is string {
  if (!path) return false;
  const [folder, name, ...rest] = path.split('/');
  return folder === PHOTOS_FOLDER && !!name && name !== '.' && name !== '..' && rest.length === 0;
}

/** Deletes files that a committed change left unreferenced. A leftover file is harmless. */
export function removePhotos(files: PhotoFiles, paths: (string | null)[]): void {
  for (const path of paths) {
    if (!isAppOwnedPhoto(path)) continue;
    try {
      files.remove(path);
    } catch (error) {
      console.warn('Could not delete a photo file', error);
    }
  }
}

/** Removes files in the app-owned folder that no medication references. */
export function removeUnreferencedPhotos(db: Db, files: PhotoFiles): void {
  const referenced = new Set(
    db
      .all<{ imageUrl: string }>('SELECT imageUrl FROM medications WHERE imageUrl IS NOT NULL')
      .map((row) => row.imageUrl),
  );
  removePhotos(
    files,
    files.list().filter((path) => !referenced.has(path)),
  );
}

/** The size to resize to so the long edge is at most `limit`, or null if it already fits. */
export function fitLongEdge(
  width: number,
  height: number,
  limit: number,
): { width: number } | { height: number } | null {
  if (Math.max(width, height) <= limit) return null;
  return width >= height ? { width: limit } : { height: limit };
}
