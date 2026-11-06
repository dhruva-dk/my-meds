import { Stack } from 'expo-router';

export default function SwitchLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Switch Profile' }} />
    </Stack>
  );
}
