import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase extends ChangeNotifier {
  static const _databasename = "todo.db";
  static const _databaseversion = 1;

  static const table = "my_table";

  // column names
  static const columnID = 'id';
  static const columnName = "todo";

  // a database
  static Database? _database;

  // privateconstructor
  TodoDatabase._privateConstructor();
  static final TodoDatabase instance = TodoDatabase._privateConstructor();

  // asking for a database
  Future<Database?> get databse async {
    if (_database != null) return _database;

    // create a database if one doesn't exist
    _database = await _initDatabase();
    return _database;
  }

  // function to return a database
  _initDatabase() async {
    Directory documentdirecoty = await getApplicationDocumentsDirectory();
    String path = join(documentdirecoty.path, _databasename);
    return await openDatabase(path,
        version: _databaseversion, onCreate: _onCreate);
  }

  // create a database since it doesn't exist
  Future _onCreate(Database db, int version) async {
    // sql code
    await db.execute('''
      CREATE TABLE $table (
        $columnID INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL
      );
      ''');
  }

  // functions to insert data
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.databse;
    int res = await db!.insert(table, row);
    notifyListeners();
    return res;
  }

  // function to query all the rows
  Future<List<Map<String, dynamic>>> queryall() async {
    Database? db = await instance.databse;
    return await db!.query(table);
  }

  // function to query all the rows
  Future<Map<String, dynamic>> queryone(int id) async {
    Database? db = await instance.databse;
    return (await db!.query(table, where: "id = ?", whereArgs: [id])).first;
  }

  // function to delete some data
  Future<int> deletedata(int id) async {
    Database? db = await instance.databse;
    int res = await db!.delete(table, where: "id = ?", whereArgs: [id]);
    notifyListeners();
    return res;
  }
}
