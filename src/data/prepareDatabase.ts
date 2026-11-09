import { transaction, type Db } from './db';
import { repairInvariants } from './invariants';
import { attachLegacy, importLegacy, type AttachedLegacy, type LegacyFiles } from './legacyImport';
import { loadSnapshot, type Snapshot } from './snapshot';

export const SCHEMA_VERSION = 2;

/**
 * Brings the database to the current schema, repairs its invariants and loads the first
 * snapshot, all in one transaction: if anything fails, nothing was changed.
 *
 * Every step only adds, so 1.2.0 can still open the file if 2.0 is pulled. 1.2.0 resets
 * `user_version` to 1 when it opens a newer file, so each step is safe to repeat.
 *
 * `legacy` names pre-1.1 databases to import if this database has never been set up.
 */
export function prepareDatabase(db: Db, legacy: LegacyFiles = {}): Snapshot {
  const version = userVersion(db);
  const isEmpty = version === 0 && !db.get("SELECT 1 FROM sqlite_master WHERE name = 'profiles'");
  const attached = isEmpty ? attachLegacy(db, legacy) : null;
  try {
    return transaction(db, () => {
      if (version < SCHEMA_VERSION) migrate(db, attached);
      repairInvariants(db);
      return loadSnapshot(db);
    });
  } finally {
    attached?.detach();
  }
}

function migrate(db: Db, legacy: AttachedLegacy | null) {
  createV1Tables(db);
  if (legacy) importLegacy(db, legacy);
  addAppState(db);
  deleteOrphanedMedications(db);
  db.exec(`PRAGMA user_version = ${SCHEMA_VERSION}`);
}

export function userVersion(db: Db): number {
  return db.get<{ user_version: number }>('PRAGMA user_version')?.user_version ?? 0;
}

/** The tables exactly as 1.2.0 creates them, for fresh installs. */
function createV1Tables(db: Db) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS profiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      dob TEXT NOT NULL,
      pcp TEXT,
      healthConditions TEXT,
      pharmacy TEXT
    );
    CREATE TABLE IF NOT EXISTS medications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      dosage TEXT NOT NULL,
      additionalInfo TEXT NOT NULL,
      imageUrl TEXT,
      FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
    );
  `);
}

function addAppState(db: Db) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS app_state (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      active_profile_id INTEGER REFERENCES profiles (id) ON DELETE SET NULL
    );
  `);
}

/** 1.2.0 never enabled foreign keys, so deleting a profile left its medications behind. */
function deleteOrphanedMedications(db: Db) {
  db.run('DELETE FROM medications WHERE profile_id NOT IN (SELECT id FROM profiles)');
}
