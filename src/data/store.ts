import { transaction, type Db } from './db';
import { loadSnapshot, type Snapshot } from './snapshot';

let db: Db | null = null;
let snapshot: Snapshot | null = null;
const listeners = new Set<() => void>();

/** Points the store at a prepared database and loads the first snapshot. */
export function initStore(database: Db): void {
  db = database;
  snapshot = loadSnapshot(database);
  listeners.forEach((listener) => listener());
}

export function getSnapshot(): Snapshot {
  if (!snapshot) throw new Error('initStore must run before the snapshot is read.');
  return snapshot;
}

export function subscribe(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

/**
 * The only way data changes: runs `fn` in one transaction, then rebuilds the snapshot.
 * If `fn` throws, the transaction rolls back and the snapshot stays as it was.
 */
export function commit<T>(fn: (db: Db) => T): T {
  if (!db) throw new Error('initStore must run before a commit.');
  const database = db;
  const result = transaction(database, () => fn(database));
  snapshot = loadSnapshot(database);
  listeners.forEach((listener) => listener());
  return result;
}
