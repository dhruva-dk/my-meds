import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:medication_tracker/model/user_profile.dart';

class ProfileDatabaseHelper {
  static const _databaseName = "UserProfileDatabase.db";
  static const _databaseVersion = 2;
  static const table = 'profile_table';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDob = 'dob';
  static const columnPcp = 'pcp';
  static const columnHealthConditions = 'healthConditions';
  static const columnPharmacy = 'pharmacy';

  ProfileDatabaseHelper._privateConstructor();
  static final ProfileDatabaseHelper instance =
      ProfileDatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade); // Added onUpgrade
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnDob TEXT NOT NULL,
        $columnPcp TEXT,
        $columnHealthConditions TEXT,
        $columnPharmacy TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnPharmacy TEXT');
    }
  }

  Future<int> insert(UserProfile profile) async {
    Database db = await instance.database;
    try {
      final map = profile.toMap();
      map.remove('id'); // Remove the ID key
      print("insert");
      return await db.insert(table, map);
    } catch (e) {
      throw DatabaseException('Failed to insert profile: $e');
    }
  }

  Future<int> update(UserProfile profile) async {
    Database db = await instance.database;
    try {
      print("update");
      return await db.update(table, profile.toMap(),
          where: '$columnId = ?', whereArgs: [profile.id]);
    } catch (e) {
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    try {
      return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete profile: $e');
    }
  }

  Future<void> deleteAllProfiles() async {
    Database db = await instance.database;
    await db.delete(table);
  }

  Future<List<UserProfile>> queryAllRows() async {
    Database db = await instance.database;
    try {
      var res = await db.query(table);
      return res.isNotEmpty
          ? res.map((c) => UserProfile.fromMap(c)).toList()
          : [];
    } catch (e) {
      throw DatabaseException('Failed to retrieve profiles: $e');
    }
  }
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => "Database Exception: $message";
}
