import { loadSnapshot } from '@/data/snapshot';
import { preparedFixture } from '../../../test/prepared';

describe('loadSnapshot', () => {
  it('holds all profiles by name and the active profile', () => {
    const snapshot = loadSnapshot(preparedFixture('v1-seeded.db'));

    expect(snapshot.profiles.map((profile) => profile.name)).toEqual([
      'Default Profile',
      'Maria Garcia',
      "Sam O'Neil",
    ]);
    expect(snapshot.activeProfile).toEqual({
      id: 1,
      name: 'Default Profile',
      dob: '11/05/2026',
      pcp: '',
      healthConditions: '',
      pharmacy: '',
    });
  });

  it("lists only the active profile's medications, sorted by name ignoring case", () => {
    const db = preparedFixture('v1-seeded.db');
    db.run('UPDATE app_state SET active_profile_id = 3');

    expect(loadSnapshot(db).medications).toEqual([
      {
        id: 9,
        profileId: 3,
        name: 'amoxicillin',
        genericName: null,
        dosage: '250 mg',
        dosageForm: null,
        ndc: null,
        notes: 'Finish the full course',
        photo: null,
      },
      {
        id: 10,
        profileId: 3,
        name: 'Tylenol',
        genericName: null,
        dosage: '160 mg',
        dosageForm: 'Suspension',
        ndc: null,
        notes: '',
        photo: null,
      },
    ]);
  });

  it('keeps the stored photo path relative to Documents', () => {
    const db = preparedFixture('v1-seeded.db');
    db.run('UPDATE app_state SET active_profile_id = 2');

    expect(loadSnapshot(db).medications.map((med) => [med.name, med.photo])).toEqual([
      ['Brand: Advil\nGeneric: Ibuprofen\nTake with food', null],
      ['Fish oil', 'image_picker_9E21B643-C0C6-4540-9401-C76035161FC8.jpg'],
      ['Ibuprofen', null],
      ['Insulin glargine', null],
      ['Lipitor', null],
      ['Metformin', 'image_picker_BE853A23-58D7-456D-A22B-91B9ED7A719C.jpg'],
    ]);
  });
});
