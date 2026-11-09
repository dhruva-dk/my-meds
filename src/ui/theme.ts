import { DynamicColorIOS, PlatformColor } from 'react-native';

/** The Home card. */
export const CARD_GREEN = '#2F3A33';

/**
 * The tint for controls. CARD_GREEN is under 2:1 on dark backgrounds, so dark mode uses a lighter
 * green. Keep in step with the withAccentColor plugin options in app.json.
 */
export const ACCENT = { light: CARD_GREEN, dark: '#8FBFA0' };

export const colors = {
  accent: DynamicColorIOS(ACCENT),
  destructive: PlatformColor('systemRed'),
  /** Stock secondaryLabel is about 3.4:1 on white; the accessibility floor is 4.5:1. */
  secondary: DynamicColorIOS({ light: '#5C5C63', dark: '#B4B4BB' }),
  label: PlatformColor('label'),
  background: PlatformColor('systemGroupedBackground'),
  fill: PlatformColor('tertiarySystemFill'),
  chevron: PlatformColor('tertiaryLabel'),
};
