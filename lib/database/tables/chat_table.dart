class ChatTable {
  static const String tableName = 'chat_messages';

  static const String id = 'id';
  static const String sessionId = 'session_id';
  static const String messageType = 'message_type';
  static const String contentType = 'content_type';
  static const String text = 'text';
  static const String imagePath = 'image_path';
  static const String scanId = 'scan_id';
  static const String createdAt = 'created_at';

  static const String createQuery = '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $sessionId TEXT NOT NULL,
      $messageType TEXT NOT NULL,
      $contentType TEXT NOT NULL,
      $text TEXT,
      $imagePath TEXT,
      $scanId INTEGER,
      $createdAt TEXT NOT NULL
    )
  ''';
}
