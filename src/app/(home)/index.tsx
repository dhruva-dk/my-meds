import { FlatList, StyleSheet, Text, View } from 'react-native';
import { useSnapshot } from '@/data/useSnapshot';
import { MedicationRow } from '@/ui/MedicationRow';
import { photoUri } from '@/ui/photoUri';
import { ProfileHeader } from '@/ui/ProfileHeader';
import { colors } from '@/ui/theme';

export default function HomeScreen() {
  const { activeProfile, medications } = useSnapshot();
  return (
    <FlatList
      style={styles.list}
      contentContainerStyle={styles.content}
      contentInsetAdjustmentBehavior="automatic"
      data={medications}
      keyExtractor={(medication) => String(medication.id)}
      ListHeaderComponent={<ProfileHeader name={activeProfile.name} dob={activeProfile.dob} />}
      ListEmptyComponent={
        <Text style={styles.empty}>No medications. Add by tapping Add Med below.</Text>
      }
      ItemSeparatorComponent={Separator}
      renderItem={({ item }) => (
        <MedicationRow
          name={item.name}
          genericName={item.genericName}
          dosage={item.dosage}
          photoUri={photoUri(item.photo)}
        />
      )}
    />
  );
}

function Separator() {
  return <View style={styles.separator} />;
}

const styles = StyleSheet.create({
  list: { backgroundColor: colors.background },
  content: { padding: 16 },
  separator: { height: 10 },
  empty: { fontSize: 17, color: colors.secondaryLabel, textAlign: 'center', marginTop: 32 },
});
