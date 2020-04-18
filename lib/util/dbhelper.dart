import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/model/todo.dart';

class DBHelper {
  static final DBHelper _dbHelper = DBHelper._internal();
  String tblTodo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DBHelper._internal();

  factory DBHelper() {
    return _dbHelper;
  }

  static Database _db;

  Future<Database> get dbObject async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  Future<Database> initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "todos.db";
    var dbToDos = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbToDos;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  Future<int> insertToDo(Todo todo) async {
    Database db = await this.dbObject;
    var result = await db.insert(tblTodo, todo.toMap());
    return result;
  }

  Future<List> getToDos() async {
    Database db = await this.dbObject;
    var result =
        await db.rawQuery("SELECT * FROM $tblTodo order by $colPriority ASC");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.dbObject;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT count (*) from $tblTodo"));
    return result;
  }

  Future<int> updateToDo(Todo todo) async {
    var db = await this.dbObject;
    var result = await db.update(tblTodo, todo.toMap(),
        where: "$colId = ?", whereArgs: [todo.id]);
    return result;
  }

  Future<int> deleteToDo(int id) async {
    var db = await this.dbObject;
    var result = await db.rawDelete('DELETE FROM $tblTodo WHERE $colId = $id');
    return result;
  }
}
