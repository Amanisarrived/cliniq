class ReminderModel {
  final int? id;
  final String medicineName;
  final String? imagePath;
  final String? notes;
  final bool isMorning;
  final bool isAfternoon;
  final bool isNight;
  final String morningTime;
  final String afternoonTime;
  final String nightTime;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String familyMember;
  final DateTime createdAt;
  final String? firestoreId; // ✅ Add kiya

  const ReminderModel({
    this.id,
    required this.medicineName,
    this.imagePath,
    this.notes,
    this.isMorning = false,
    this.isAfternoon = false,
    this.isNight = false,
    this.morningTime = '08:00',
    this.afternoonTime = '14:00',
    this.nightTime = '21:00',
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.familyMember = 'Self',
    required this.createdAt,
    this.firestoreId, // ✅ Add kiya
  });

  // From SQLite
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      medicineName: map['medicine_name'] ?? '',
      imagePath: map['image_path'],
      notes: map['notes'],
      isMorning: map['is_morning'] == 1,
      isAfternoon: map['is_afternoon'] == 1,
      isNight: map['is_night'] == 1,
      morningTime: map['morning_time'] ?? '08:00',
      afternoonTime: map['afternoon_time'] ?? '14:00',
      nightTime: map['night_time'] ?? '21:00',
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isActive: map['is_active'] == 1,
      familyMember: map['family_member'] ?? 'Self',
      createdAt: DateTime.parse(map['created_at']),
      firestoreId: map['firestore_id'] as String?, // ✅ Add kiya
    );
  }

  // To SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'medicine_name': medicineName,
      'image_path': imagePath,
      'notes': notes,
      'is_morning': isMorning ? 1 : 0,
      'is_afternoon': isAfternoon ? 1 : 0,
      'is_night': isNight ? 1 : 0,
      'morning_time': morningTime,
      'afternoon_time': afternoonTime,
      'night_time': nightTime,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_active': isActive ? 1 : 0,
      'family_member': familyMember,
      'created_at': createdAt.toIso8601String(),
      if (firestoreId != null) 'firestore_id': firestoreId, // ✅ Add kiya
    };
  }

  // Copy with
  ReminderModel copyWith({
    int? id,
    String? medicineName,
    String? imagePath,
    String? notes,
    bool? isMorning,
    bool? isAfternoon,
    bool? isNight,
    String? morningTime,
    String? afternoonTime,
    String? nightTime,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? familyMember,
    String? firestoreId, // ✅ Add kiya
  }) {
    return ReminderModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      isMorning: isMorning ?? this.isMorning,
      isAfternoon: isAfternoon ?? this.isAfternoon,
      isNight: isNight ?? this.isNight,
      morningTime: morningTime ?? this.morningTime,
      afternoonTime: afternoonTime ?? this.afternoonTime,
      nightTime: nightTime ?? this.nightTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      familyMember: familyMember ?? this.familyMember,
      createdAt: createdAt,
      firestoreId: firestoreId ?? this.firestoreId, // ✅ Add kiya
    );
  }

  // Helpers
  bool get hasAnyTime => isMorning || isAfternoon || isNight;

  List<String> get activeTimes {
    final times = <String>[];
    if (isMorning) times.add('Morning $morningTime');
    if (isAfternoon) times.add('Afternoon $afternoonTime');
    if (isNight) times.add('Night $nightTime');
    return times;
  }
}
