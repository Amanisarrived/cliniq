class DiaryEntryModel {
  final int? id;
  final DateTime date;
  final int mood; // 1-5 (1=exhausted, 5=amazing)
  final List<String> symptoms;
  final int waterGlasses; // 0-10
  final List<DiaryMedicine> medicines;
  final String? notes;
  final DateTime createdAt;

  const DiaryEntryModel({
    this.id,
    required this.date,
    required this.mood,
    required this.symptoms,
    required this.waterGlasses,
    required this.medicines,
    this.notes,
    required this.createdAt,
  });

  // From SQLite
  factory DiaryEntryModel.fromMap(
    Map<String, dynamic> map,
    List<DiaryMedicine> medicines,
  ) {
    return DiaryEntryModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date']),
      mood: map['mood'] as int,
      symptoms: map['symptoms'].toString().isEmpty
          ? []
          : (map['symptoms'] as String).split(','),
      waterGlasses: map['water_glasses'] as int,
      medicines: medicines,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // To SQLite
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String().split('T')[0],
        'mood': mood,
        'symptoms': symptoms.join(','),
        'water_glasses': waterGlasses,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  // Copy with
  DiaryEntryModel copyWith({
    int? id,
    DateTime? date,
    int? mood,
    List<String>? symptoms,
    int? waterGlasses,
    List<DiaryMedicine>? medicines,
    String? notes,
    DateTime? createdAt,
  }) =>
      DiaryEntryModel(
        id: id ?? this.id,
        date: date ?? this.date,
        mood: mood ?? this.mood,
        symptoms: symptoms ?? this.symptoms,
        waterGlasses: waterGlasses ?? this.waterGlasses,
        medicines: medicines ?? this.medicines,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  // Helpers
  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😴';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '😐';
    }
  }

  String get moodLabel {
    switch (mood) {
      case 1:
        return 'Exhausted';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Amazing';
      default:
        return 'Okay';
    }
  }

  bool get hasSymptoms => symptoms.isNotEmpty;
  bool get allMedicinesTaken =>
      medicines.isEmpty || medicines.every((m) => m.taken);
  int get medicinesTakenCount => medicines.where((m) => m.taken).length;
}

class DiaryMedicine {
  final int? id;
  final int entryId;
  final String medicineName;
  final bool taken;

  const DiaryMedicine({
    this.id,
    required this.entryId,
    required this.medicineName,
    required this.taken,
  });

  factory DiaryMedicine.fromMap(Map<String, dynamic> map) => DiaryMedicine(
        id: map['id'] as int?,
        entryId: map['entry_id'] as int,
        medicineName: map['medicine_name'] as String,
        taken: map['taken'] == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'entry_id': entryId,
        'medicine_name': medicineName,
        'taken': taken ? 1 : 0,
      };

  DiaryMedicine copyWith({bool? taken}) => DiaryMedicine(
        id: id,
        entryId: entryId,
        medicineName: medicineName,
        taken: taken ?? this.taken,
      );
}
