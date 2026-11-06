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
  addV2Schema(db);
  dropDetailsOfRenamedMedications(db);
  deleteOrphanedMedications(db);
  cleanUpLegacyValues(db);
  db.run('UPDATE medications SET details_name = name');
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

function addV2Schema(db: Db) {
  const columns = new Set(
    db.all<{ name: string }>('PRAGMA table_info(medications)').map((column) => column.name),
  );
  // details_name is the name the generic name, dosage form and NDC were saved with.
  // 2.0 sets it on every save; 1.2.0 doesn't know it, so it detects renames made in 1.2.0.
  for (const column of ['generic_name', 'dosage_form', 'ndc', 'details_name']) {
    if (!columns.has(column)) db.exec(`ALTER TABLE medications ADD COLUMN ${column} TEXT`);
  }
  db.exec(`
    CREATE TABLE IF NOT EXISTS app_state (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      active_profile_id INTEGER REFERENCES profiles (id) ON DELETE SET NULL
    );
  `);
}

/** After a rollback, 1.2.0 can rename a medication; its 2.0 details then describe another drug. */
function dropDetailsOfRenamedMedications(db: Db) {
  db.run(`
    UPDATE medications SET generic_name = NULL, dosage_form = NULL, ndc = NULL
    WHERE details_name IS NOT name
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

type LegacyRow = {
  id: number;
  name: string;
  generic_name: string | null;
  dosage: string;
  dosage_form: string | null;
  additionalInfo: string;
};

/**
 * Splits values 1.2.0 packed into text, but only when the whole value matches exactly and
 * the value it fills is empty, so it never overwrites what 2.0 saved.
 */
function cleanUpLegacyValues(db: Db) {
  const rows = db.all<LegacyRow>(
    'SELECT id, name, generic_name, dosage, dosage_form, additionalInfo FROM medications',
  );
  for (const row of rows) {
    const nameMatch = row.generic_name === null ? FDA_NAME.exec(row.name) : null;
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

    const formMatch = row.dosage_form === null ? DOSAGE_TYPE.exec(row.additionalInfo) : null;
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
