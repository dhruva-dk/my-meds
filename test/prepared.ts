import { dirname } from 'node:path';
import type { Db } from '@/data/db';
import { openAppDatabase } from '@/data/openAppDatabase';
import type { Snapshot } from '@/data/snapshot';
import { copyFixture, nodeDocuments } from './nodeDb';

/** Opens a copy of a 1.2.0 fixture the way the app does at launch. */
export function openFixture(name: 'v1-fresh.db' | 'v1-seeded.db'): { db: Db; snapshot: Snapshot } {
  return openAppDatabase(nodeDocuments(dirname(copyFixture(name))));
}

export function preparedFixture(name: 'v1-fresh.db' | 'v1-seeded.db'): Db {
  return openFixture(name).db;
}
