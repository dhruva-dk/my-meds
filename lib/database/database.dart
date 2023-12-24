import 'package:medication_tracker/model/medication_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// DatabaseException class for handling errors
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => "Database Exception: $message";
}

class DatabaseHelper {
  static final _databaseName = "MedicationDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'medication_table';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnDosage = 'dosage';
  static final columnAdditionalInfo = 'additionalInfo';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Open the database and create the table
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medication_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        additionalInfo TEXT NOT NULL
      )
    ''');
  }

  // Helper methods

  // Insert a Medication object into the database with error handling
  Future<int> insert(Medication medication) async {
    Database db = await instance.database;
    try {
      return await db.insert(table, medication.toJson());
    } catch (e) {
      throw DatabaseException('Failed to insert medication: $e');
    }
  }

  // Update a Medication object in the database with error handling
  Future<int> update(Medication medication) async {
    Database db = await instance.database;
    try {
      return await db.update(table, medication.toJson(),
          where: '$columnId = ?', whereArgs: [medication.id]);
    } catch (e) {
      throw DatabaseException('Failed to update medication: $e');
    }
  }

  // Delete a Medication object from the database with error handling
  Future<int> delete(int id) async {
    Database db = await instance.database;
    try {
      return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete medication: $e');
    }
  }

  // Retrieve all Medications from the database with error handling
  Future<List<Medication>> queryAllRows() async {
    Database db = await instance.database;
    try {
      var res = await db.query(table);
      return res.isNotEmpty
          ? res.map((c) => Medication.fromJson(c)).toList()
          : [];
    } catch (e) {
      throw DatabaseException('Failed to retrieve medications: $e');
    }
  }
}
