import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import type { Db } from '@/data/db';
import { BACKUP_FILE, openAppDatabase } from '@/data/openAppDatabase';
import { copyFixture, nodeDocuments, openTestDb, tempDir } from '../../../test/nodeDb';

/** Opens the database at `path` the way the app does at launch. */
function prepare(path: string): Db {
  return openAppDatabase(nodeDocuments(dirname(path))).db;
}

function backupPathFor(path: string) {
  return join(dirname(path), BACKUP_FILE);
}

const medicationRows = (db: Db) =>
  db.all(
    `SELECT id, profile_id, name, generic_name, dosage, dosage_form, ndc, additionalInfo, imageUrl
     FROM medications ORDER BY id`,
  );

describe('migrating the seeded 1.2.0 database', () => {
  it('migrates every medication to exactly the expected row', () => {
    const db = prepare(copyFixture('v1-seeded.db'));

    expect(medicationRows(db)).toEqual([
      {
        id: 1,
        profile_id: 2,
        name: 'Lipitor',
        generic_name: 'Atorvastatin Calcium',
        dosage: '',
        dosage_form: 'Tablet, Film Coated',
        ndc: null,
        additionalInfo: '',
        imageUrl: null,
      },
      {
        id: 2,
        profile_id: 2,
        name: 'Metformin',
        generic_name: null,
        dosage: '500 mg',
        dosage_form: null,
        ndc: null,
        additionalInfo: 'Twice daily with meals',
        imageUrl: 'image_picker_BE853A23-58D7-456D-A22B-91B9ED7A719C.jpg',
      },
      {
        id: 3,
        profile_id: 2,
        name: 'Insulin glargine',
        generic_name: null,
        dosage: '10',
        dosage_form: null,
        ndc: null,
        additionalInfo: '',
        imageUrl: null,
      },
      {
        id: 4,
        profile_id: 2,
        name: 'Fish oil',
        generic_name: null,
        dosage: '1 capsule daily',
        dosage_form: null,
        ndc: null,
        additionalInfo: '',
        imageUrl: 'image_picker_9E21B643-C0C6-4540-9401-C76035161FC8.jpg',
      },
      {
        id: 5,
        profile_id: 2,
        name: 'Ibuprofen',
        generic_name: 'Ibuprofen',
        dosage: '200 mg',
        dosage_form: null,
        ndc: null,
        additionalInfo: '',
        imageUrl: null,
      },
      {
        id: 6,
        profile_id: 2,
        name: 'Brand: Advil\nGeneric: Ibuprofen\nTake with food',
        generic_name: null,
        dosage: '',
        dosage_form: null,
        ndc: null,
        additionalInfo: 'Dosage type: Tablet\nRefill in May',
        imageUrl: null,
      },
      {
        id: 7,
        profile_id: 1,
        name: 'Vitamin D',
        generic_name: null,
        dosage: '1000 IU',
        dosage_form: null,
        ndc: null,
        additionalInfo: '',
        imageUrl: 'image_picker_F4DC60E1-C9E7-4B5C-BCB9-DC96667D7202.jpg',
      },
      {
        id: 9,
        profile_id: 3,
        name: 'amoxicillin',
        generic_name: null,
        dosage: '250 mg',
        dosage_form: null,
        ndc: null,
        additionalInfo: 'Finish the full course',
        imageUrl: '',
      },
      {
        id: 10,
        profile_id: 3,
        name: 'Tylenol',
        generic_name: null,
        dosage: '160 mg',
        dosage_form: 'Suspension',
        ndc: null,
        additionalInfo: '',
        imageUrl: '',
      },
    ]);
  });
});

const dump = (db: Db) => ({
  version: db.get('PRAGMA user_version'),
  profiles: db.all('SELECT * FROM profiles ORDER BY id'),
  medications: db.all('SELECT * FROM medications ORDER BY id'),
  appState: db.all('SELECT * FROM app_state'),
});

const activeProfileId = (db: Db) =>
  db.get<{ active_profile_id: number }>('SELECT active_profile_id FROM app_state')
    ?.active_profile_id;

