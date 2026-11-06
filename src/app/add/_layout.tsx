import { Stack } from 'expo-router';

export default function AddMedLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Add Med' }} />
    </Stack>
  );
}
