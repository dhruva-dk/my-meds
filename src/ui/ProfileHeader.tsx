import { StyleSheet, Text, View } from 'react-native';
import { colors } from './theme';

type Props = { name: string; dob: string };

export function ProfileHeader({ name, dob }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.name} accessibilityRole="header">
        {name}
      </Text>
      <Text style={styles.dob} accessibilityLabel={`Date of birth ${dob || 'not set'}`}>
        Date of birth {dob || '—'}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { gap: 4, paddingTop: 8, paddingBottom: 20 },
  name: { fontSize: 34, fontWeight: '700', color: colors.label },
  dob: { fontSize: 17, color: colors.secondaryLabel },
});
