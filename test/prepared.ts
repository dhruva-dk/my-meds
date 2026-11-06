import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import type { Db } from '@/data/db';
import { prepareDatabase } from '@/data/prepareDatabase';
import { copyFixture, openTestDb } from './nodeDb';

/** Opens a copy of a 1.2.0 fixture, migrated and repaired the way the app does at launch. */
export function preparedFixture(name: 'v1-fresh.db' | 'v1-seeded.db'): Db {
  const path = copyFixture(name);
  const db = openTestDb(path);
  const backupPath = join(dirname(path), 'CombinedDatabase.v1.bak');
  prepareDatabase(db, { backupPath, backupExists: existsSync(backupPath) });
  return db;
}
