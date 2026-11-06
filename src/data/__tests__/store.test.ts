import { commit, getSnapshot, initStore, subscribe } from '@/data/store';
import { preparedFixture } from '../../../test/prepared';

describe('store', () => {
  it('rebuilds the snapshot and notifies subscribers after a commit', () => {
    initStore(preparedFixture('v1-seeded.db'));
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
    initStore(preparedFixture('v1-seeded.db'));
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
});
