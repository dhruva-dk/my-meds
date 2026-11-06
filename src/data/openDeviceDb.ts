import { Paths } from 'expo-file-system';
import { openDatabaseSync } from 'expo-sqlite';
import { configureConnection, type Db, type SqlValue } from './db';

/** Opens a database file directly in the app's Documents directory, where 1.x kept it. */
export function openDeviceDb(fileName: string): Db {
  const db = openDatabaseSync(fileName, undefined, Paths.document.uri);
  return configureConnection({
    exec: (sql) => db.execSync(sql),
    run: (sql, params: SqlValue[] = []) => {
      const result = db.runSync(sql, params);
      return { changes: result.changes, lastInsertRowId: result.lastInsertRowId };
    },
    get: <T>(sql: string, params: SqlValue[] = []) => db.getFirstSync<T>(sql, params) ?? undefined,
    all: <T>(sql: string, params: SqlValue[] = []) => db.getAllSync<T>(sql, params),
    close: () => db.closeSync(),
  });
}
