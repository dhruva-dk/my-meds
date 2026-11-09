import {
  addMedication,
  addProfile,
  countMedications,
  deleteMedication,
  deleteProfile,
  setActiveProfile,
  updateMedication,
  updateProfile,
} from '@/data/commands';
import type { Db } from '@/data/db';
import {
  fitLongEdge,
  isAppOwnedPhoto,
  removeUnreferencedPhotos,
  type PhotoFiles,
} from '@/data/photoFiles';
import { getSnapshot, initStore } from '@/data/store';
import { openFixture } from '../../../test/prepared';

const LEGACY_PHOTO = 'image_picker_9E21B643-C0C6-4540-9401-C76035161FC8.jpg';
const blankProfile = { name: 'New', dob: '', pcp: '', healthConditions: '', pharmacy: '' };

function setup() {
  const { db, snapshot } = openFixture('v1-seeded.db');
  const files = new Set<string>();
  const removed: string[] = [];
  let next = 1;
  const photos: PhotoFiles = {
    store: async () => {
      const path = `images/${next++}.jpg`;
      files.add(path);
      return path;
    },
    list: () => [...files],
    remove: (path) => {
      files.delete(path);
      removed.push(path);
    },
  };
  initStore(db, snapshot, photos);
  return { db, files, removed };
}

const medication = (db: Db, id: number) => db.get('SELECT * FROM medications WHERE id = ?', [id]);

describe('medication commands', () => {
  it('adds a trimmed medication that appears in sorted order', async () => {
    setup();
    setActiveProfile(3);

    const id = await addMedication(3, { name: '  Brufen ', dosage: ' 10 mg ', notes: ' note ' });

    const added = getSnapshot().medications.find((med) => med.id === id);
    expect(added).toMatchObject({ name: 'Brufen', dosage: '10 mg', notes: 'note', photo: null });
    expect(getSnapshot().medications.map((med) => med.name)).toEqual([
      'amoxicillin',
      'Brufen',
      'Brand: Tylenol\nGeneric: Unknown Generic Name',
    ]);
  });

  it('stores no photo as an empty string, as 1.2.0 did', async () => {
    const { db } = setup();
    const id = await addMedication(1, { name: 'A', dosage: '', notes: '' });
    expect(medication(db, id)).toMatchObject({ imageUrl: '' });
  });

  it('refuses a blank name and saves nothing', () => {
    const { db } = setup();
    const before = db.all('SELECT * FROM medications');
    expect(() => addMedication(1, { name: '   ', dosage: '', notes: '' })).toThrow();
    expect(db.all('SELECT * FROM medications')).toEqual(before);
  });

  it('removes the photo it just saved if the medication cannot be saved', async () => {
    const { files, removed } = setup();
    await expect(
      addMedication(999, { name: 'A', dosage: '', notes: '' }, 'file:///picked.jpg'),
    ).rejects.toThrow();
    expect(files.size).toBe(0);
    expect(removed).toEqual(['images/1.jpg']);
  });

  it('updates a medication and keeps its photo', async () => {
    const { db } = setup();
    await updateMedication(4, { name: 'Fish oil', dosage: '2 capsules', notes: '' });
    expect(medication(db, 4)).toMatchObject({ dosage: '2 capsules', imageUrl: LEGACY_PHOTO });
  });

  it('throws when updating a medication that no longer exists', async () => {
    setup();
    await expect(updateMedication(999, { name: 'A', dosage: '', notes: '' })).rejects.toThrow();
  });

  it('replacing a 1.2.0 photo leaves its file alone', async () => {
    const { db, removed } = setup();
    await updateMedication(4, { name: 'Fish oil', dosage: '', notes: '' }, 'file:///new.jpg');
    expect(medication(db, 4)).toMatchObject({ imageUrl: 'images/1.jpg' });
    expect(removed).toEqual([]);
  });

  it('replacing an app-owned photo deletes the old file after the commit', async () => {
    const { db, removed } = setup();
    const id = await addMedication(1, { name: 'A', dosage: '', notes: '' }, 'file:///a.jpg');
    await updateMedication(id, { name: 'A', dosage: '', notes: '' }, 'file:///b.jpg');
    expect(medication(db, id)).toMatchObject({ imageUrl: 'images/2.jpg' });
    expect(removed).toEqual(['images/1.jpg']);
  });

  it('deleting a medication removes its app-owned photo but not a 1.2.0 photo', async () => {
    const { removed } = setup();
    const id = await addMedication(1, { name: 'A', dosage: '', notes: '' }, 'file:///a.jpg');
    deleteMedication(id);
    deleteMedication(4);
    expect(removed).toEqual(['images/1.jpg']);
  });

  it('throws when deleting a medication that no longer exists', () => {
    setup();
    expect(() => deleteMedication(999)).toThrow();
  });
});

