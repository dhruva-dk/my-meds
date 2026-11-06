import { DynamicColorIOS, PlatformColor } from 'react-native';

/** Brand tint. The dark variant stays readable on black backgrounds. */
export const tintHex = { light: '#2F3A33', dark: '#A3BFAB' } as const;

export const colors = {
  tint: DynamicColorIOS(tintHex),
  label: PlatformColor('label'),
  secondaryLabel: PlatformColor('secondaryLabel'),
  tertiaryLabel: PlatformColor('tertiaryLabel'),
  background: PlatformColor('systemGroupedBackground'),
  card: PlatformColor('secondarySystemGroupedBackground'),
  fill: PlatformColor('tertiarySystemFill'),
  separator: PlatformColor('separator'),
  destructive: PlatformColor('systemRed'),
  onTint: DynamicColorIOS({ light: '#FFFFFF', dark: '#000000' }),
};
