import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'cow_manager.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            mobile TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cows (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cow_id TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            breed TEXT NOT NULL,
            lactation_month INTEGER NOT NULL,
            image_path TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Database get db {
    if (_db == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _db!;
  }

  // Users
  Future<int> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String mobile,
  }) async {
    return await db.insert(
      'users',
      {
        'name': name,
        'username': username,
        'email': email,
        'password': password, // In production, hash this
        'mobile': mobile,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, Object?>?> login({
    required String login, // username or email
    required String password,
  }) async {
    final rows = await db.query(
      'users',
      where: '(username = ? OR email = ?) AND password = ?',
      whereArgs: [login, login, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  // Cows
  Future<int> addCow({
    required String cowId,
    required String name,
    required String breed,
    required int lactationMonth,
    String? imagePath,
  }) async {
    return await db.insert(
      'cows',
      {
        'cow_id': cowId,
        'name': name,
        'breed': breed,
        'lactation_month': lactationMonth,
        'image_path': imagePath,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Map<String, Object?>>> listCows() async {
    return await db.query('cows', orderBy: 'created_at DESC');
  }

  // Metrics for dashboard
  Future<int> getCowCount() async {
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM cows');
    return (res.first['c'] as int?) ?? 0;
  }

  Future<double> getAverageLactationMonth() async {
    final res = await db.rawQuery('SELECT AVG(lactation_month) as avg_lm FROM cows');
    final v = res.first['avg_lm'];
    if (v == null) return 0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0;
  }

  Future<int> getRecentBirthsCount({int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM cows WHERE created_at >= ?',
      [since],
    );
    return (res.first['c'] as int?) ?? 0;
  }
}