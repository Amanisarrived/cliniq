class RemindersTable {
  static const String tableName = 'reminders';

  static const String id = 'id';
  static const String medicineName = 'medicine_name';
  static const String imagePath = 'image_path';
  static const String notes = 'notes';
  static const String isMorning = 'is_morning';
  static const String isAfternoon = 'is_afternoon';
  static const String isNight = 'is_night';
  static const String morningTime = 'morning_time';
  static const String afternoonTime = 'afternoon_time';
  static const String nightTime = 'night_time';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String isActive = 'is_active';
  static const String familyMember = 'family_member';
  static const String createdAt = 'created_at';
  static const String firestoreId = 'firestore_id'; // ✅ Add kiya

  static const String createQuery = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $medicineName TEXT NOT NULL,
      $imagePath TEXT,
      $notes TEXT,
      $isMorning INTEGER DEFAULT 0,
      $isAfternoon INTEGER DEFAULT 0,
      $isNight INTEGER DEFAULT 0,
      $morningTime TEXT DEFAULT '08:00',
      $afternoonTime TEXT DEFAULT '14:00',
      $nightTime TEXT DEFAULT '21:00',
      $startDate TEXT NOT NULL,
      $endDate TEXT,
      $isActive INTEGER DEFAULT 1,
      $familyMember TEXT DEFAULT 'Self',
      $createdAt TEXT NOT NULL,
      $firestoreId TEXT
    )
  ''';
}
