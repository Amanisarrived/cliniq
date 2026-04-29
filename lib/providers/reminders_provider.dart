import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../database/daos/reminders_dao.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';

enum RemindersStatus { idle, loading, success, error }

class RemindersProvider extends ChangeNotifier {
  final RemindersDao _dao = RemindersDao.instance;
  final NotificationService _notifService = NotificationService.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ReminderModel> _allReminders = [];
  List<ReminderModel> _todayReminders = [];
  RemindersStatus _status = RemindersStatus.idle;
  String? _error;

  List<ReminderModel> get allReminders => List.unmodifiable(_allReminders);
  List<ReminderModel> get todayReminders => List.unmodifiable(_todayReminders);
  RemindersStatus get status => _status;
  bool get isLoading => _status == RemindersStatus.loading;
  String? get error => _error;

  // ─── Load Reminders ───────────────────────────
  Future<void> loadReminders() async {
    _setStatus(RemindersStatus.loading);
    try {
      final allRows = await _dao.getAllReminders();
      final todayRows = await _dao.getTodayReminders();

      _allReminders = allRows.map(ReminderModel.fromMap).toList();
      _todayReminders = todayRows.map(ReminderModel.fromMap).toList();

      _setStatus(RemindersStatus.success);
    } catch (e) {
      _error = e.toString();
      _setStatus(RemindersStatus.error);
      debugPrint('Load reminders error: $e');
    }
  }

  // ─── Add Reminder ─────────────────────────────
  Future<bool> addReminder(ReminderModel reminder) async {
    try {
      final id = await _dao.insertReminder(reminder.toMap());
      final savedReminder = reminder.copyWith(id: id);

      await _notifService.scheduleReminder(savedReminder);
      await _saveToFirestore(savedReminder);
      await loadReminders();
      return true;
    } catch (e) {
      debugPrint('Add reminder error: $e');
      return false;
    }
  }

  // ─── Toggle Active ────────────────────────────
  Future<void> toggleReminder(int id, bool isActive) async {
    try {
      await _dao.toggleActive(id, isActive);

      final reminder = _allReminders.firstWhere((r) => r.id == id);

      if (isActive) {
        await _notifService.scheduleReminder(
          reminder.copyWith(isActive: true),
        );
      } else {
        await _notifService.cancelReminder(id);
      }

      await loadReminders();
    } catch (e) {
      debugPrint('Toggle reminder error: $e');
    }
  }

  // ─── Delete Reminder ──────────────────────────
  Future<void> deleteReminder(int id) async {
    try {
      await _dao.deleteReminder(id);
      await _notifService.cancelReminder(id);

      // ✅ firestoreId se delete karo
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final reminder = _allReminders.firstWhere((r) => r.id == id);
        if (reminder.firestoreId != null) {
          await _db
              .collection('users')
              .doc(uid)
              .collection('reminders')
              .doc(reminder.firestoreId)
              .delete();
        }
      }

      _allReminders = _allReminders.where((r) => r.id != id).toList();
      _todayReminders = _todayReminders.where((r) => r.id != id).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Delete reminder error: $e');
    }
  }

  // ─── Save to Firestore ────────────────────────
  Future<void> _saveToFirestore(ReminderModel reminder) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // ✅ Doc ref pehle banao — ID save karo
      final docRef =
          _db.collection('users').doc(uid).collection('reminders').doc();

      await docRef.set({
        'firestoreId': docRef.id,
        'medicineName': reminder.medicineName,
        'isMorning': reminder.isMorning,
        'isAfternoon': reminder.isAfternoon,
        'isNight': reminder.isNight,
        'morningTime': reminder.morningTime,
        'afternoonTime': reminder.afternoonTime,
        'nightTime': reminder.nightTime,
        'startDate': reminder.startDate.toIso8601String(),
        'endDate': reminder.endDate?.toIso8601String(),
        'familyMember': reminder.familyMember,
        'notes': reminder.notes,
        'isActive': reminder.isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ SQLite mein firestoreId save karo
      if (reminder.id != null) {
        await _dao.updateFirestoreId(reminder.id!, docRef.id);
      }
    } catch (e) {
      debugPrint('Firestore backup error: $e');
    }
  }

  // ─── Update Reminder ──────────────────────────
  Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      await _dao.updateReminder(reminder.id!, reminder.toMap());

      await _notifService.cancelReminder(reminder.id!);
      if (reminder.isActive) {
        await _notifService.scheduleReminder(reminder);
      }

      await loadReminders();
      return true;
    } catch (e) {
      debugPrint('Update reminder error: $e');
      return false;
    }
  }

  // ─── Sync from Firestore ──────────────────────
  Future<void> syncFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final existing = await _dao.getAllReminders();
      if (existing.isNotEmpty) return;

      final snapshot =
          await _db.collection('users').doc(uid).collection('reminders').get();

      if (snapshot.docs.isEmpty) return;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reminder = ReminderModel(
          medicineName: data['medicineName'] ?? '',
          isMorning: data['isMorning'] ?? false,
          isAfternoon: data['isAfternoon'] ?? false,
          isNight: data['isNight'] ?? false,
          morningTime: data['morningTime'] ?? '08:00',
          afternoonTime: data['afternoonTime'] ?? '14:00',
          nightTime: data['nightTime'] ?? '21:00',
          startDate: DateTime.parse(data['startDate']),
          endDate:
              data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
          familyMember: data['familyMember'] ?? 'Self',
          notes: data['notes'] ?? '',
          isActive: data['isActive'] ?? true,
          createdAt: DateTime.now(),
          firestoreId: doc.id, // ✅ firestoreId save karo
        );

        final id = await _dao.insertReminder(reminder.toMap());

        // ✅ firestoreId SQLite mein save karo
        await _dao.updateFirestoreId(id, doc.id);

        if (reminder.isActive) {
          await _notifService.scheduleReminder(reminder.copyWith(id: id));
        }
      }

      await loadReminders();
      debugPrint('Synced ${snapshot.docs.length} reminders from Firestore ✅');
    } catch (e) {
      debugPrint('Sync from Firestore error: $e');
    }
  }

  void _setStatus(RemindersStatus status) {
    _status = status;
    notifyListeners();
  }
}
