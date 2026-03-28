import * as SQLite from 'expo-sqlite';
import * as FileSystem from 'expo-file-system';
import { Platform } from 'react-native';
import { UserProfile, Medication } from '../types';

const DB_NAME = 'CombinedDatabase.db';

export class DatabaseService {
  private static db: SQLite.SQLiteDatabase | null = null;

  static async initDatabase() {
    if (this.db) return this.db;
    
    // Check if the old flutter database needs to be copied over
    await this.migrateFlutterDatabase();
    
    // Open the Expo SQLite database
    this.db = await SQLite.openDatabaseAsync(DB_NAME);
    
    // Ensure tables exist
    await this.db.execAsync(`
      CREATE TABLE IF NOT EXISTS profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        pcp TEXT,
        healthConditions TEXT,
        pharmacy TEXT
      );

      CREATE TABLE IF NOT EXISTS medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        additionalInfo TEXT NOT NULL,
        imageUrl TEXT,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
      );
    `);

    // We also run the split database migration if required.
    // However, if we copied CombinedDatabase.db, this is skipped.
    return this.db;
  }

  private static async migrateFlutterDatabase() {
    try {
      // expo-sqlite stores databases in FileSystem.documentDirectory + 'SQLite/'
      // @ts-ignore
      const expoDbDir = `${FileSystem.documentDirectory}SQLite/`;
      const expoDbPath = `${expoDbDir}${DB_NAME}`;
      
      const dirInfo = await FileSystem.getInfoAsync(expoDbDir);
      if (!dirInfo.exists) {
        await FileSystem.makeDirectoryAsync(expoDbDir, { intermediates: true });
      }

      const expoDbInfo = await FileSystem.getInfoAsync(expoDbPath);
      if (expoDbInfo.exists) {
        // Already migrated
        return;
      }

      let oldFlutterDbPath = '';
      if (Platform.OS === 'android') {
        // Flutter's getDatabasesPath() on Android usually points here
        oldFlutterDbPath = `/data/user/0/com.dhruvakumar.medication_tracker/databases/${DB_NAME}`;
      } else if (Platform.OS === 'ios') {
        // Flutter's getDatabasesPath() on iOS is typically NSDocumentDirectory -> which is FileSystem.documentDirectory
        // However, sqflite often saves inside a custom folder or directly in Documents. 
        // We will check default Flutter locations:
        // @ts-ignore
        oldFlutterDbPath = `${FileSystem.documentDirectory}${DB_NAME}`;
      }

      if (oldFlutterDbPath) {
        const oldInfo = await FileSystem.getInfoAsync(oldFlutterDbPath);
        if (oldInfo.exists) {
          console.log(`Migrating Flutter DB from ${oldFlutterDbPath} to ${expoDbPath}`);
          await FileSystem.copyAsync({
            from: oldFlutterDbPath,
            to: expoDbPath,
          });
        } else {
          console.log(`Flutter DB not found at ${oldFlutterDbPath}, proceeding with fresh DB.`);
        }
      }
    } catch (error) {
      console.warn('Error during Flutter DB migration check:', error);
    }
  }

  // Profiles CRUD
  static async getAllProfiles(): Promise<UserProfile[]> {
    const db = await this.initDatabase();
    let profiles = await db.getAllAsync<UserProfile>('SELECT * FROM profiles');
    if (profiles.length === 0) {
      await db.runAsync(
        'INSERT INTO profiles (name, dob, pcp, healthConditions, pharmacy) VALUES (?, ?, ?, ?, ?)',
        ['Me', new Date(1990, 0, 1).toISOString(), '', '', '']
      );
      profiles = await db.getAllAsync<UserProfile>('SELECT * FROM profiles');
    }
    return profiles;
  }

  static async insertProfile(profile: UserProfile): Promise<number> {
    const db = await this.initDatabase();
    const result = await db.runAsync(
      `INSERT INTO profiles (name, dob, pcp, healthConditions, pharmacy) VALUES (?, ?, ?, ?, ?)`,
      [profile.name, profile.dob, profile.pcp, profile.healthConditions, profile.pharmacy]
    );
    return result.lastInsertRowId;
  }

  static async updateProfile(profile: UserProfile): Promise<void> {
    if (!profile.id) return;
    const db = await this.initDatabase();
    await db.runAsync(
      `UPDATE profiles SET name = ?, dob = ?, pcp = ?, healthConditions = ?, pharmacy = ? WHERE id = ?`,
      [profile.name, profile.dob, profile.pcp, profile.healthConditions, profile.pharmacy, profile.id]
    );
  }

  static async deleteProfile(id: number): Promise<void> {
    const db = await this.initDatabase();
    await db.runAsync('DELETE FROM profiles WHERE id = ?', [id]);
  }

  // Medications CRUD
  static async getMedicationsForProfile(profileId: number): Promise<Medication[]> {
    const db = await this.initDatabase();
    return await db.getAllAsync<Medication>(
      'SELECT * FROM medications WHERE profile_id = ?',
      [profileId]
    );
  }

  static async insertMedication(medication: Medication): Promise<number> {
    const db = await this.initDatabase();
    const result = await db.runAsync(
      `INSERT INTO medications (profile_id, name, dosage, additionalInfo, imageUrl) VALUES (?, ?, ?, ?, ?)`,
      [medication.profile_id, medication.name, medication.dosage, medication.additionalInfo, medication.imageUrl]
    );
    return result.lastInsertRowId;
  }

  static async updateMedication(medication: Medication): Promise<void> {
    if (!medication.id) return;
    const db = await this.initDatabase();
    await db.runAsync(
      `UPDATE medications SET name = ?, dosage = ?, additionalInfo = ?, imageUrl = ? WHERE id = ?`,
      [medication.name, medication.dosage, medication.additionalInfo, medication.imageUrl, medication.id]
    );
  }

  static async deleteMedication(id: number): Promise<void> {
    const db = await this.initDatabase();
    await db.runAsync('DELETE FROM medications WHERE id = ?', [id]);
  }
}
