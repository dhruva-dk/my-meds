import { copyFileSync, existsSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { configureConnection, type Db, type SqlValue } from '@/data/db';
import type { Documents } from '@/data/openAppDatabase';

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

/** Copies a committed 1.2.0 fixture database into a fresh temporary directory. */
export function copyFixture(name: 'v1-fresh.db' | 'v1-seeded.db'): string {
  const path = join(tempDir(), 'CombinedDatabase.db');
  copyFileSync(join(__dirname, 'fixtures', name), path);
  return path;
}

/** The app's Documents directory, backed by a real directory on disk. */
export function nodeDocuments(dir: string = tempDir()): Documents {
  return {
    path: dir,
    exists: (name) => existsSync(join(dir, name)),
    remove: (name) => rmSync(join(dir, name), { force: true }),
    openDb: (name) => openTestDb(join(dir, name)),
  };
}
