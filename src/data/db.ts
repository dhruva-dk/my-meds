export type SqlValue = string | number | null;

export type RunResult = { changes: number; lastInsertRowId: number };

/**
 * The synchronous SQLite surface the app uses. The app opens it with expo-sqlite;
 * unit tests open the same interface with node:sqlite against real database files.
 */
export interface Db {
  /** Runs one or more statements without parameters. */
  exec(sql: string): void;
  run(sql: string, params?: SqlValue[]): RunResult;
  get<T>(sql: string, params?: SqlValue[]): T | undefined;
  all<T>(sql: string, params?: SqlValue[]): T[];
  close(): void;
}

/** Runs `fn` in a transaction: commits if it returns, rolls back and rethrows if it throws. */
export function transaction<T>(db: Db, fn: () => T): T {
  db.exec('BEGIN');
  try {
    const result = assertSynchronous(fn());
    db.exec('COMMIT');
    return result;
  } catch (error) {
    try {
      db.exec('ROLLBACK');
    } catch {
      // SQLite may already have rolled back (for example on a full disk).
    }
    throw error;
  }
}

/** Per-connection settings every adapter applies right after opening. */
export function configureConnection(db: Db): Db {
  db.exec('PRAGMA foreign_keys = ON');
  return db;
}

/** Writes must finish inside their transaction; awaited work would run after COMMIT. */
export function assertSynchronous<T>(value: T): T {
  if (typeof (value as { then?: unknown } | null)?.then === 'function') {
    throw new Error(
      'Database writes need a synchronous function; awaited work would run after COMMIT.',
    );
  }
  return value;
}
