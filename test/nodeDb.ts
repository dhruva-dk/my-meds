import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { configureConnection, type Db, type SqlValue } from '@/data/db';

/** Opens a database file with node:sqlite behind the app's Db interface. */
export function openTestDb(path: string): Db {
  // Start from SQLite's defaults, as expo-sqlite does, so the shared setup is what is tested.
  const db = new DatabaseSync(path, { enableForeignKeyConstraints: false });
  return configureConnection({
    exec: (sql) => db.exec(sql),
    run: (sql, params: SqlValue[] = []) => {
      const result = db.prepare(sql).run(...params);
      return { changes: Number(result.changes), lastInsertRowId: Number(result.lastInsertRowid) };
    },
    get: <T>(sql: string, params: SqlValue[] = []) =>
      db.prepare(sql).get(...params) as T | undefined,
    all: <T>(sql: string, params: SqlValue[] = []) => db.prepare(sql).all(...params) as T[],
    close: () => db.close(),
  });
}

/** A fresh, empty temporary directory. */
export function tempDir(): string {
  return mkdtempSync(join(tmpdir(), 'mymeds-'));
}
