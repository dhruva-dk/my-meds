import { DarkTheme, DefaultTheme, ThemeProvider, type ErrorBoundaryProps } from 'expo-router';
import { NativeTabs } from 'expo-router/native-tabs';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import { useColorScheme } from 'react-native';
import { startApp } from '@/data/startup';
import { MessageScreen } from '@/ui/MessageScreen';
import { ACCENT } from '@/ui/theme';

const lightTheme = {
  ...DefaultTheme,
  colors: { ...DefaultTheme.colors, primary: ACCENT.light },
};
const darkTheme = { ...DarkTheme, colors: { ...DarkTheme.colors, primary: ACCENT.dark } };

export function ErrorBoundary({ error, retry }: ErrorBoundaryProps) {
  useEffect(() => console.error('Unhandled render error', error), [error]);
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
  const [startup] = useState(startApp);
  const scheme = useColorScheme();

  if (!startup.ok) {
    return (
      <MessageScreen
        title="Couldn't open your data"
        message="My Meds couldn't open your medications. Nothing was changed. Close the app and try again."
      />
    );
  }

  return (
    <ThemeProvider value={scheme === 'dark' ? darkTheme : lightTheme}>
      <StatusBar style="auto" />
      <NativeTabs>
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
