import { atom } from 'jotai';
import { UserProfile, Medication } from '../types';

export const profilesAtom = atom<UserProfile[]>([]);
export const selectedProfileAtom = atom<UserProfile | null>(null);
export const medicationsAtom = atom<Medication[]>([]);
