import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:second_project/booking.dart';
import 'package:second_project/function.dart';
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
    //await deleteDatabase(path);
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
        client_name TEXT,
        log_in BOOLEAN default 0,
        last_login BOOLEAN default 0
      )
    ''');
    print("done");
  }

  void drop_table() async {
    print("DROP");
    Database dbClient0 = await db;
    dbClient0.execute("DROP TABLE session");
    print("DROP DONE");
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database dbClient = await db;
    await dbClient.update(
      'session',
      // Set the values to update.
      {'log_in': 0, 'last_login': 0},
      // Specify the record to update based on its ID.
      where: 'id > 0',
    );
/*     dbClient.execute("DROP TABLE IF EXISTS session");
    print("TABLE DROPED"); */

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

  Future<void> updateRecord_login(
      String mobile, String name, String email) async {
    // Get a reference to the database.
    Database dbClient = await db;

    // Update the record with the specified ID.
    await dbClient.update(
      'session',
      // Set the values to update.
      {'log_in': 0, 'last_login': 0},
      // Specify the record to update based on its ID.
      where: 'id > 0',
    );
    await dbClient.update(
      'session',
      // Set the values to update.
      {
        'client_mobile': mobile,
        'client_email': email,
        'client_name': name,
        'log_in': 1,
        'last_login': 1
      },
      // Specify the record to update based on its ID.
      where: 'client_mobile = ?',
      whereArgs: [mobile],
    );
    print("DB updated after login");
  }

  Future<void> update_logout_user() async {
    // Get a reference to the database.
    Database dbClient = await db;

    // Update the record with the specified ID.
    await dbClient.update(
      'session',
      // Set the values to update.
      {'log_in': 0, 'last_login': 0},
      // Specify the record to update based on its ID.
      where: 'id > 0',
    );

    print("DB updated to all logout ..");
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database dbClient = await db;
    return await dbClient
        .rawQuery('select * from session ORDER by id DESC limit 1');
  }

  Future<List<Map<String, dynamic>>> check_user_session() async {
    Database dbClient = await db;
    return await dbClient.rawQuery(
        'select client_mobile,client_name,client_email from session where log_in=true and last_login=true ORDER by id DESC limit 1');
  }

  Future<bool> user_exist(String mobile, String email) async {
    Database dbClient = await db;
    bool exists = false;
    List<Map> result = await dbClient.rawQuery(
        'select id from session where client_mobile="$mobile" or client_email="$email"');
    int result_length = result.length;
    if (result_length > 0) {
      var exists = true;
    }

    return exists;
  }

  Future<void> auto_login(BuildContext context) async {
    Database dbClient = await db;
    String client_mobile1 = '';
    String client_name1 = '';
    String client_email1 = '';
    List<Map> result = await dbClient.rawQuery(
        "select client_name,client_mobile,client_email from session where log_in=1 and last_login=1");
    if (result.length == 1) {
      for (var elements in result) {
        client_mobile1 = elements['client_mobile'];
        client_name1 = elements['client_name'];
        client_email1 = elements['client_email'];
        sendDataToServer(context, client_mobile1, client_email1);
      }
    }
  }
}