describe('profile commands', () => {
  it('updates a profile with trimmed values', () => {
    setup();
    updateProfile(3, { ...blankProfile, name: ' Sam ', dob: '01/02/2000', pcp: ' Dr. B ' });
    expect(getSnapshot().profiles.find((profile) => profile.id === 3)).toMatchObject({
      name: 'Sam',
      dob: '01/02/2000',
      pcp: 'Dr. B',
    });
  });

  it('stores an empty value when the date of birth is cleared', () => {
    const { db } = setup();
    updateProfile(2, { ...blankProfile, name: 'Maria', dob: '' });
    expect(db.get('SELECT dob FROM profiles WHERE id = 2')).toEqual({ dob: '' });
  });

  it('adds a profile without switching to it', () => {
    setup();
    const before = getSnapshot().activeProfile.id;
    const id = addProfile(blankProfile);
    expect(getSnapshot().profiles.some((profile) => profile.id === id)).toBe(true);
    expect(getSnapshot().activeProfile.id).toBe(before);
  });

  it('switches the active profile and throws for one that is gone', () => {
    setup();
    setActiveProfile(3);
    expect(getSnapshot().activeProfile.id).toBe(3);
    expect(() => setActiveProfile(999)).toThrow();
    expect(getSnapshot().activeProfile.id).toBe(3);
  });

  it("deletes a profile's medications and app-owned photos together", async () => {
    const { db, removed } = setup();
    await addMedication(3, { name: 'A', dosage: '', notes: '' }, 'file:///a.jpg');
    expect(countMedications(3)).toBe(3);

    deleteProfile(3);

    expect(db.all('SELECT id FROM medications WHERE profile_id = 3')).toEqual([]);
    expect(removed).toEqual(['images/1.jpg']);
  });

  it('makes another profile active when the active one is deleted', () => {
    setup();
    setActiveProfile(3);
    deleteProfile(3);
    expect(getSnapshot().activeProfile.id).toBe(1);
  });

  it('refuses to delete the last profile', () => {
    setup();
    deleteProfile(2);
    deleteProfile(3);
    expect(() => deleteProfile(1)).toThrow();
    expect(getSnapshot().profiles).toHaveLength(1);
  });

  it('leaves every medication with an existing profile after any deletes', () => {
    const { db } = setup();
    deleteProfile(2);
    deleteProfile(1);
    expect(
      db.all('SELECT id FROM medications WHERE profile_id NOT IN (SELECT id FROM profiles)'),
    ).toEqual([]);
    expect(getSnapshot().activeProfile.id).toBe(3);
  });
});

describe('photo files', () => {
  it('owns only files directly in the images folder', () => {
    expect(isAppOwnedPhoto('images/a.jpg')).toBe(true);
    for (const path of [
      'a.jpg',
      '',
      null,
      'images/',
      'images/../a.jpg',
      'images/x/a.jpg',
      'images/..',
    ]) {
      expect(isAppOwnedPhoto(path)).toBe(false);
    }
  });

  it('removes only unreferenced files in the app-owned folder at startup', async () => {
    const { db, files, removed } = setup();
    const id = await addMedication(1, { name: 'A', dosage: '', notes: '' }, 'file:///a.jpg');
    files.add('images/stray.jpg');
    files.add(LEGACY_PHOTO);
    const photos: PhotoFiles = {
      store: async () => '',
      list: () => [...files].filter((path) => path.startsWith('images/')).concat(LEGACY_PHOTO),
      remove: (path) => {
        files.delete(path);
        removed.push(path);
      },
    };

    removeUnreferencedPhotos(db, photos);

    expect(removed).toEqual(['images/stray.jpg']);
    expect(medication(db, id)).toMatchObject({ imageUrl: 'images/1.jpg' });
    expect(files.has('images/1.jpg')).toBe(true);
  });

  it('fits a 4032x3024 photo to 1600 on its long edge', () => {
    expect(fitLongEdge(4032, 3024, 1600)).toEqual({ width: 1600 });
    expect(fitLongEdge(3024, 4032, 1600)).toEqual({ height: 1600 });
    expect(fitLongEdge(1600, 1200, 1600)).toBeNull();
  });
});
