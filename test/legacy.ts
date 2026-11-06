import { copyFileSync } from 'node:fs';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import type { SqlValue } from '@/data/db';
import { openTestDb, tempDir } from './nodeDb';

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

/**
 * Leaves `name` as the old app would if it were killed mid-write: a hot journal next to a
 * file that already holds part of an unfinished change.
 */
export function leaveHotJournal(dir: string, name: string, unfinishedChange: string) {
  const scratch = join(tempDir(), name);
  copyFileSync(join(dir, name), scratch);
  const db = new DatabaseSync(scratch);
  // A tiny page cache makes SQLite write changed pages to the file before committing.
  db.exec('PRAGMA cache_size = 1');
  db.exec('BEGIN');
  db.exec(unfinishedChange);
  copyFileSync(scratch, join(dir, name));
  copyFileSync(`${scratch}-journal`, join(dir, `${name}-journal`));
  db.exec('ROLLBACK');
  db.close();
}
