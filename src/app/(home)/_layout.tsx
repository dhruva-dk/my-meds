import { Stack } from 'expo-router';

export const unstable_settings = { anchor: 'index' };

export default function HomeLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Home', headerLargeTitleEnabled: true }} />
      <Stack.Screen name="medication/[id]" options={{ title: 'View Medication' }} />
    </Stack>
  );
}
