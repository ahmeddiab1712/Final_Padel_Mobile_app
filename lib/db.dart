import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  DatabaseHelper._internal();

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mydatabase.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY,
        branch_name TEXT,
        branch_id INTEGER,
        client_mobile TEXT,
        client_email TEXT,
        device_id TEXT,
        device_info TEXT,
        device_model TEXT,
        device_version TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database dbClient = await db;
    return await dbClient.insert('session', row);
  }

  Future<void> updateRecord(String mobile, String branch_name) async {
    // Get a reference to the database.
    Database dbClient = await db;

    // Update the record with the specified ID.
    await dbClient.update(
      'session',
      // Set the values to update.
      {'branch_name': branch_name},
      // Specify the record to update based on its ID.
      where: 'client_mobile = ?',
      whereArgs: [mobile],
    );
    print("DB updated" + branch_name);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database dbClient = await db;
    return await dbClient
        .rawQuery('select * from session ORDER by id DESC limit 1');
  }
}
