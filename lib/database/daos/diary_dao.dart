import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../tables/diary_table.dart';
import '../../models/diary_entry_model.dart';

class DiaryDao {
  static final DiaryDao instance = DiaryDao._internal();
  factory DiaryDao() => instance;
  DiaryDao._internal();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ─── Insert Entry ─────────────────────────────
  Future<int> insertEntry(Map<String, dynamic> data) async {
    final db = await _db;
    return db.insert(
      DiaryTable.entriesTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Insert Medicines ─────────────────────────
  Future<void> insertMedicines(
    int entryId,
    List<DiaryMedicine> medicines,
  ) async {
    final db = await _db;
    final batch = db.batch();
    for (final m in medicines) {
      // ✅ Direct map banao
      batch.insert(
        DiaryTable.medicinesTable,
        {
          'entry_id': entryId,
          'medicine_name': m.medicineName,
          'taken': m.taken ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ─── Get Entry by Date ────────────────────────
  Future<DiaryEntryModel?> getEntryByDate(String date) async {
    final db = await _db;
    final rows = await db.query(
      DiaryTable.entriesTable,
      where: '${DiaryTable.date} = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final medicines = await _getMedicinesForEntry(rows.first['id'] as int);
    return DiaryEntryModel.fromMap(rows.first, medicines);
  }

  // ─── Get Last N Entries ───────────────────────
  Future<List<DiaryEntryModel>> getLastEntries(int count) async {
    final db = await _db;
    final rows = await db.query(
      DiaryTable.entriesTable,
      orderBy: '${DiaryTable.date} DESC',
      limit: count,
    );

    final entries = <DiaryEntryModel>[];
    for (final row in rows) {
      final medicines = await _getMedicinesForEntry(row['id'] as int);
      entries.add(DiaryEntryModel.fromMap(row, medicines));
    }
    return entries;
  }

  // ─── Get Entries Between Dates ────────────────
  Future<List<DiaryEntryModel>> getEntriesBetween(
    String startDate,
    String endDate,
  ) async {
    final db = await _db;
    final rows = await db.query(
      DiaryTable.entriesTable,
      where: '${DiaryTable.date} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${DiaryTable.date} DESC',
    );

    final entries = <DiaryEntryModel>[];
    for (final row in rows) {
      final medicines = await _getMedicinesForEntry(row['id'] as int);
      entries.add(DiaryEntryModel.fromMap(row, medicines));
    }
    return entries;
  }

  // ─── Get All Entries ──────────────────────────
  Future<List<DiaryEntryModel>> getAllEntries() async {
    final db = await _db;
    final rows = await db.query(
      DiaryTable.entriesTable,
      orderBy: '${DiaryTable.date} DESC',
    );

    final entries = <DiaryEntryModel>[];
    for (final row in rows) {
      final medicines = await _getMedicinesForEntry(row['id'] as int);
      entries.add(DiaryEntryModel.fromMap(row, medicines));
    }
    return entries;
  }

  // ─── Get Current Streak ───────────────────────
  Future<int> getCurrentStreak() async {
    final db = await _db;
    final rows = await db.query(
      DiaryTable.entriesTable,
      columns: [DiaryTable.date],
      orderBy: '${DiaryTable.date} DESC',
    );

    if (rows.isEmpty) return 0;

    int streak = 0;
    DateTime current = DateTime.now();

    for (final row in rows) {
      final entryDate = DateTime.parse(row[DiaryTable.date] as String);
      final diff = current.difference(entryDate).inDays;

      if (diff <= 1) {
        streak++;
        current = entryDate;
      } else {
        break;
      }
    }

    return streak;
  }

  // ─── Delete Entry ─────────────────────────────
  Future<void> deleteEntry(int id) async {
    final db = await _db;
    await db.delete(
      DiaryTable.entriesTable,
      where: '${DiaryTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ─── Private: Get Medicines for Entry ─────────
  Future<List<DiaryMedicine>> _getMedicinesForEntry(int entryId) async {
    final db = await _db;
    final rows = await db.query(
      DiaryTable.medicinesTable,
      where: '${DiaryTable.entryId} = ?',
      whereArgs: [entryId],
    );
    return rows.map(DiaryMedicine.fromMap).toList();
  }
}
