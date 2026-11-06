import type { Db } from './db';
import type { LegacyFiles } from './legacyImport';
import { prepareDatabase, userVersion } from './prepareDatabase';
import type { Snapshot } from './snapshot';

/** The app's Documents directory, where 1.x kept its databases and photos. */
export type Documents = {
  /** Absolute filesystem path, for SQLite. */
  path: string;
  exists(name: string): boolean;
  /** Does nothing if the file doesn't exist. */
  remove(name: string): void;
  /** Replaces `to` if it exists. */
  copy(from: string, to: string): void;
  /** Replaces `to` if it exists. */
  move(from: string, to: string): void;
  openDb(name: string): Db;
};

export const DATABASE_FILE = 'CombinedDatabase.db';
export const BACKUP_FILE = 'CombinedDatabase.v1.bak';
const PARTIAL_BACKUP_FILE = 'CombinedDatabase.v1.bak.partial';
const LEGACY_PROFILES_FILE = 'UserProfileDatabase.db';
const LEGACY_MEDICATIONS_FILE = 'MedicationDatabase.db';

/**
 * Opens the combined database, backs up a 1.x database once, and migrates it.
 * A database that has never been set up (missing, or left empty by 1.2.0's crashed import)
 * is filled from pre-1.1 databases if any. A new database that can't be prepared is removed.
 */
export function openAppDatabase(documents: Documents): { db: Db; snapshot: Snapshot } {
  const isNew = !documents.exists(DATABASE_FILE);
  const db = documents.openDb(DATABASE_FILE);
  const legacyCopies: string[] = [];
  try {
    const version = userVersion(db);
    if (version === 1 && !documents.exists(BACKUP_FILE)) backUp(db, documents);
    const legacy: LegacyFiles =
      version === 0
        ? {
            profilesPath: copyLegacy(documents, LEGACY_PROFILES_FILE, legacyCopies),
            medicationsPath: copyLegacy(documents, LEGACY_MEDICATIONS_FILE, legacyCopies),
          }
        : {};
    return { db, snapshot: prepareDatabase(db, legacy) };
  } catch (error) {
    closeQuietly(db);
    if (isNew) {
      documents.remove(DATABASE_FILE);
      documents.remove(`${DATABASE_FILE}-journal`);
    }
    throw error;
  } finally {
    legacyCopies.forEach((name) => documents.remove(name));
  }
}

/** A consistent copy, renamed into place only once complete, so a partial one never counts. */
function backUp(db: Db, documents: Documents) {
  documents.remove(PARTIAL_BACKUP_FILE);
  db.run('VACUUM INTO ?', [`${documents.path}/${PARTIAL_BACKUP_FILE}`]);
  documents.move(PARTIAL_BACKUP_FILE, BACKUP_FILE);
}

/**
 * Even reading a database can change it: SQLite rolls back a leftover journal into the file.
 * The import reads copies, so legacy files are never changed.
 */
function copyLegacy(documents: Documents, name: string, copies: string[]): string | undefined {
  if (!documents.exists(name)) return undefined;
  const copy = name.replace(/\.db$/, '.import.db');
  copies.push(copy, `${copy}-journal`);
  documents.remove(`${copy}-journal`);
  documents.copy(name, copy);
  if (documents.exists(`${name}-journal`)) documents.copy(`${name}-journal`, `${copy}-journal`);
  return `${documents.path}/${copy}`;
}

function closeQuietly(db: Db) {
  try {
    db.close();
  } catch (error) {
    console.warn('Could not close the database', error);
  }
}
