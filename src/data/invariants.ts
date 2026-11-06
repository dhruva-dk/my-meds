import type { Db } from './db';

export function insertDefaultProfile(db: Db): number {
  return db.run(
    "INSERT INTO profiles (name, dob, pcp, healthConditions, pharmacy) VALUES ('Default Profile', '', '', '', '')",
  ).lastInsertRowId;
}

/**
 * There is always a profile, and the active profile always exists.
 * Runs at the end of every write transaction, so no write can break either.
 */
export function repairInvariants(db: Db): void {
  if (!db.get('SELECT id FROM profiles LIMIT 1')) insertDefaultProfile(db);
  db.run('INSERT OR IGNORE INTO app_state (id) VALUES (1)');
  db.run(`
    UPDATE app_state
    SET active_profile_id = (SELECT id FROM profiles ORDER BY name COLLATE NOCASE, id LIMIT 1)
    WHERE id = 1
      AND (active_profile_id IS NULL
        OR active_profile_id NOT IN (SELECT id FROM profiles))
  `);
}
