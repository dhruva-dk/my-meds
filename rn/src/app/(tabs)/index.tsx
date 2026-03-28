import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAtom } from 'jotai';
import { useRouter } from 'expo-router';

import { AppColors, AppTypography, GlobalStyles } from '../../styles/theme';
import { selectedProfileAtom, medicationsAtom } from '../../store';
import { DatabaseService } from '../../database/database';
import MedicationTile from '../../components/MedicationTile';
import { Medication } from '../../types';
import { PDFService } from '../../services/pdf';

export default function HomeScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [profile, setSelectedProfile] = useAtom(selectedProfileAtom);
  const [medications, setMedications] = useAtom(medicationsAtom);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!profile) {
      DatabaseService.getAllProfiles().then(all => {
        if (all.length > 0) setSelectedProfile(all[0]);
      });
    } else {
      loadMeds();
    }
  }, [profile]);

  const loadMeds = async () => {
    if (!profile?.id) return;
    try {
      setLoading(true);
      const data = await DatabaseService.getMedicationsForProfile(profile.id);
      setMedications(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async () => {
    try {
      await PDFService.shareMedications(medications);
    } catch (e: any) {
      Alert.alert('Export Failed', e.message);
    }
  };



  const renderHeader = () => {
    const safeTop = Math.max(insets.top, 20);
    return (
      <View style={[styles.headerContainer, { paddingTop: safeTop + 8 }]}>
        <View style={{ flex: 1 }}>
          <Text style={styles.headerTitle} numberOfLines={1}>{profile?.name || "Name N/A"}</Text>
          <Text style={styles.headerDob}>{profile?.dob ? new Date(profile.dob).toLocaleDateString() : "N/A"}</Text>
        </View>
        <TouchableOpacity onPress={handleExport} style={styles.exportButton} activeOpacity={0.8}>
          <Ionicons name="share-outline" size={22} color="#000000" />
          <Text style={styles.exportButtonText}>Export</Text>
        </TouchableOpacity>
      </View>
    );
  };

  const renderMedication = ({ item }: { item: Medication }) => (
    <MedicationTile 
      medication={item} 
      onEdit={() => router.push({ pathname: '/EditMedication', params: { medication: JSON.stringify(item) } })} 
      onDeleteSuccess={loadMeds}
    />
  );

  return (
    <View style={GlobalStyles.container}>
      {renderHeader()}
      
      <View style={styles.body}>
        {medications.length > 0 && (
          <Text style={styles.sectionTitle}>Your Medications</Text>
        )}

        {loading ? (
          <ActivityIndicator size="large" color={AppColors.primary} style={styles.center} />
        ) : medications.length === 0 ? (
          <View style={styles.center}>
            <Text style={styles.emptyText}>No medications. Add by pressing the + button below.</Text>
          </View>
        ) : (
          <FlatList
            data={medications}
            keyExtractor={m => m.id?.toString() || Math.random().toString()}
            renderItem={renderMedication}
            contentContainerStyle={styles.listContent}
          />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  headerContainer: {
    backgroundColor: AppColors.lightAccentSecondary, // theme.colorScheme.secondary
    borderBottomLeftRadius: 48,
    borderBottomRightRadius: 48,
    paddingLeft: 32,
    paddingRight: 32,
    paddingBottom: 16,
    width: '100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  exportButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 24,
    elevation: 2,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 4,
  },
  exportButtonText: {
    color: '#000000',
    fontSize: 15,
    fontWeight: 'bold',
    marginLeft: 6,
  },
  headerTitle: {
    ...AppTypography.headlineLarge,
    color: '#FFFFFF',
    marginBottom: 4,
  },
  headerDob: {
    ...AppTypography.headlineSmall,
    color: '#FFFFFF',
  },
  body: {
    flex: 1,
  },
  sectionTitle: {
    ...AppTypography.headlineSmall,
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
  },
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    ...AppTypography.bodyMedium,
    textAlign: 'center',
    paddingHorizontal: 16,
  },
  listContent: {
    paddingBottom: 24,
  }
});
