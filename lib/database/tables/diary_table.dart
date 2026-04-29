class DiaryTable {
  // ─── Entries Table ────────────────────────────
  static const String entriesTable = 'diary_entries';

  static const String id = 'id';
  static const String date = 'date';
  static const String mood = 'mood';
  static const String symptoms = 'symptoms';
  static const String waterGlasses = 'water_glasses';
  static const String notes = 'notes';
  static const String createdAt = 'created_at';

  static const String createEntriesTable = '''
    CREATE TABLE IF NOT EXISTS $entriesTable (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $date TEXT NOT NULL UNIQUE,
      $mood INTEGER NOT NULL,
      $symptoms TEXT DEFAULT '',
      $waterGlasses INTEGER DEFAULT 0,
      $notes TEXT,
      $createdAt TEXT NOT NULL
    )
  ''';

  // ─── Medicines Table ──────────────────────────
  static const String medicinesTable = 'diary_medicines';

  static const String medicineId = 'id';
  static const String entryId = 'entry_id';
  static const String medicineName = 'medicine_name';
  static const String taken = 'taken';

  static const String createMedicinesTable = '''
    CREATE TABLE IF NOT EXISTS $medicinesTable (
      $medicineId INTEGER PRIMARY KEY AUTOINCREMENT,
      $entryId INTEGER NOT NULL,
      $medicineName TEXT NOT NULL,
      $taken INTEGER DEFAULT 0,
      FOREIGN KEY ($entryId) REFERENCES $entriesTable($id) ON DELETE CASCADE
    )
  ''';
}
