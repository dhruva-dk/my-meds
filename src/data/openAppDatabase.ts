import type { Db } from './db';
import type { LegacyFiles } from './legacyImport';
import { prepareDatabase } from './prepareDatabase';

/** The app's Documents directory, where 1.x kept its databases and photos. */
export type Documents = {
  /** Absolute filesystem path, for SQLite. */
  path: string;
  exists(name: string): boolean;
  remove(name: string): void;
  openDb(name: string): Db;
};

export const DATABASE_FILE = 'CombinedDatabase.db';
const BACKUP_FILE = 'CombinedDatabase.v1.bak';
const LEGACY_PROFILES_FILE = 'UserProfileDatabase.db';
const LEGACY_MEDICATIONS_FILE = 'MedicationDatabase.db';

/**
 * Opens the combined database and migrates it. A database that has never been set up
 * (missing, or left empty by 1.2.0's crashed import) is filled from pre-1.1 databases if any.
 * If a new database can't be prepared, it is removed so the next launch starts clean.
 */
export function openAppDatabase(documents: Documents): Db {
  const isNew = !documents.exists(DATABASE_FILE);
  const legacy: LegacyFiles = {};
  if (documents.exists(LEGACY_PROFILES_FILE)) {
    legacy.profilesPath = `${documents.path}/${LEGACY_PROFILES_FILE}`;
  }
  if (documents.exists(LEGACY_MEDICATIONS_FILE)) {
    legacy.medicationsPath = `${documents.path}/${LEGACY_MEDICATIONS_FILE}`;
  }

  const db = documents.openDb(DATABASE_FILE);
  try {
    prepareDatabase(db, {
      backupPath: `${documents.path}/${BACKUP_FILE}`,
      backupExists: documents.exists(BACKUP_FILE),
      legacy,
    });
    return db;
  } catch (error) {
    db.close();
    if (isNew) {
      documents.remove(DATABASE_FILE);
      documents.remove(`${DATABASE_FILE}-journal`);
    }
    throw error;
  }
}
