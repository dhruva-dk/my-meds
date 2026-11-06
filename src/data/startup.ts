import { File, Paths } from 'expo-file-system';
import type { Db } from './db';
import { openDeviceDb } from './openDeviceDb';
import { prepareDatabase } from './prepareDatabase';
import { initStore } from './store';

const DATABASE_NAME = 'CombinedDatabase.db';
const BACKUP_NAME = 'CombinedDatabase.v1.bak';

export type StartupResult = { ok: true } | { ok: false; error: unknown };

let result: StartupResult | undefined;

/** Opens, migrates and loads the user's data. Runs once per launch. */
export function startApp(): StartupResult {
  result ??= openAndLoad();
  return result;
}

function openAndLoad(): StartupResult {
  let db: Db | undefined;
  try {
    db = openDeviceDb(DATABASE_NAME);
    const backup = new File(Paths.document, BACKUP_NAME);
    prepareDatabase(db, { backupPath: filePath(backup), backupExists: backup.exists });
    initStore(db);
    return { ok: true };
  } catch (error) {
    console.error('Could not open data', error);
    try {
      db?.close();
    } catch {
      // Already failed; the fatal screen is shown either way.
    }
    return { ok: false, error };
  }
}

function filePath(file: File): string {
  return decodeURIComponent(file.uri.replace(/^file:\/\//, ''));
}
