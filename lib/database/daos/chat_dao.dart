import 'package:sqflite/sqflite.dart';
import '../../models/chat_message_model.dart';
import '../database_helper.dart';
import '../tables/chat_table.dart';

class ChatDao {
  static final ChatDao instance = ChatDao._internal();
  factory ChatDao() => instance;
  ChatDao._internal();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // Save message
  Future<int> insertMessage({
    required String sessionId,
    required ChatMessage message,
    int? scanId,
  }) async {
    final db = await _db;
    return db.insert(
      ChatTable.tableName,
      {
        ChatTable.sessionId: sessionId,
        ChatTable.messageType: message.messageType.name,
        ChatTable.contentType: message.contentType.name,
        ChatTable.text: message.text,
        ChatTable.imagePath: message.imagePath,
        ChatTable.scanId: scanId,
        ChatTable.createdAt: message.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get messages by session
  Future<List<Map<String, dynamic>>> getSessionMessages(
    String sessionId,
  ) async {
    final db = await _db;
    return db.query(
      ChatTable.tableName,
      where: '${ChatTable.sessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${ChatTable.createdAt} ASC',
    );
  }

  // Get all sessions
  Future<List<Map<String, dynamic>>> getAllSessions() async {
    final db = await _db;
    return db.rawQuery('''
      SELECT DISTINCT ${ChatTable.sessionId},
      MAX(${ChatTable.createdAt}) as lastMessage
      FROM ${ChatTable.tableName}
      GROUP BY ${ChatTable.sessionId}
      ORDER BY lastMessage DESC
    ''');
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    final db = await _db;
    await db.delete(
      ChatTable.tableName,
      where: '${ChatTable.sessionId} = ?',
      whereArgs: [sessionId],
    );
  }

  // Clear old sessions — 30 din se purane
  Future<void> clearOldSessions() async {
    final db = await _db;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    await db.delete(
      ChatTable.tableName,
      where: '${ChatTable.createdAt} < ?',
      whereArgs: [cutoff],
    );
  }
}
