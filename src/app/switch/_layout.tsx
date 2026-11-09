import { Stack } from 'expo-router';

export const unstable_settings = { anchor: 'index' };

export default function SwitchLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{ title: 'Select Profile', headerLargeTitleEnabled: true }}
      />
      <Stack.Screen name="new" options={{ title: 'Add Profile', presentation: 'modal' }} />
    </Stack>
  );
}
