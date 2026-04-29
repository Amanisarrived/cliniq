import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../tables/reminders_table.dart';

class RemindersDao {
  static final RemindersDao instance = RemindersDao._internal();
  factory RemindersDao() => instance;
  RemindersDao._internal();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ─── Insert Reminder ──────────────────────────
  Future<int> insertReminder(Map<String, dynamic> data) async {
    final db = await _db;
    return db.insert(
      RemindersTable.tableName,
      {
        ...data,
        RemindersTable.createdAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Update Firestore ID ──────────────────────
  Future<void> updateFirestoreId(int id, String firestoreId) async {
    final db = await _db;
    await db.update(
      RemindersTable.tableName,
      {RemindersTable.firestoreId: firestoreId},
      where: '${RemindersTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ─── Get Active Reminders ─────────────────────
  Future<List<Map<String, dynamic>>> getActiveReminders() async {
    final db = await _db;
    return db.query(
      RemindersTable.tableName,
      where: '${RemindersTable.isActive} = ?',
      whereArgs: [1],
      orderBy: '${RemindersTable.createdAt} DESC',
    );
  }

  // ─── Get Today Reminders ──────────────────────
  Future<List<Map<String, dynamic>>> getTodayReminders() async {
    final db = await _db;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return db.query(
      RemindersTable.tableName,
      where: '''
        ${RemindersTable.isActive} = 1
        AND ${RemindersTable.startDate} <= ?
        AND (
          ${RemindersTable.endDate} IS NULL
          OR ${RemindersTable.endDate} >= ?
        )
      ''',
      whereArgs: [today, today],
      orderBy: '${RemindersTable.morningTime} ASC',
    );
  }

  // ─── Update Reminder ──────────────────────────
  Future<int> updateReminder(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await _db;
    return db.update(
      RemindersTable.tableName,
      data,
      where: '${RemindersTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ─── Toggle Active ────────────────────────────
  Future<void> toggleActive(int id, bool isActive) async {
    final db = await _db;
    await db.update(
      RemindersTable.tableName,
      {RemindersTable.isActive: isActive ? 1 : 0},
      where: '${RemindersTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ─── Delete Reminder ──────────────────────────
  Future<int> deleteReminder(int id) async {
    final db = await _db;
    return db.delete(
      RemindersTable.tableName,
      where: '${RemindersTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ─── Get All Reminders ────────────────────────
  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final db = await _db;
    return db.query(
      RemindersTable.tableName,
      orderBy: '${RemindersTable.createdAt} DESC',
    );
  }
}