describe('migrating 1.2.0 databases', () => {
  it('keeps profiles unchanged and starts on the profile 1.2.0 showed first', () => {
    const db = prepare(copyFixture('v1-seeded.db'));

    expect(db.all('SELECT * FROM profiles ORDER BY id')).toEqual([
      {
        id: 1,
        name: 'Default Profile',
        dob: '11/05/2026',
        pcp: '',
        healthConditions: '',
        pharmacy: '',
      },
      {
        id: 2,
        name: 'Maria Garcia',
        dob: '03/14/1956',
        pcp: 'Dr. Anil Patel',
        healthConditions: 'Type 2 diabetes, hypertension',
        pharmacy: '(512) 555-0142',
      },
      { id: 3, name: "Sam O'Neil", dob: '11/02/2015', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
    expect(activeProfileId(db)).toBe(1);
    expect(db.get('PRAGMA user_version')).toEqual({ user_version: 2 });
  });

  it('migrates the fresh 1.2.0 database without changing its Default Profile', () => {
    const db = prepare(copyFixture('v1-fresh.db'));

    expect(db.all('SELECT * FROM profiles')).toEqual([
      {
        id: 1,
        name: 'Default Profile',
        dob: '11/05/2026',
        pcp: '',
        healthConditions: '',
        pharmacy: '',
      },
    ]);
    expect(medicationRows(db)).toEqual([]);
    expect(activeProfileId(db)).toBe(1);
  });

  it('changes nothing when run a second time', () => {
    const path = copyFixture('v1-seeded.db');
    const first = dump(prepare(path));

    expect(dump(prepare(path))).toEqual(first);
  });

  it('migrates again after a rollback to 1.2.0 reset the version and added rows', () => {
    const path = copyFixture('v1-seeded.db');
    const db = prepare(path);
    // What 1.2.0 does when it opens the migrated file, then saves an FDA pick.
    db.exec('PRAGMA user_version = 1');
    db.run(
      `INSERT INTO medications (profile_id, name, dosage, additionalInfo, imageUrl)
       VALUES (3, ?, '5 ', 'Dosage type: Tablet', '')`,
      ['Brand: Zyrtec\nGeneric: Cetirizine'],
    );
    db.close();

    const again = prepare(path);

    expect(again.get("SELECT * FROM medications WHERE name = 'Zyrtec'")).toMatchObject({
      generic_name: 'Cetirizine',
      dosage: '5',
      dosage_form: 'Tablet',
      additionalInfo: '',
    });
    expect(again.get('PRAGMA user_version')).toEqual({ user_version: 2 });
  });

  it('drops the generic name and dosage form when 1.2.0 renamed the medication', () => {
    const path = copyFixture('v1-seeded.db');
    const db = prepare(path);
    // After a rollback, 1.2.0 can edit only the columns it knows about.
    db.exec('PRAGMA user_version = 1');
    db.run("UPDATE medications SET name = 'Crestor', dosage = '10 mg' WHERE id = 1");
    db.close();

    const again = prepare(path);

    expect(
      again.get('SELECT name, generic_name, dosage_form FROM medications WHERE id = 1'),
    ).toEqual({ name: 'Crestor', generic_name: null, dosage_form: null });
    expect(again.get('SELECT generic_name FROM medications WHERE id = 5')).toEqual({
      generic_name: 'Ibuprofen',
    });
  });

  it('keeps values saved in 2.0 when migrating again after a rollback', () => {
    const path = copyFixture('v1-seeded.db');
    const db = prepare(path);
    // A note typed in 2.0 that happens to look like what 1.2.0 saved.
    db.run("UPDATE medications SET additionalInfo = 'Dosage type: chewable' WHERE id = 1");
    db.exec('PRAGMA user_version = 1');
    db.close();

    expect(
      prepare(path).get('SELECT dosage_form, additionalInfo FROM medications WHERE id = 1'),
    ).toEqual({ dosage_form: 'Tablet, Film Coated', additionalInfo: 'Dosage type: chewable' });
  });

  it('keeps every column 1.2.0 reads', () => {
    const db = prepare(copyFixture('v1-seeded.db'));
    const columns = (table: string) =>
      db.all<{ name: string }>(`PRAGMA table_info(${table})`).map((column) => column.name);

    expect(columns('profiles')).toEqual(
      expect.arrayContaining(['id', 'name', 'dob', 'pcp', 'healthConditions', 'pharmacy']),
    );
    expect(columns('medications')).toEqual(
      expect.arrayContaining(['id', 'profile_id', 'name', 'dosage', 'additionalInfo', 'imageUrl']),
    );
  });

  it('leaves the original file byte-identical when the migration fails', () => {
    const path = copyFixture('v1-seeded.db');
    const setup = openTestDb(path);
    // An unexpected table shape makes the migration fail after its first steps ran.
    setup.exec('CREATE TABLE app_state (unexpected TEXT)');
    setup.close();
    const before = readFileSync(path);

    expect(() => prepare(path)).toThrow();

    expect(readFileSync(path).equals(before)).toBe(true);
  });

  it('backs up again when a killed launch left the backup unfinished', () => {
    const path = copyFixture('v1-seeded.db');
    writeFileSync(join(dirname(path), `${BACKUP_FILE}.partial`), 'the first half of a backup');
    const original = v1Contents(openTestDb(path));

    prepare(path);

    expect(v1Contents(openTestDb(backupPathFor(path)))).toEqual(original);
    expect(existsSync(join(dirname(path), `${BACKUP_FILE}.partial`))).toBe(false);
  });

  it('backs up the 1.2.0 database exactly once', () => {
    const path = copyFixture('v1-seeded.db');
    const backup = backupPathFor(path);
    const original = v1Contents(openTestDb(path));

    const db = prepare(path);
    const backupBytes = readFileSync(backup);
    // A rollback to 1.2.0 resets the version, so the next launch migrates again.
    db.exec('PRAGMA user_version = 1');
    db.close();
    prepare(path);

    expect(v1Contents(openTestDb(backup))).toEqual(original);
    expect(readFileSync(backup).equals(backupBytes)).toBe(true);
  });
});

const v1Contents = (db: Db) => ({
  version: db.get('PRAGMA user_version'),
  profiles: db.all('SELECT * FROM profiles ORDER BY id'),
  medications: db.all('SELECT * FROM medications ORDER BY id'),
});

describe('a new install', () => {
  it('creates an active Default Profile with no date of birth and no backup', () => {
    const path = join(tempDir(), 'CombinedDatabase.db');
    const db = prepare(path);

    expect(db.all('SELECT * FROM profiles')).toEqual([
      { id: 1, name: 'Default Profile', dob: '', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
    expect(activeProfileId(db)).toBe(1);
    expect(medicationRows(db)).toEqual([]);
    expect(existsSync(backupPathFor(path))).toBe(false);
  });
});

describe('repairing invariants on every launch', () => {
  it('creates Default Profile when no profile exists', () => {
    const path = copyFixture('v1-fresh.db');
    prepare(path).exec('DELETE FROM profiles');

    const db = prepare(path);

    expect(db.all('SELECT name, dob FROM profiles')).toEqual([
      { name: 'Default Profile', dob: '' },
    ]);
    expect(activeProfileId(db)).toBe(db.get<{ id: number }>('SELECT id FROM profiles')?.id);
  });

  it('moves the active profile to the first by name when it no longer exists', () => {
    const path = copyFixture('v1-seeded.db');
    const db = prepare(path);
    db.run('UPDATE app_state SET active_profile_id = 2');
    // After a rollback, 1.2.0 resets the version and deletes a profile without foreign keys,
    // so nothing clears the reference or the profile's medications.
    db.exec('PRAGMA user_version = 1');
    db.exec('PRAGMA foreign_keys = OFF');
    db.run('DELETE FROM profiles WHERE id = 2');
    db.close();

    const again = prepare(path);

    expect(activeProfileId(again)).toBe(1);
    expect(again.all('SELECT id FROM medications WHERE profile_id = 2')).toEqual([]);
  });

  it('keeps an active profile that still exists', () => {
    const path = copyFixture('v1-seeded.db');
    prepare(path).run('UPDATE app_state SET active_profile_id = 3');

    expect(activeProfileId(prepare(path))).toBe(3);
  });
});
