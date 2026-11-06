import { DarkTheme, DefaultTheme, ThemeProvider, type ErrorBoundaryProps } from 'expo-router';
import { NativeTabs } from 'expo-router/native-tabs';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme } from 'react-native';
import { MessageScreen } from '@/ui/MessageScreen';
import { colors, tintHex } from '@/ui/theme';

export function ErrorBoundary({ retry }: ErrorBoundaryProps) {
  return (
    <MessageScreen
      title="Something went wrong"
      message="My Meds ran into a problem. Try again, or close and reopen the app."
      actionLabel="Try Again"
      onAction={retry}
    />
  );
}

export default function RootLayout() {
  const scheme = useColorScheme();
  const base = scheme === 'dark' ? DarkTheme : DefaultTheme;
  const theme = {
    ...base,
    colors: { ...base.colors, primary: scheme === 'dark' ? tintHex.dark : tintHex.light },
  };

  return (
    <ThemeProvider value={theme}>
      <StatusBar style="auto" />
      <NativeTabs tintColor={colors.tint}>
        <NativeTabs.Trigger name="(home)">
          <NativeTabs.Trigger.Label>Home</NativeTabs.Trigger.Label>
          <NativeTabs.Trigger.Icon sf={{ default: 'house', selected: 'house.fill' }} />
        </NativeTabs.Trigger>
        <NativeTabs.Trigger name="add">
          <NativeTabs.Trigger.Label>Add Med</NativeTabs.Trigger.Label>
          <NativeTabs.Trigger.Icon sf={{ default: 'plus.circle', selected: 'plus.circle.fill' }} />
        </NativeTabs.Trigger>
        <NativeTabs.Trigger name="profile">
          <NativeTabs.Trigger.Label>Profile</NativeTabs.Trigger.Label>
          <NativeTabs.Trigger.Icon sf={{ default: 'person', selected: 'person.fill' }} />
        </NativeTabs.Trigger>
        <NativeTabs.Trigger name="switch">
          <NativeTabs.Trigger.Label>Switch</NativeTabs.Trigger.Label>
          <NativeTabs.Trigger.Icon sf={{ default: 'person.2', selected: 'person.2.fill' }} />
        </NativeTabs.Trigger>
      </NativeTabs>
    </ThemeProvider>
  );
}
