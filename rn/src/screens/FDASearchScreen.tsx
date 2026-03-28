import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TextInput, FlatList, ActivityIndicator } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import Header from '../components/Header';
import PrimaryButton from '../components/PrimaryButton';
import PhotoUploadButton from '../components/PhotoUploadButton';
import SearchTile from '../components/SearchTile';
import { AppColors, AppTypography, GlobalStyles } from '../styles/theme';
import { FDAAPIService, FDADrug } from '../api/fda';

export default function FDASearchScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<FDADrug[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Debounced Search logic
  useEffect(() => {
    const handler = setTimeout(async () => {
      if (query.trim().length >= 3) {
        setLoading(true);
        setError('');
        try {
          const fetchedInfo = await FDAAPIService.searchMedications(query.trim());
          setResults(fetchedInfo);
        } catch (err: any) {
          setResults([]);
          setError(err.message || 'Error executing search');
        } finally {
          setLoading(false);
        }
      } else {
        setResults([]);
        setError('');
      }
    }, 500);

    return () => clearTimeout(handler);
  }, [query]);

  const navigateToCreate = (params: any = {}) => {
    navigation.navigate('CreateMedication', params);
  };

  const handleTakePhoto = async () => {
    const perm = await ImagePicker.requestCameraPermissionsAsync();
    if (!perm.granted) return;
    const result = await ImagePicker.launchCameraAsync({ allowsEditing: true, quality: 0.8 });
    if (!result.canceled && result.assets[0]) {
      navigateToCreate({ imageUri: result.assets[0].uri });
    }
  };

  const handleUploadPhoto = async () => {
    const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) return;
    const result = await ImagePicker.launchImageLibraryAsync({ allowsEditing: true, quality: 0.8 });
    if (!result.canceled && result.assets[0]) {
      navigateToCreate({ imageUri: result.assets[0].uri });
    }
  };

  return (
    <View style={GlobalStyles.container}>
      <Header title="Add Medication" onBackPressed={() => navigation.goBack()} />
      <View style={styles.body}>
        <Text style={styles.heading}>FDA Search</Text>
        <View style={styles.searchBox}>
          <Ionicons name="search" size={20} color={AppColors.textSecondary} style={{ marginRight: 8 }} />
          <TextInput
            style={styles.input}
            placeholder="Search"
            value={query}
            onChangeText={setQuery}
            autoCorrect={false}
          />
        </View>

        <View style={styles.buttonRow}>
          <View style={styles.flex1}><PrimaryButton title="Manual Input" onPress={() => navigateToCreate()} /></View>
          <View style={{ width: 8 }} />
          <View style={styles.flex1}><PhotoUploadButton onTakePhoto={handleTakePhoto} onUploadPhoto={handleUploadPhoto} /></View>
        </View>

        <Text style={[styles.heading, { marginTop: 32 }]}>Search Results</Text>
        
        <View style={styles.resultsContainer}>
          {loading ? (
            <ActivityIndicator size="large" color={AppColors.primary} />
          ) : error ? (
            <Text style={styles.emptyResults}>{error}</Text>
          ) : (
            <FlatList
              data={results}
              keyExtractor={item => item.ndc}
              renderItem={({ item }) => (
                <SearchTile drug={item} onTap={() => navigateToCreate({ initialDrug: item })} />
              )}
              contentContainerStyle={{ paddingBottom: insets.bottom + 20 }}
            />
          )}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  body: {
    flex: 1,
    padding: 16,
  },
  heading: {
    ...AppTypography.headlineSmall,
    marginBottom: 16,
  },
  searchBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 24,
    paddingHorizontal: 16,
    height: 50,
    marginBottom: 16,
  },
  input: {
    flex: 1,
    fontSize: 16,
  },
  buttonRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  flex1: {
    flex: 1,
  },
  resultsContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  emptyResults: {
    textAlign: 'center',
    color: AppColors.textSecondary,
  }
});
