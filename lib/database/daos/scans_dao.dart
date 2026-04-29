import 'package:sqflite/sqflite.dart';
import '../../models/scan_result_model.dart';
import '../database_helper.dart';
import '../tables/scans_table.dart';

class ScansDao {
  static final ScansDao instance = ScansDao._internal();
  factory ScansDao() => instance;
  ScansDao._internal();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // Insert scan
  Future<int> insertScan({
    required ScanResult result,
    String? imagePath,
  }) async {
    final db = await _db;
    return db.insert(
      ScansTable.tableName,
      {
        ScansTable.medicineName: result.medicineName,
        ScansTable.whatItsFor: result.whatItsFor,
        ScansTable.whenToTake: result.whenToTake,
        ScansTable.avoid: result.avoid,
        ScansTable.additionalInfo: result.additionalInfo,
        ScansTable.imagePath: imagePath,
        ScansTable.fromCache: result.isFromCache ? 1 : 0,
        ScansTable.createdAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all scans
  Future<List<Map<String, dynamic>>> getAllScans() async {
    final db = await _db;
    return db.query(
      ScansTable.tableName,
      orderBy: '${ScansTable.createdAt} DESC',
    );
  }

  // Get recent scans
  Future<List<Map<String, dynamic>>> getRecentScans({
    int limit = 10,
  }) async {
    final db = await _db;
    return db.query(
      ScansTable.tableName,
      orderBy: '${ScansTable.createdAt} DESC',
      limit: limit,
    );
  }

  // Delete scan
  Future<int> deleteScan(int id) async {
    final db = await _db;
    return db.delete(
      ScansTable.tableName,
      where: '${ScansTable.id} = ?',
      whereArgs: [id],
    );
  }

  // Clear all
  Future<void> clearAll() async {
    final db = await _db;
    await db.delete(ScansTable.tableName);
  }
}
