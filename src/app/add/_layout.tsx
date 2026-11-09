import { Stack } from 'expo-router';

export const unstable_settings = { anchor: 'index' };

export default function AddMedLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{ title: 'Add Medication', headerLargeTitleEnabled: true }}
      />
      <Stack.Screen name="new" options={{ title: 'Add Medication', presentation: 'modal' }} />
    </Stack>
  );
}
