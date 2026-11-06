import { createHash } from 'node:crypto';
import { readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import type { Db } from '@/data/db';
import { openAppDatabase } from '@/data/openAppDatabase';
import { leaveHotJournal, writeLegacyMedications, writeLegacyProfiles } from '../../../test/legacy';
import { nodeDocuments, openTestDb, tempDir } from '../../../test/nodeDb';

const profiles = (db: Db) => db.all('SELECT * FROM profiles ORDER BY id');
const medications = (db: Db) =>
  db.all(
    'SELECT id, profile_id, name, dosage, additionalInfo, imageUrl FROM medications ORDER BY id',
  );
const activeProfileId = (db: Db) =>
  db.get<{ active_profile_id: number }>('SELECT active_profile_id FROM app_state')
    ?.active_profile_id;

const maria = {
  id: 4,
  name: 'Maria Garcia',
  dob: '03/14/1956',
  pcp: 'Dr. Patel',
  healthConditions: 'Hypertension',
  pharmacy: '(512) 555-0142',
};

describe('importing pre-merge databases', () => {
  it('imports the first legacy profile and all medications with their ids', () => {
    const dir = tempDir();
    writeLegacyProfiles(dir, [maria, { id: 7, name: 'Second', dob: '01/01/2000' }]);
    writeLegacyMedications(dir, [
      {
        id: 3,
        name: 'Metformin',
        dosage: '500 mg',
        additionalInfo: 'With meals',
        imageUrl: '/var/mobile/Containers/Data/Application/OLD/Documents/image_picker_A.jpg',
      },
      { id: 8, name: 'Lisinopril', dosage: '10 mg ', additionalInfo: '', imageUrl: null },
      { id: 9, name: 'Aspirin', dosage: '81 mg', additionalInfo: '', imageUrl: '' },
    ]);

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(profiles(db)).toEqual([maria]);
    expect(activeProfileId(db)).toBe(4);
    expect(medications(db)).toEqual([
      {
        id: 3,
        profile_id: 4,
        name: 'Metformin',
        dosage: '500 mg',
        additionalInfo: 'With meals',
        imageUrl: 'image_picker_A.jpg',
      },
      {
        id: 8,
        profile_id: 4,
        name: 'Lisinopril',
        dosage: '10 mg',
        additionalInfo: '',
        imageUrl: null,
      },
      {
        id: 9,
        profile_id: 4,
        name: 'Aspirin',
        dosage: '81 mg',
        additionalInfo: '',
        imageUrl: null,
      },
    ]);
  });

  it('creates Default Profile when only the medications file exists', () => {
    const dir = tempDir();
    writeLegacyMedications(dir, [
      { id: 2, name: 'Vitamin D', dosage: '1000 IU', additionalInfo: '', imageUrl: null },
    ]);

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(profiles(db)).toEqual([
      { id: 1, name: 'Default Profile', dob: '', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
    expect(medications(db)).toEqual([
      {
        id: 2,
        profile_id: 1,
        name: 'Vitamin D',
        dosage: '1000 IU',
        additionalInfo: '',
        imageUrl: null,
      },
    ]);
    expect(activeProfileId(db)).toBe(1);
  });

  it('creates Default Profile when the legacy profile table is empty', () => {
    const dir = tempDir();
    writeLegacyProfiles(dir, []);
    writeLegacyMedications(dir, [
      { id: 5, name: 'Zinc', dosage: '50 mg', additionalInfo: '', imageUrl: 'zinc.jpg' },
    ]);

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(profiles(db)).toEqual([
      { id: 1, name: 'Default Profile', dob: '', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
    expect(medications(db)).toEqual([
      {
        id: 5,
        profile_id: 1,
        name: 'Zinc',
        dosage: '50 mg',
        additionalInfo: '',
        imageUrl: 'zinc.jpg',
      },
    ]);
  });

  it('imports legacy files from before imageUrl and pharmacy existed', () => {
    const dir = tempDir();
    writeLegacyProfiles(dir, [{ id: 1, name: 'Sam', dob: '11/02/2015', pcp: null }], { v1: true });
    writeLegacyMedications(
      dir,
      [{ id: 1, name: 'Amoxicillin', dosage: '250 mg', additionalInfo: '' }],
      {
        v1: true,
      },
    );

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(profiles(db)).toEqual([
      { id: 1, name: 'Sam', dob: '11/02/2015', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
    expect(medications(db)).toEqual([
      {
        id: 1,
        profile_id: 1,
        name: 'Amoxicillin',
        dosage: '250 mg',
        additionalInfo: '',
        imageUrl: null,
      },
    ]);
  });

  it('imports over the empty database 1.2.0 leaves when its own import crashes', () => {
    const dir = tempDir();
    writeLegacyProfiles(dir, [maria]);
    writeLegacyMedications(dir, [
      { id: 8, name: 'Lisinopril', dosage: '10 mg', additionalInfo: '', imageUrl: null },
    ]);
    // 1.2.0 creates the file, then rolls back everything when a NULL imageUrl crashes it.
    writeFileSync(join(dir, 'CombinedDatabase.db'), '');

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(profiles(db)).toEqual([maria]);
    expect(medications(db)).toEqual([
      {
        id: 8,
        profile_id: 4,
        name: 'Lisinopril',
        dosage: '10 mg',
        additionalInfo: '',
        imageUrl: null,
      },
    ]);
  });

  it('ignores legacy files once a combined database exists', () => {
    const dir = tempDir();
    openAppDatabase(nodeDocuments(dir)).db.close();
    writeLegacyProfiles(dir, [maria]);

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(profiles(db)).toEqual([
      { id: 1, name: 'Default Profile', dob: '', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
  });

  it('never modifies the legacy files', () => {
    const dir = tempDir();
    writeLegacyProfiles(dir, [maria]);
    writeLegacyMedications(dir, [
      { id: 1, name: 'Brand: X\nGeneric: Y', dosage: '1 ', additionalInfo: 'Dosage type: Tablet' },
    ]);
    const before = legacyHashes(dir);

    openAppDatabase(nodeDocuments(dir)).db.close();

    expect(legacyHashes(dir)).toEqual(before);
  });

  it('leaves no combined database and unchanged legacy files when the import fails', () => {
    const dir = tempDir();
    const documents = nodeDocuments(dir);
    writeLegacyProfiles(dir, [maria]);
    // A damaged legacy table that lets a medication without a name through.
    writeLegacyMedications(dir, [{ id: 1, name: null, dosage: '5 mg', additionalInfo: '' }], {
      ddl: 'CREATE TABLE medication_table (id INTEGER PRIMARY KEY, name TEXT, dosage TEXT, additionalInfo TEXT)',
    });
    const before = legacyHashes(dir);

    expect(() => openAppDatabase(documents).db).toThrow(/NOT NULL/);

    expect(documents.exists('CombinedDatabase.db')).toBe(false);
    expect(documents.exists('CombinedDatabase.db-journal')).toBe(false);
    expect(legacyHashes(dir)).toEqual(before);
  });

  it('reads a legacy file the old app left mid-write without changing it', () => {
    const dir = tempDir();
    writeLegacyProfiles(dir, [maria]);
    writeLegacyMedications(dir, [
      { id: 1, name: 'Metformin', dosage: '500 mg', additionalInfo: '', imageUrl: null },
    ]);
    leaveHotJournal(
      dir,
      'MedicationDatabase.db',
      `WITH RECURSIVE n(i) AS (SELECT 2 UNION ALL SELECT i + 1 FROM n WHERE i < 300)
       INSERT INTO medication_table (id, name, dosage, additionalInfo)
       SELECT i, 'Unsaved', hex(randomblob(500)), '' FROM n`,
    );
    const before = legacyHashes(dir, ['MedicationDatabase.db', 'MedicationDatabase.db-journal']);

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(db.all('SELECT id, name FROM medications')).toEqual([{ id: 1, name: 'Metformin' }]);
    expect(legacyHashes(dir, ['MedicationDatabase.db', 'MedicationDatabase.db-journal'])).toEqual(
      before,
    );
    expect(readdirSync(dir).filter((name) => name.includes('.import.'))).toEqual([]);
  });

  it('skips a legacy file that is not a database', () => {
    const dir = tempDir();
    writeFileSync(join(dir, 'UserProfileDatabase.db'), 'not a database, just text '.repeat(40));
    writeLegacyMedications(dir, [
      { id: 2, name: 'Zinc', dosage: '50 mg', additionalInfo: '', imageUrl: null },
    ]);
    const warn = jest.spyOn(console, 'warn').mockImplementation(() => {});

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(db.all('SELECT name, dob FROM profiles')).toEqual([
      { name: 'Default Profile', dob: '' },
    ]);
    expect(db.all('SELECT id, name FROM medications')).toEqual([{ id: 2, name: 'Zinc' }]);
    expect(warn).toHaveBeenCalled();
    warn.mockRestore();
  });

  it('does not import into a database that already has tables', () => {
    const dir = tempDir();
    const existing = openTestDb(join(dir, 'CombinedDatabase.db'));
    existing.exec(`
      CREATE TABLE profiles (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
        dob TEXT NOT NULL, pcp TEXT, healthConditions TEXT, pharmacy TEXT);
      INSERT INTO profiles VALUES (4, 'Already Here', '', '', '', '');
    `);
    existing.close();
    writeLegacyProfiles(dir, [maria]);

    const db = openAppDatabase(nodeDocuments(dir)).db;

    expect(db.all('SELECT id, name FROM profiles')).toEqual([{ id: 4, name: 'Already Here' }]);
  });
});

function legacyHashes(dir: string, names = ['UserProfileDatabase.db', 'MedicationDatabase.db']) {
  const hash = (name: string) =>
    createHash('sha256')
      .update(readFileSync(join(dir, name)))
      .digest('hex');
  return names.map(hash);
}
