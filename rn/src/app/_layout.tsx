import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { DatabaseService } from '../database/database';

export default function RootLayout() {
  const [dbReady, setDbReady] = useState(false);

  useEffect(() => {
    async function loadDb() {
      await DatabaseService.initDatabase();
      setDbReady(true);
    }
    loadDb();
  }, []);

  if (!dbReady) {
    return (
      <View style={styles.center}>
        <Text>Loading App...</Text>
      </View>
    );
  }

  return (
    <SafeAreaProvider>
      <Stack 
        screenOptions={{ 
          headerShown: false, 
          contentStyle: { backgroundColor: '#F6F6F6' } 
        }}
      >
        <Stack.Screen name="index" />
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="CreateMedication" />
        <Stack.Screen name="EditMedication" />
        <Stack.Screen name="CreateProfile" />
      </Stack>
      <StatusBar style="auto" />
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  }
});
