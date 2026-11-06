import { assertSynchronous, transaction, type Db } from './db';
import { repairInvariants } from './invariants';
import { loadSnapshot, type Snapshot } from './snapshot';

let db: Db | null = null;
let snapshot: Snapshot | null = null;
const listeners = new Set<() => void>();

/** Points the store at a prepared database and the snapshot loaded when it was prepared. */
export function initStore(database: Db, first: Snapshot): void {
  db = database;
  snapshot = first;
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
 * The only way data changes: runs `fn`, repairs the invariants and rebuilds the snapshot,
 * all in one transaction. If any step throws, it rolls back and the snapshot stays as it was.
 */
export function commit<T>(fn: (db: Db) => T): T {
  if (!db) throw new Error('initStore must run before a commit.');
  const database = db;
  const [result, next] = transaction(database, () => {
    const value = assertSynchronous(fn(database));
    repairInvariants(database);
    return [value, loadSnapshot(database)] as const;
  });
  snapshot = next;
  listeners.forEach((listener) => listener());
  return result;
}
