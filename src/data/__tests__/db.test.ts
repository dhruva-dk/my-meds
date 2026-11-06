import { transaction } from '@/data/db';
import { openTestDb, tempDir } from '../../../test/nodeDb';

describe('Db (node:sqlite adapter)', () => {
  it('round-trips rows through run, get and all', () => {
    const db = openTestDb(`${tempDir()}/a.db`);
    db.exec('CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT, note TEXT)');

    const inserted = db.run('INSERT INTO t (name, note) VALUES (?, ?)', ['Metformin', null]);
    db.run('INSERT INTO t (name, note) VALUES (?, ?)', ['Advil', 'with food']);

    expect(inserted).toEqual({ changes: 1, lastInsertRowId: 1 });
    expect(db.get('SELECT name, note FROM t WHERE id = ?', [1])).toEqual({
      name: 'Metformin',
      note: null,
    });
    expect(db.get('SELECT * FROM t WHERE id = ?', [99])).toBeUndefined();
    expect(db.all('SELECT name FROM t ORDER BY name')).toEqual([
      { name: 'Advil' },
      { name: 'Metformin' },
    ]);
  });
});

describe('transaction', () => {
  it('commits when the function returns and rolls back when it throws', () => {
    const db = openTestDb(`${tempDir()}/b.db`);
    db.exec('CREATE TABLE t (name TEXT NOT NULL)');

    const result = transaction(db, () => {
      db.run('INSERT INTO t VALUES (?)', ['kept']);
      return 'done';
    });
    expect(() =>
      transaction(db, () => {
        db.run('INSERT INTO t VALUES (?)', ['discarded']);
        throw new Error('boom');
      }),
    ).toThrow('boom');

    expect(result).toBe('done');
    expect(db.all('SELECT name FROM t')).toEqual([{ name: 'kept' }]);
  });
});

describe('transaction with an async function', () => {
  it('rolls back and refuses, because the work would finish after COMMIT', () => {
    const db = openTestDb(`${tempDir()}/async.db`);
    db.exec('CREATE TABLE t (name TEXT NOT NULL)');

    expect(() =>
      transaction(db, async () => {
        db.run('INSERT INTO t VALUES (?)', ['too early']);
      }),
    ).toThrow(/synchronous/);
    expect(db.all('SELECT name FROM t')).toEqual([]);
  });
});

describe('opening a database', () => {
  it('enforces foreign keys on every connection', () => {
    const path = `${tempDir()}/c.db`;
    const first = openTestDb(path);
    first.exec(`
      CREATE TABLE parent (id INTEGER PRIMARY KEY);
      CREATE TABLE child (parent_id INTEGER REFERENCES parent (id));
    `);
    first.close();

    const db = openTestDb(path);

    expect(() => db.run('INSERT INTO child VALUES (?)', [42])).toThrow(/FOREIGN KEY/);
  });
});
