import type { Db } from './db';
import { insertDefaultProfile } from './invariants';

/** Absolute paths of copies of the pre-1.1 database files, if they exist. */
export type LegacyFiles = { profilesPath?: string; medicationsPath?: string };

/** Which legacy files are attached to the connection, and how to detach them. */
export type AttachedLegacy = { profiles: boolean; medications: boolean; detach(): void };

const PROFILES = 'legacy_profiles';
const MEDICATIONS = 'legacy_medications';

/** Attaches the legacy files. Must run outside a transaction, as must `detach`. */
export function attachLegacy(db: Db, files: LegacyFiles): AttachedLegacy {
  const profiles = attach(db, files.profilesPath, PROFILES);
  const medications = attach(db, files.medicationsPath, MEDICATIONS);
  return {
    profiles,
    medications,
    detach: () => {
      if (profiles) detach(db, PROFILES);
      if (medications) detach(db, MEDICATIONS);
    },
  };
}

function attach(db: Db, path: string | undefined, schema: string): boolean {
  if (!path) return false;
  try {
    db.run(`ATTACH DATABASE ? AS ${schema}`, [path]);
    return true;
  } catch (error) {
    // A damaged file would otherwise block every launch; there is nothing in it to import.
    if (/not a database/i.test(String(error))) {
      console.warn(`Skipping unreadable legacy database ${schema}`, error);
      return false;
    }
    throw error;
  }
}

function detach(db: Db, schema: string) {
  try {
    db.exec(`DETACH DATABASE ${schema}`);
  } catch (error) {
    // Don't hide the error that ended the import.
    console.warn(`Could not detach ${schema}`, error);
  }
}

type LegacyProfile = {
  id: number;
  name: string;
  dob: string;
  pcp?: string | null;
  healthConditions?: string | null;
  pharmacy?: string | null;
};

type LegacyMedication = {
  id: number;
  name: string;
  dosage: string | null;
  additionalInfo: string | null;
  imageUrl?: string | null;
};

/**
 * Copies the first legacy profile (or a new Default Profile) and every legacy medication,
 * keeping their ids, into the new combined tables. Runs inside the migration transaction.
 */
export function importLegacy(db: Db, legacy: AttachedLegacy): void {
  const profile =
    legacy.profiles && hasTable(db, PROFILES, 'profile_table')
      ? db.get<LegacyProfile>(`SELECT * FROM ${PROFILES}.profile_table ORDER BY id LIMIT 1`)
      : undefined;

  const profileId = profile
    ? db.run(
        `INSERT INTO profiles (id, name, dob, pcp, healthConditions, pharmacy)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          profile.id,
          profile.name,
          profile.dob,
          profile.pcp ?? '',
          profile.healthConditions ?? '',
          profile.pharmacy ?? '',
        ],
      ).lastInsertRowId
    : insertDefaultProfile(db);

  if (!legacy.medications || !hasTable(db, MEDICATIONS, 'medication_table')) return;
  const medications = db.all<LegacyMedication>(
    `SELECT * FROM ${MEDICATIONS}.medication_table ORDER BY id`,
  );
  for (const medication of medications) {
    db.run(
      `INSERT INTO medications (id, profile_id, name, dosage, additionalInfo, imageUrl)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        medication.id,
        profileId,
        medication.name,
        medication.dosage ?? '',
        medication.additionalInfo ?? '',
        fileName(medication.imageUrl),
      ],
    );
  }
}

/** An empty legacy file attaches fine but has no tables. */
function hasTable(db: Db, schema: string, table: string): boolean {
  return !!db.get(`SELECT 1 FROM ${schema}.sqlite_master WHERE type = 'table' AND name = ?`, [
    table,
  ]);
}

/** Legacy versions stored full paths; photos are found by filename in Documents. */
function fileName(imageUrl: string | null | undefined): string | null {
  return imageUrl?.split('/').pop() || null;
}
