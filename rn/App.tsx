import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';

import { DatabaseService } from './src/database/database';
import SelectProfileScreen from './src/screens/SelectProfileScreen';
import HomeScreen from './src/screens/HomeScreen';
import FDASearchScreen from './src/screens/FDASearchScreen';
import CreateMedicationScreen from './src/screens/CreateMedicationScreen';
import CreateProfileScreen from './src/screens/CreateProfileScreen';
import EditProfileScreen from './src/screens/EditProfileScreen';
import EditMedicationScreen from './src/screens/EditMedicationScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  const [dbReady, setDbReady] = useState(false);

  useEffect(() => {
    async function loadDb() {
      // Triggers Flutter migration -> SQLite
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
      <NavigationContainer>
        <Stack.Navigator 
          initialRouteName="SelectProfile" 
          screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#F6F6F6' } }}
        >
          <Stack.Screen name="SelectProfile" component={SelectProfileScreen} />
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="FDASearch" component={FDASearchScreen} />
          <Stack.Screen name="CreateMedication" component={CreateMedicationScreen} />
          <Stack.Screen name="EditMedication" component={EditMedicationScreen} />
          <Stack.Screen name="CreateProfile" component={CreateProfileScreen} />
          <Stack.Screen name="EditProfile" component={EditProfileScreen} />
        </Stack.Navigator>
      </NavigationContainer>
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
