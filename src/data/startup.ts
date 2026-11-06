import { File, Paths } from 'expo-file-system';
import { openAppDatabase, type Documents } from './openAppDatabase';
import { openDeviceDb } from './openDeviceDb';
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
    initStore(openAppDatabase(deviceDocuments()));
    return { ok: true };
  } catch (error) {
    console.error('Could not open data', error);
    return { ok: false, error };
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
    openDb: openDeviceDb,
  };
}
