// database_service.dart
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const _databaseName = "MedicationDatabase.db";
  static const _databaseVersion = 3;

  static const medicationTable = 'medication_table';
  static const profileTable = 'profiles';

  // Make this a singleton
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create profiles table
    await db.execute('''
      CREATE TABLE $profileTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        pcp TEXT,
        healthConditions TEXT,
        pharmacy TEXT
      )
    ''');

    // Create medications table with foreign key
    await db.execute('''
      CREATE TABLE $medicationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        additionalInfo TEXT NOT NULL,
        imageUrl TEXT,
        FOREIGN KEY (profile_id) REFERENCES $profileTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      if (oldVersion < 3) {
        // 1. Create profiles table
        await txn.execute('''
          CREATE TABLE $profileTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dob TEXT NOT NULL,
            pcp TEXT,
            healthConditions TEXT,
            pharmacy TEXT
          )
        ''');

        // 2. Add profile_id to existing medications table
        await txn.execute(
            'ALTER TABLE $medicationTable ADD COLUMN profile_id INTEGER REFERENCES $profileTable(id)');

        // 3. Import existing profile or create default
        String oldProfilePath =
            join(await getDatabasesPath(), "UserProfileDatabase.db");
        int defaultProfileId;

        if (await databaseExists(oldProfilePath)) {
          Database oldProfileDb = await openDatabase(oldProfilePath);
          List<Map<String, dynamic>> oldProfiles =
              await oldProfileDb.query('profile_table');

          defaultProfileId = oldProfiles.isNotEmpty
              ? await txn.insert(profileTable, oldProfiles[0])
              : await txn.insert(profileTable, {
                  'name': 'Default Profile',
                  'dob': DateTime.now().toIso8601String(),
                  'pcp': '',
                  'healthConditions': '',
                  'pharmacy': ''
                });

          await oldProfileDb.close();
          await deleteDatabase(oldProfilePath);
        } else {
          defaultProfileId = await txn.insert(profileTable, {
            'name': 'Default Profile',
            'dob': DateTime.now().toIso8601String(),
            'pcp': '',
            'healthConditions': '',
            'pharmacy': ''
          });
        }

        // 4. Link existing medications to the profile
        await txn.execute(
            'UPDATE $medicationTable SET profile_id = ?', [defaultProfileId]);
      }
    });
  }

  // Profile Methods
  Future<List<UserProfile>> getAllProfiles() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(profileTable);
    return List.generate(maps.length, (i) => UserProfile.fromMap(maps[i]));
  }

  Future<UserProfile?> getProfile(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      profileTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<int> insertProfile(UserProfile profile) async {
    Database db = await database;
    return await db.insert(profileTable, profile.toMap());
  }

  Future<int> updateProfile(UserProfile profile) async {
    Database db = await database;
    return await db.update(
      profileTable,
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    Database db = await database;
    return await db.delete(
      profileTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Medication Methods
  Future<List<Medication>> getMedicationsForProfile(int profileId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      medicationTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<int> insertMedication(Medication medication) async {
    Database db = await database;
    return await db.insert(medicationTable, medication.toMap());
  }

  Future<int> updateMedication(Medication medication) async {
    Database db = await database;
    return await db.update(
      medicationTable,
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    Database db = await database;
    return await db.delete(
      medicationTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
