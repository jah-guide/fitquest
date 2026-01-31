// fitquest/lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  // Web fallback storage
  static const _webStorageKey = 'fitquest_web_exercises';

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      // On web we don't use sqflite; callers should use the CRUD methods which
      // handle web storage. Throwing here prevents accidental direct DB use.
      throw UnsupportedError(
        'Database not available on web. Use provider fallbacks.',
      );
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'fitquest.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        isSynced INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // CRUD operations
  Future<int> insertExercise(Exercise exercise) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webStorageKey);
      final list = raw == null ? [] : json.decode(raw) as List<dynamic>;
      final items = list.map((e) => Map<String, dynamic>.from(e)).toList();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final map = exercise.toMap()..['id'] = newId;
      items.add(map);
      await prefs.setString(_webStorageKey, json.encode(items));
      return newId;
    }

    final db = await database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> getAllExercises() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webStorageKey);
      if (raw == null) return [];
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((m) => Exercise.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    }

    final db = await database;
    final maps = await db.query('exercises', orderBy: 'name');
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByCategory(String category) async {
    if (kIsWeb) {
      final all = await getAllExercises();
      return all.where((e) => e.category == category).toList();
    }

    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name',
    );
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getUnsyncedExercises() async {
    if (kIsWeb) {
      final all = await getAllExercises();
      return all.where((e) => e.isSynced == false).toList();
    }

    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<int> updateExercise(Exercise exercise) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webStorageKey);
      final list = raw == null ? [] : json.decode(raw) as List<dynamic>;
      final items = list.map((e) => Map<String, dynamic>.from(e)).toList();
      final idx = items.indexWhere((m) => m['id'] == exercise.id);
      if (idx >= 0) {
        items[idx] = exercise.toMap();
        await prefs.setString(_webStorageKey, json.encode(items));
        return 1;
      }
      return 0;
    }

    final db = await database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webStorageKey);
      final list = raw == null ? [] : json.decode(raw) as List<dynamic>;
      final items = list.map((e) => Map<String, dynamic>.from(e)).toList();
      items.removeWhere((m) => m['id'] == id);
      await prefs.setString(_webStorageKey, json.encode(items));
      return 1;
    }

    final db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllAsSynced() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webStorageKey);
      if (raw == null) return;
      final list = json.decode(raw) as List<dynamic>;
      final items = list.map((e) => Map<String, dynamic>.from(e)).toList();
      for (final m in items) {
        m['isSynced'] = 1;
      }
      await prefs.setString(_webStorageKey, json.encode(items));
      return;
    }

    final db = await database;
    await db.update(
      'exercises',
      {'isSynced': 1},
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }
}
