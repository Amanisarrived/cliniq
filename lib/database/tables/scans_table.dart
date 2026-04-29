class ScansTable {
  static const String tableName = 'scans';

  static const String id = 'id';
  static const String medicineName = 'medicine_name';
  static const String whatItsFor = 'what_its_for';
  static const String whenToTake = 'when_to_take';
  static const String avoid = 'avoid';
  static const String additionalInfo = 'additional_info';
  static const String imagePath = 'image_path';
  static const String fromCache = 'from_cache';
  static const String createdAt = 'created_at';

  static const String createQuery = '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $medicineName TEXT NOT NULL,
      $whatItsFor TEXT NOT NULL,
      $whenToTake TEXT NOT NULL,
      $avoid TEXT NOT NULL,
      $additionalInfo TEXT,
      $imagePath TEXT,
      $fromCache INTEGER DEFAULT 0,
      $createdAt TEXT NOT NULL
    )
  ''';
}
