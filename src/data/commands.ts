import type { Db } from './db';
import { removePhotos } from './photoFiles';
import { commit, getPhotoFiles, queryCount } from './store';

export type MedicationFields = { name: string; dosage: string; notes: string };

export type ProfileFields = {
  name: string;
  dob: string;
  pcp: string;
  healthConditions: string;
  pharmacy: string;
};

function requiredName(name: string): string {
  const trimmed = name.trim();
  if (!trimmed) throw new Error('A name is required.');
  return trimmed;
}

function trimmedMedication(fields: MedicationFields): MedicationFields {
  return {
    name: requiredName(fields.name),
    dosage: fields.dosage.trim(),
    notes: fields.notes.trim(),
  };
}

function trimmedProfile(fields: ProfileFields): ProfileFields {
  return {
    name: requiredName(fields.name),
    dob: fields.dob.trim(),
    pcp: fields.pcp.trim(),
    healthConditions: fields.healthConditions.trim(),
    pharmacy: fields.pharmacy.trim(),
  };
}

function expectChanged(changes: number, what: string) {
  if (changes === 0) throw new Error(`${what} no longer exists.`);
}

/** Saves a picked photo, runs `write`, and removes the saved photo again if `write` fails. */
async function withStoredPhoto<T>(
  sourceUri: string | null | undefined,
  write: (photo: string | null) => T,
): Promise<T> {
  const files = getPhotoFiles();
  const photo = sourceUri ? await files.store(sourceUri) : null;
  try {
    return write(photo);
  } catch (error) {
    removePhotos(files, [photo]);
    throw error;
  }
}

export function addMedication(
  profileId: number,
  fields: MedicationFields,
  newPhotoUri?: string | null,
): Promise<number> {
  const { name, dosage, notes } = trimmedMedication(fields);
  return withStoredPhoto(
    newPhotoUri,
    (photo) =>
      commit((db) =>
        db.run(
          'INSERT INTO medications (profile_id, name, dosage, additionalInfo, imageUrl) VALUES (?, ?, ?, ?, ?)',
          [profileId, name, dosage, notes, photo ?? ''],
        ),
      ).lastInsertRowId,
  );
}

const photoOf = (db: Db, id: number) =>
  db.get<{ imageUrl: string | null }>('SELECT imageUrl FROM medications WHERE id = ?', [id])
    ?.imageUrl ?? null;

/** Keeps the current photo unless `newPhotoUri` replaces it. */
export async function updateMedication(
  id: number,
  fields: MedicationFields,
  newPhotoUri?: string | null,
): Promise<void> {
  const { name, dosage, notes } = trimmedMedication(fields);
  const replaced = await withStoredPhoto(newPhotoUri, (photo) =>
    commit((db) => {
      const previous = photoOf(db, id);
      const { changes } = db.run(
        'UPDATE medications SET name = ?, dosage = ?, additionalInfo = ?, imageUrl = COALESCE(?, imageUrl) WHERE id = ?',
        [name, dosage, notes, photo, id],
      );
      expectChanged(changes, 'This medication');
      return photo ? previous : null;
    }),
  );
  removePhotos(getPhotoFiles(), [replaced]);
}

export function deleteMedication(id: number): void {
  const photo = commit((db) => {
    const previous = photoOf(db, id);
    expectChanged(db.run('DELETE FROM medications WHERE id = ?', [id]).changes, 'This medication');
    return previous;
  });
  removePhotos(getPhotoFiles(), [photo]);
}

export function updateProfile(id: number, fields: ProfileFields): void {
  const { name, dob, pcp, healthConditions, pharmacy } = trimmedProfile(fields);
  commit((db) => {
    const { changes } = db.run(
      'UPDATE profiles SET name = ?, dob = ?, pcp = ?, healthConditions = ?, pharmacy = ? WHERE id = ?',
      [name, dob, pcp, healthConditions, pharmacy, id],
    );
    expectChanged(changes, 'This profile');
  });
}

/** Adds a profile without switching to it, as 1.2.0 did. */
export function addProfile(fields: ProfileFields): number {
  const { name, dob, pcp, healthConditions, pharmacy } = trimmedProfile(fields);
  return commit(
    (db) =>
      db.run(
        'INSERT INTO profiles (name, dob, pcp, healthConditions, pharmacy) VALUES (?, ?, ?, ?, ?)',
        [name, dob, pcp, healthConditions, pharmacy],
      ).lastInsertRowId,
  );
}

export function setActiveProfile(id: number): void {
  commit((db) => {
    const { changes } = db.run(
      'UPDATE app_state SET active_profile_id = ? WHERE id = 1 AND EXISTS (SELECT 1 FROM profiles WHERE id = ?)',
      [id, id],
    );
    expectChanged(changes, 'This profile');
  });
}

/** Deletes a profile and its medications. A different profile becomes active if needed. */
export function deleteProfile(id: number): void {
  const photos = commit((db) => {
    const count = db.get<{ count: number }>('SELECT COUNT(*) AS count FROM profiles')?.count ?? 0;
    if (count <= 1) throw new Error('The last profile cannot be deleted.');
    const rows = db.all<{ imageUrl: string | null }>(
      'SELECT imageUrl FROM medications WHERE profile_id = ?',
      [id],
    );
    expectChanged(db.run('DELETE FROM profiles WHERE id = ?', [id]).changes, 'This profile');
    return rows.map((row) => row.imageUrl);
  });
  removePhotos(getPhotoFiles(), photos);
}

export function countMedications(profileId: number): number {
  return queryCount('SELECT COUNT(*) AS count FROM medications WHERE profile_id = ?', [profileId]);
}
