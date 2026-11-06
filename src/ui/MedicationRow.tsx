import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors } from './theme';
import { Thumbnail } from './Thumbnail';

type Props = {
  name: string;
  genericName: string | null;
  dosage: string;
  photoUri: string | null;
  onPress?: () => void;
};

export function MedicationRow({ name, genericName, dosage, photoUri, onPress }: Props) {
  const showGeneric = genericName && genericName.toLowerCase() !== name.toLowerCase();
  const label = [name, showGeneric ? `generic ${genericName}` : null, dosage || null]
    .filter(Boolean)
    .join(', ');
  return (
    <Pressable
      onPress={onPress}
      disabled={!onPress}
      accessibilityRole={onPress ? 'button' : undefined}
      accessibilityLabel={label}
      style={({ pressed }) => [styles.row, pressed && styles.pressed]}
    >
      <Thumbnail uri={photoUri} />
      <View style={styles.text}>
        <Text style={styles.name}>{name}</Text>
        {showGeneric ? <Text style={styles.detail}>{genericName}</Text> : null}
        {dosage ? <Text style={styles.detail}>{dosage}</Text> : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    padding: 12,
    borderRadius: 14,
    backgroundColor: colors.card,
  },
  pressed: { opacity: 0.6 },
  text: { flex: 1, gap: 2 },
  name: { fontSize: 17, fontWeight: '600', color: colors.label },
  detail: { fontSize: 15, color: colors.secondaryLabel },
});
