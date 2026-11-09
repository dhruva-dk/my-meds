import { File, Paths } from 'expo-file-system';
import type { Db } from './db';
import { devicePhotoFiles } from './devicePhotoFiles';
import { openAppDatabase, type Documents } from './openAppDatabase';
import { openDeviceDb } from './openDeviceDb';
import { removeUnreferencedPhotos } from './photoFiles';
import { initStore } from './store';

export type StartupResult = { ok: true } | { ok: false; error: unknown };

let result: StartupResult | undefined;

/** Opens, migrates and loads the user's data. Runs once per launch. */
export function startApp(): StartupResult {
  result ??= openAndLoad();
  return result;
}

function openAndLoad(): StartupResult {
  try {
    const { db, snapshot } = openAppDatabase(deviceDocuments());
    initStore(db, snapshot, devicePhotoFiles);
    cleanUpPhotos(db);
    return { ok: true };
  } catch (error) {
    console.error('Could not open data', error);
    return { ok: false, error };
  }
}

/** A file left over is harmless, so a failure here must not stop the app opening. */
function cleanUpPhotos(db: Db) {
  try {
    removeUnreferencedPhotos(db, devicePhotoFiles);
  } catch (error) {
    console.warn('Could not clean up photos', error);
  }
}

function deviceDocuments(): Documents {
  return {
    path: decodeURIComponent(Paths.document.uri.replace(/^file:\/\//, '').replace(/\/$/, '')),
    exists: (name) => new File(Paths.document, name).exists,
    remove: (name) => {
      const file = new File(Paths.document, name);
      if (file.exists) file.delete();
    },
    copy: (from, to) =>
      new File(Paths.document, from).copySync(new File(Paths.document, to), { overwrite: true }),
    move: (from, to) =>
      new File(Paths.document, from).moveSync(new File(Paths.document, to), { overwrite: true }),
    openDb: openDeviceDb,
  };
}
