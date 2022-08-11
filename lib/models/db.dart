import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase extends ChangeNotifier {
  static const _databasename = "todo.db";
  static const _databaseversion = 1;

  static const table = "my_table";

  static const columnID = 'id';
  static const columnName = "todo";

  static Database? _database;

  TodoDatabase._privateConstructor();
  static final TodoDatabase instance = TodoDatabase._privateConstructor();

  Future<Database?> get databse async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentdirecoty = await getApplicationDocumentsDirectory();
    String path = join(documentdirecoty.path, _databasename);
    return await openDatabase(path,
        version: _databaseversion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnID INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL
      );
      ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.databse;
    int res = await db!.insert(table, row);
    notifyListeners();
    return res;
  }

  Future<List<Map<String, dynamic>>> queryall() async {
    Database? db = await instance.databse;
    return await db!.query(table);
  }

  Future<Map<String, dynamic>> queryone(int id) async {
    Database? db = await instance.databse;
    return (await db!.query(table, where: "id = ?", whereArgs: [id])).first;
  }

  Future<int> deletedata(int id) async {
    Database? db = await instance.databse;
    int res = await db!.delete(table, where: "id = ?", whereArgs: [id]);
    notifyListeners();
    return res;
  }
}
