import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String? id;
  final String doctorName;
  final String hospitalName;
  final String diagnosis;
  final String notes;
  final List<String> tags;
  final List<String> imageUrls;
  final DateTime date;
  final AiExtracted? aiExtracted;
  final DateTime createdAt;
  final String? aiSummary;

  PrescriptionModel({
    this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.diagnosis,
    required this.notes,
    required this.tags,
    required this.imageUrls,
    required this.date,
    this.aiExtracted,
    required this.createdAt,
    this.aiSummary,
  });

  factory PrescriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrescriptionModel(
      id: doc.id,
      doctorName: data['doctorName'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      notes: data['notes'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      date: (data['date'] as Timestamp).toDate(),
      aiExtracted: data['aiExtracted'] != null
          ? AiExtracted.fromMap(data['aiExtracted'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      aiSummary: data['aiSummary'],
    );
  }

  Map<String, dynamic> toMap() => {
        'doctorName': doctorName,
        'hospitalName': hospitalName,
        'diagnosis': diagnosis,
        'notes': notes,
        'tags': tags,
        'imageUrls': imageUrls,
        'date': Timestamp.fromDate(date),
        'aiExtracted': aiExtracted?.toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'aiSummary': aiSummary,
      };

  PrescriptionModel copyWith({
    String? id,
    String? doctorName,
    String? hospitalName,
    String? diagnosis,
    String? notes,
    List<String>? tags,
    List<String>? imageUrls,
    DateTime? date,
    AiExtracted? aiExtracted,
    DateTime? createdAt,
    String? aiSummary,
  }) =>
      PrescriptionModel(
        id: id ?? this.id,
        doctorName: doctorName ?? this.doctorName,
        hospitalName: hospitalName ?? this.hospitalName,
        diagnosis: diagnosis ?? this.diagnosis,
        notes: notes ?? this.notes,
        tags: tags ?? this.tags,
        imageUrls: imageUrls ?? this.imageUrls,
        date: date ?? this.date,
        aiExtracted: aiExtracted ?? this.aiExtracted,
        createdAt: createdAt ?? this.createdAt,
        aiSummary: aiSummary ?? this.aiSummary,
      );
}

class AiExtracted {
  final List<String> medicines;
  final String rawText;
  final DateTime scannedAt;

  AiExtracted({
    required this.medicines,
    required this.rawText,
    required this.scannedAt,
  });

  factory AiExtracted.fromMap(Map<String, dynamic> map) => AiExtracted(
        medicines: List<String>.from(map['medicines'] ?? []),
        rawText: map['rawText'] ?? '',
        scannedAt: (map['scannedAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'medicines': medicines,
        'rawText': rawText,
        'scannedAt': Timestamp.fromDate(scannedAt),
      };
}
