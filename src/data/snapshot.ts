import type { Db } from './db';

export type Profile = {
  id: number;
  name: string;
  /** `MM/dd/yyyy`, or '' when not given. Other text is shown as typed. */
  dob: string;
  pcp: string;
  healthConditions: string;
  pharmacy: string;
};

export type Medication = {
  id: number;
  profileId: number;
  name: string;
  dosage: string;
  notes: string;
  /** Path relative to Documents, or null when there is no photo. */
  photo: string | null;
};

/** Everything the UI renders, rebuilt from the database after every write. */
export type Snapshot = {
  profiles: Profile[];
  activeProfile: Profile;
  /** The active profile's medications, sorted by name ignoring case and a leading `Brand: `. */
  medications: Medication[];
};

type ProfileRow = {
  id: number;
  name: string;
  dob: string;
  pcp: string | null;
  healthConditions: string | null;
  pharmacy: string | null;
};

type MedicationRow = {
  id: number;
  profile_id: number;
  name: string;
  dosage: string;
  additionalInfo: string;
  imageUrl: string | null;
};

export function loadSnapshot(db: Db): Snapshot {
  const profiles = db
    .all<ProfileRow>('SELECT * FROM profiles ORDER BY name COLLATE NOCASE, id')
    .map(toProfile);
  const activeId = db.get<{ active_profile_id: number | null }>(
    'SELECT active_profile_id FROM app_state WHERE id = 1',
  )?.active_profile_id;
  const activeProfile = profiles.find((profile) => profile.id === activeId);
  if (!activeProfile) {
    throw new Error('The active profile is missing; prepareDatabase must run first.');
  }
  const medications = db
    .all<MedicationRow>(
      `SELECT * FROM medications WHERE profile_id = ?
       ORDER BY CASE WHEN name LIKE 'Brand: %' THEN substr(name, 8) ELSE name END COLLATE NOCASE, id`,
      [activeProfile.id],
    )
    .map(toMedication);
  return { profiles, activeProfile, medications };
}

function toProfile(row: ProfileRow): Profile {
  return {
    id: row.id,
    name: row.name,
    dob: row.dob,
    pcp: row.pcp ?? '',
    healthConditions: row.healthConditions ?? '',
    pharmacy: row.pharmacy ?? '',
  };
}

function toMedication(row: MedicationRow): Medication {
  return {
    id: row.id,
    profileId: row.profile_id,
    name: row.name,
    dosage: row.dosage,
    notes: row.additionalInfo,
    photo: row.imageUrl ? row.imageUrl : null,
  };
}
