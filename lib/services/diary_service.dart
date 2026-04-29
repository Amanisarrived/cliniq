import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/diary_entry_model.dart';

class DiaryService {
  static final DiaryService instance = DiaryService._internal();
  factory DiaryService() => instance;
  DiaryService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Save to Firestore ────────────────────────
  Future<void> saveEntry(DiaryEntryModel entry) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final dateStr = entry.date.toIso8601String().split('T')[0];

      await _db
          .collection('users')
          .doc(uid)
          .collection('diary')
          .doc(dateStr)
          .set({
        'date': dateStr,
        'mood': entry.mood,
        'moodEmoji': entry.moodEmoji,
        'moodLabel': entry.moodLabel,
        'symptoms': entry.symptoms,
        'waterGlasses': entry.waterGlasses,
        'notes': entry.notes,
        'medicines': entry.medicines
            .map((m) => {
                  'name': m.medicineName,
                  'taken': m.taken,
                })
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Diary entry saved to Firestore ✅');
    } catch (e) {
      debugPrint('Diary Firestore save error: $e');
    }
  }

  // ─── Sync from Firestore → SQLite ─────────────
  Future<List<Map<String, dynamic>>> getEntriesFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('diary')
          .orderBy('date', descending: true)
          .limit(30)
          .get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Diary Firestore fetch error: $e');
      return [];
    }
  }

  // ─── Generate AI Insights ─────────────────────
  Future<String?> generateInsights(Map<String, dynamic> weekData) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable('generateDiaryInsights');

      final result = await callable.call({'weekData': weekData});
      final data = Map<String, dynamic>.from(result.data);

      if (data['success'] == true) {
        return data['analysis'] as String;
      } else if (data['error'] == 'no_credits') {
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('generateInsights error: $e');
      return null;
    }
  }
}
