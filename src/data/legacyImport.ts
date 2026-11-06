import type { Db, SqlValue } from './db';

/** Absolute paths of the pre-1.1 database files that exist, if any. */
export type LegacyFiles = { profilesPath?: string; medicationsPath?: string };

const PROFILES = 'legacy_profiles';
const MEDICATIONS = 'legacy_medications';

/** Attaches the legacy files read-only by convention: the import only ever SELECTs from them. */
export function attachLegacy(db: Db, files: LegacyFiles): () => void {
  const attached: string[] = [];
  const attach = (path: string | undefined, schema: string) => {
    if (!path) return;
    db.run(`ATTACH DATABASE ? AS ${schema}`, [path]);
    attached.push(schema);
  };
  attach(files.profilesPath, PROFILES);
  attach(files.medicationsPath, MEDICATIONS);
  return () => attached.forEach((schema) => db.exec(`DETACH DATABASE ${schema}`));
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
export function importLegacy(db: Db): void {
  const profile = hasTable(db, PROFILES, 'profile_table')
    ? db.get<LegacyProfile>(`SELECT * FROM ${PROFILES}.profile_table ORDER BY id LIMIT 1`)
    : undefined;

  const profileId = profile
    ? insertProfile(db, [
        profile.id,
        profile.name,
        profile.dob,
        profile.pcp ?? '',
        profile.healthConditions ?? '',
        profile.pharmacy ?? '',
      ])
    : insertProfile(db, [null, 'Default Profile', '', '', '', '']);

  if (!hasTable(db, MEDICATIONS, 'medication_table')) return;
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

function hasTable(db: Db, schema: string, table: string): boolean {
  try {
    return !!db.get(`SELECT name FROM ${schema}.sqlite_master WHERE type = 'table' AND name = ?`, [
      table,
    ]);
  } catch {
    // The file was not attached.
    return false;
  }
}

function insertProfile(db: Db, values: SqlValue[]): number {
  return db.run(
    `INSERT INTO profiles (id, name, dob, pcp, healthConditions, pharmacy)
     VALUES (?, ?, ?, ?, ?, ?)`,
    values,
  ).lastInsertRowId;
}

/** Legacy versions stored full paths; photos are found by filename in Documents. */
function fileName(imageUrl: string | null | undefined): string | null {
  const name = imageUrl?.split('/').pop()?.trim();
  return name ? name : null;
}
