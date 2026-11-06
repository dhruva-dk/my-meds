import { transaction, type Db } from './db';

export const SCHEMA_VERSION = 2;

export type PrepareOptions = {
  /** Filesystem path for the one-time copy of a 1.x database, taken before it is first migrated. */
  backupPath: string;
  backupExists: boolean;
};

/**
 * Brings the database to the current schema and repairs its invariants.
 *
 * Every step only adds, so 1.2.0 can still open the file if 2.0 is pulled. 1.2.0 resets
 * `user_version` to 1 when it opens a newer file, so each step is safe to repeat.
 */
export function prepareDatabase(db: Db, { backupPath, backupExists }: PrepareOptions): void {
  const version = userVersion(db);
  if (version === 1 && !backupExists) {
    db.run('VACUUM INTO ?', [backupPath]);
  }

  transaction(db, () => {
    if (version < SCHEMA_VERSION) {
      createV1Tables(db);
      addV2Schema(db);
      deleteOrphanedMedications(db);
      cleanUpLegacyValues(db);
      db.exec(`PRAGMA user_version = ${SCHEMA_VERSION}`);
    }
    repairInvariants(db);
  });
}

function userVersion(db: Db): number {
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

function addV2Schema(db: Db) {
  const columns = new Set(
    db.all<{ name: string }>('PRAGMA table_info(medications)').map((column) => column.name),
  );
  for (const column of ['generic_name', 'dosage_form', 'ndc']) {
    if (!columns.has(column)) db.exec(`ALTER TABLE medications ADD COLUMN ${column} TEXT`);
  }
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

const UNKNOWN_BRAND = 'Unknown Brand Name';
const UNKNOWN_GENERIC = 'Unknown Generic Name';
const UNKNOWN_FORM = 'Unknown';
const FDA_NAME = /^Brand: ([^\n]*)\nGeneric: ([^\n]*)$/;
const DOSAGE_TYPE = /^Dosage type: ([^\n]*)$/;

type LegacyRow = { id: number; name: string; dosage: string; additionalInfo: string };

/** Splits values 1.2.0 packed into text, but only when the whole value matches exactly. */
function cleanUpLegacyValues(db: Db) {
  const rows = db.all<LegacyRow>('SELECT id, name, dosage, additionalInfo FROM medications');
  for (const row of rows) {
    const nameMatch = FDA_NAME.exec(row.name);
    if (nameMatch) {
      const brand = known(nameMatch[1], UNKNOWN_BRAND);
      const generic = known(nameMatch[2], UNKNOWN_GENERIC);
      const name = brand ?? generic;
      if (name) {
        db.run('UPDATE medications SET name = ?, generic_name = ? WHERE id = ?', [
          name,
          generic,
          row.id,
        ]);
      }
    }

    const formMatch = DOSAGE_TYPE.exec(row.additionalInfo);
    if (formMatch) {
      db.run("UPDATE medications SET dosage_form = ?, additionalInfo = '' WHERE id = ?", [
        known(formMatch[1], UNKNOWN_FORM),
        row.id,
      ]);
    }

    const dosage = row.dosage.trim();
    if (dosage !== row.dosage) {
      db.run('UPDATE medications SET dosage = ? WHERE id = ?', [dosage, row.id]);
    }
  }
}

function known(value: string, placeholder: string): string | null {
  const trimmed = value.trim();
  return trimmed === '' || trimmed === placeholder ? null : trimmed;
}

/** There is always a profile, and the active profile always exists. */
function repairInvariants(db: Db) {
  const anyProfile = db.get('SELECT id FROM profiles LIMIT 1');
  if (!anyProfile) {
    db.run(
      "INSERT INTO profiles (name, dob, pcp, healthConditions, pharmacy) VALUES ('Default Profile', '', '', '', '')",
    );
  }
  db.run('INSERT OR IGNORE INTO app_state (id) VALUES (1)');
  db.run(`
    UPDATE app_state
    SET active_profile_id = (SELECT id FROM profiles ORDER BY name COLLATE NOCASE, id LIMIT 1)
    WHERE id = 1
      AND (active_profile_id IS NULL
        OR active_profile_id NOT IN (SELECT id FROM profiles))
  `);
}
