import { useSyncExternalStore } from 'react';
import { getSnapshot, subscribe } from './store';
import type { Snapshot } from './snapshot';

export function useSnapshot(): Snapshot {
  return useSyncExternalStore(subscribe, getSnapshot);
}
