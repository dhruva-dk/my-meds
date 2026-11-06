import { commit, getSnapshot, initStore, subscribe } from '@/data/store';
import { openFixture } from '../../../test/prepared';

function open(name: 'v1-seeded.db') {
  const { db, snapshot } = openFixture(name);
  initStore(db, snapshot);
}

describe('store', () => {
  it('rebuilds the snapshot and notifies subscribers after a commit', () => {
    open('v1-seeded.db');
    const before = getSnapshot();
    const listener = jest.fn();
    const unsubscribe = subscribe(listener);

    commit((db) => db.run('UPDATE app_state SET active_profile_id = 3'));

    expect(listener).toHaveBeenCalledTimes(1);
    expect(getSnapshot().activeProfile.name).toBe("Sam O'Neil");
    expect(before.activeProfile.name).toBe('Default Profile');
    unsubscribe();
  });

  it('leaves the data and snapshot unchanged when a commit throws', () => {
    open('v1-seeded.db');
    const before = getSnapshot();
    const listener = jest.fn();
    const unsubscribe = subscribe(listener);

    expect(() =>
      commit((db) => {
        db.run("UPDATE profiles SET name = 'Changed' WHERE id = 1");
        throw new Error('save failed');
      }),
    ).toThrow('save failed');

    expect(listener).not.toHaveBeenCalled();
    expect(getSnapshot()).toBe(before);
    commit(() => undefined);
    expect(getSnapshot().activeProfile.name).toBe('Default Profile');
    unsubscribe();
  });

  it('keeps a valid active profile when a commit deletes it', () => {
    open('v1-seeded.db');
    commit((db) => db.run('UPDATE app_state SET active_profile_id = 3'));

    commit((db) => db.run('DELETE FROM profiles WHERE id = 3'));
    expect(getSnapshot().activeProfile.name).toBe('Default Profile');

    commit((db) => db.run('DELETE FROM profiles'));
    expect(getSnapshot().profiles).toEqual([
      { id: 4, name: 'Default Profile', dob: '', pcp: '', healthConditions: '', pharmacy: '' },
    ]);
    expect(getSnapshot().activeProfile.id).toBe(4);
    expect(getSnapshot().medications).toEqual([]);
  });

  it('refuses an async function, leaving the data unchanged', () => {
    open('v1-seeded.db');
    const before = getSnapshot();

    expect(() =>
      commit(async (db) => {
        db.run("UPDATE profiles SET name = 'Changed' WHERE id = 1");
      }),
    ).toThrow(/synchronous/);

    commit(() => undefined);
    expect(getSnapshot()).toEqual(before);
  });
});
