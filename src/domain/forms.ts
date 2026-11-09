export const UNITS = ['N/A', 'mg', 'mL', 'g', 'mcg', 'IU', '%'] as const;
export type Unit = (typeof UNITS)[number];

/** Dosage text plus unit, as one saved string. The unit is skipped if the text already ends in it. */
export function combineDosage(text: string, unit: Unit): string {
  const dosage = text.trim();
  if (!dosage || unit === 'N/A') return dosage;
  const lower = dosage.toLowerCase();
  const suffix = unit.toLowerCase();
  const before = lower.at(-suffix.length - 1) ?? '';
  const endsInUnit = lower.endsWith(suffix) && !/[a-z]/.test(before);
  return endsInUnit ? dosage : `${dosage} ${unit}`;
}

/** Splits a saved dosage for editing. Anything not ending in a known unit stays whole. */
export function splitDosage(saved: string): { text: string; unit: Unit } {
  const dosage = saved.trim();
  const space = dosage.lastIndexOf(' ');
  if (space > 0) {
    const unit = UNITS.find((known) => known === dosage.slice(space + 1));
    if (unit && unit !== 'N/A') return { text: dosage.slice(0, space).trim(), unit };
  }
  return { text: dosage, unit: 'N/A' };
}

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/**
 * Parses stored `MM/dd/yyyy` text. Anything else, including impossible dates, is null.
 *
 * The result is noon local time. JavaScript and iOS can disagree by an hour about daylight saving
 * in past years, so a midnight birthday could show as the day before in the native date wheel.
 */
export function parseStoredDate(stored: string): Date | null {
  const match = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(stored.trim());
  if (!match) return null;
  const [month, day, year] = [Number(match[1]), Number(match[2]), Number(match[3])];
  const date = new Date(year, month - 1, day, 12);
  return date.getMonth() === month - 1 && date.getDate() === day ? date : null;
}

export function toStoredDate(date: Date): string {
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${month}/${day}/${date.getFullYear()}`;
}

export function displayDate(date: Date): string {
  return `${MONTHS[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`;
}

/** "Mar 14, 1958", or the stored text as typed if it doesn't parse, or "—" if empty. */
export function displayDob(stored: string): string {
  if (!stored.trim()) return '—';
  const date = parseStoredDate(stored);
  return date ? displayDate(date) : stored;
}

const digitsOf = (text: string) => text.replace(/\D/g, '');

/** `(###) ###-####` when the text has exactly 10 digits, and as typed otherwise. */
export function displayPhone(text: string): string {
  const digits = digitsOf(text);
  if (digits.length !== 10) return text;
  return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
}

/** Formats as the user types. Deleting never reformats, so one backspace removes one character. */
export function phoneAfterEdit(previous: string, next: string): string {
  return next.length > previous.length ? displayPhone(next) : next;
}
