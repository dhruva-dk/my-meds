import { join } from 'node:path';
import type { SqlValue } from '@/data/db';
import { openTestDb } from './nodeDb';

/** Table definitions exactly as the pre-1.1 app created them (schema version 2). */
const PROFILE_TABLE = `
  CREATE TABLE profile_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    dob TEXT NOT NULL,
    pcp TEXT,
    healthConditions TEXT,
    pharmacy TEXT
  )`;
const MEDICATION_TABLE = `
  CREATE TABLE medication_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    dosage TEXT NOT NULL,
    additionalInfo TEXT NOT NULL,
    imageUrl TEXT
  )`;
/** Schema version 1, before imageUrl and pharmacy were added. */
const PROFILE_TABLE_V1 = PROFILE_TABLE.replace(',\n    pharmacy TEXT', '');
const MEDICATION_TABLE_V1 = MEDICATION_TABLE.replace(',\n    imageUrl TEXT', '');

type Row = Record<string, SqlValue>;

function writeTable(path: string, ddl: string, table: string, rows: Row[], version: number) {
  const db = openTestDb(path);
  db.exec(ddl);
  for (const row of rows) {
    const columns = Object.keys(row);
    db.run(
      `INSERT INTO ${table} (${columns.join(', ')}) VALUES (${columns.map(() => '?').join(', ')})`,
      Object.values(row),
    );
  }
  db.exec(`PRAGMA user_version = ${version}`);
  db.close();
}

export function writeLegacyProfiles(dir: string, rows: Row[], { v1 = false } = {}) {
  writeTable(
    join(dir, 'UserProfileDatabase.db'),
    v1 ? PROFILE_TABLE_V1 : PROFILE_TABLE,
    'profile_table',
    rows,
    v1 ? 1 : 2,
  );
}

export function writeLegacyMedications(
  dir: string,
  rows: Row[],
  { v1 = false, ddl }: { v1?: boolean; ddl?: string } = {},
) {
  writeTable(
    join(dir, 'MedicationDatabase.db'),
    ddl ?? (v1 ? MEDICATION_TABLE_V1 : MEDICATION_TABLE),
    'medication_table',
    rows,
    v1 ? 1 : 2,
  );
}
