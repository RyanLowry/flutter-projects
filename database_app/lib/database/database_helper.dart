import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:database_app/database/model/user.dart';
import 'dart:async';

class DatabaseHelper{

  static Database _db;

  Future<Database> get db async{
    if (_db != null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }
  Future<Database> initDb() async{
    String docDir = await getDatabasesPath();
    String path = join(docDir,"task_database.db");
    var db = await openDatabase(path,version:1, onCreate:(db,version) async{
      await db.execute(
        "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, fname TEXT, lname TEXT)",
      );
    });
    return db;
  }

  Future<int> insertUser (User user) async{
    Database dbClient = await db;
    int res = await dbClient.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }
  Future<void> deleteUser (int id) async{
    Database dbClient = await db;
    await dbClient.delete(
      'users',
      where:"id = ?",
      whereArgs: [id],
    );
  }
  Future<void> updateUser (User user) async{
    Database dbClient = await db;
    await dbClient.update(
      'users',
      user.toMap(),
      where:"id = ?",
      whereArgs: [user.id],
    );
  }

  Future<List<User>> getAllUsers () async{
    Database dbClient = await db;
    final List<Map<String,dynamic>> maps = await dbClient.query('users');

    return List.generate(maps.length,(int i){
      return User(
        id:maps[i]['id'],
        firstName:maps[i]['fname'],
        lastName:maps[i]['lname'],
      );
    });
  }

}