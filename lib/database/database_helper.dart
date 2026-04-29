import 'package:cliniq/database/tables/diary_table.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'tables/chat_table.dart';
import 'tables/reminders_table.dart';
import 'tables/scans_table.dart';

class DatabaseHelper {
  static const String _dbName = 'cliniq.db';
  static const int _dbVersion = 3;

  // Singleton
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(ScansTable.createQuery);
    await db.execute(ChatTable.createQuery);
    await db.execute(RemindersTable.createQuery);
    await db.execute(DiaryTable.createEntriesTable);
    await db.execute(DiaryTable.createMedicinesTable);
    debugPrint('DB created — version $version');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(DiaryTable.createEntriesTable);
      await db.execute(DiaryTable.createMedicinesTable);
    }
    if (oldVersion < 3) {
      // ✅ firestoreId column add karo existing users ke liye
      await db.execute(
        'ALTER TABLE ${RemindersTable.tableName} ADD COLUMN ${RemindersTable.firestoreId} TEXT',
      );
    }
    debugPrint('DB upgrade $oldVersion → $newVersion');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
