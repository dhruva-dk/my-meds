import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, Alert, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAtom } from 'jotai';
import { Ionicons } from '@expo/vector-icons';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

import Header from '../components/Header';
import PrimaryButton from '../components/PrimaryButton';
import { AppColors, AppTypography, GlobalStyles } from '../styles/theme';
import { profilesAtom, selectedProfileAtom } from '../store';
import { DatabaseService } from '../database/database';
import { UserProfile } from '../types';

type RootStackParamList = {
  SelectProfile: undefined;
  Home: undefined;
  CreateProfile: undefined;
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'SelectProfile'>;

interface Props {
  navigation: NavigationProp;
}

export default function SelectProfileScreen({ navigation }: Props) {
  const insets = useSafeAreaInsets();
  const [profiles, setProfiles] = useAtom(profilesAtom);
  const [, setSelectedProfile] = useAtom(selectedProfileAtom);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadProfiles();
  }, []);

  const loadProfiles = async () => {
    try {
      setLoading(true);
      const data = await DatabaseService.getAllProfiles();
      setProfiles(data);
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Failed to load profiles');
    } finally {
      setLoading(false);
    }
  };

  const handleSelectProfile = (profile: UserProfile) => {
    setSelectedProfile(profile);
    navigation.reset({
      index: 0,
      routes: [{ name: 'Home' }],
    });
  };

  const handleDeleteProfile = (profile: UserProfile) => {
    Alert.alert('Delete Profile', 'Are you sure you want to delete this profile? This action cannot be undone.', [
      { text: 'Cancel', style: 'cancel' },
      { 
        text: 'Delete', 
        style: 'destructive',
        onPress: async () => {
          if (profile.id) {
            await DatabaseService.deleteProfile(profile.id);
            await loadProfiles();
          }
        }
      }
    ]);
  };

  const renderProfile = ({ item }: { item: UserProfile }) => (
    <TouchableOpacity 
      style={styles.profileCard} 
      onPress={() => handleSelectProfile(item)}
      activeOpacity={0.7}
    >
      <View style={styles.cardRow}>
        <Ionicons name="person" size={32} color={AppColors.text} />
        <View style={styles.cardDetails}>
          <Text style={styles.profileName} numberOfLines={2}>{item.name}</Text>
          <View style={styles.dobRow}>
            <Ionicons name="gift-outline" size={16} color={AppColors.textSecondary} />
            <Text style={styles.dobText} numberOfLines={1}>{new Date(item.dob).toLocaleDateString()}</Text>
          </View>
        </View>
        <TouchableOpacity style={styles.menuIcon} onPress={() => handleDeleteProfile(item)}>
          <Ionicons name="ellipsis-vertical" size={24} color={AppColors.textSecondary} />
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={GlobalStyles.container}>
      <Header title="Select Profile" showBackButton={navigation.canGoBack()} onBackPressed={() => navigation.goBack()} />
      
      <View style={styles.body}>
        {loading ? (
          <ActivityIndicator size="large" color={AppColors.primary} style={styles.center} />
        ) : profiles.length === 0 ? (
          <Text style={styles.emptyText}>No profiles added yet. Add your first profile by pressing the button below.</Text>
        ) : (
          <FlatList
            data={profiles}
            keyExtractor={p => p.id?.toString() || Math.random().toString()}
            renderItem={renderProfile}
            contentContainerStyle={styles.listContent}
          />
        )}
      </View>

      <View style={[styles.fabContainer, { paddingBottom: Math.max(insets.bottom, 16) }]}>
        <PrimaryButton 
          title="Add Profile" 
          onPress={() => navigation.navigate('CreateProfile')} 
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  body: {
    flex: 1,
    paddingTop: 8,
  },
  center: {
    flex: 1,
    justifyContent: 'center',
  },
  emptyText: {
    ...AppTypography.bodyLarge,
    textAlign: 'center',
    marginTop: 40,
    paddingHorizontal: 16,
  },
  listContent: {
    paddingBottom: 100, // Space for FAB
  },
  profileCard: {
    backgroundColor: AppColors.lightBackgroundSecondary,
    borderRadius: 24,
    padding: 16,
    marginVertical: 4,
    marginHorizontal: 16,
    // Add shadow to match generic card if Flutter used it
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  cardRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  cardDetails: {
    flex: 1,
    marginLeft: 16,
  },
  profileName: {
    ...AppTypography.headlineSmall,
  },
  dobRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
  },
  dobText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    marginLeft: 8,
  },
  menuIcon: {
    padding: 8,
  },
  fabContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 16,
    backgroundColor: 'transparent',
  }
});
