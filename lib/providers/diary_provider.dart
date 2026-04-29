import 'package:cliniq/services/diary_service.dart';
import 'package:cliniq/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import '../database/daos/diary_dao.dart';
import '../database/daos/reminders_dao.dart';
import '../models/diary_entry_model.dart';
import '../models/reminder_model.dart';

enum DiaryStatus { idle, loading, saving, success, error }

class DiaryProvider extends ChangeNotifier {
  final DiaryDao _dao = DiaryDao.instance;
  final RemindersDao _remindersDao = RemindersDao.instance;

  DiaryStatus _status = DiaryStatus.idle;
  DiaryEntryModel? _todayEntry;
  List<DiaryEntryModel> _allEntries = [];
  List<ReminderModel> _activeReminders = [];
  int _streak = 0;
  String? _error;

  DiaryStatus get status => _status;
  DiaryEntryModel? get todayEntry => _todayEntry;
  List<DiaryEntryModel> get allEntries => List.unmodifiable(_allEntries);
  List<ReminderModel> get activeReminders =>
      List.unmodifiable(_activeReminders);
  int get streak => _streak;
  String? get error => _error;
  bool get isLoading => _status == DiaryStatus.loading;
  bool get isSaving => _status == DiaryStatus.saving;
  bool get hasCheckedInToday => _todayEntry != null;
  String? _aiInsights;
  bool _isGeneratingInsights = false;

  String? get aiInsights => _aiInsights;
  bool get isGeneratingInsights => _isGeneratingInsights;
  DateTime? _lastInsightGenerated; // ✅ Track karo

  bool get canGenerateInsights {
    if (_lastInsightGenerated == null) return true;
    return DateTime.now().difference(_lastInsightGenerated!).inDays >= 7;
  }

  int get daysUntilNextInsight {
    if (_lastInsightGenerated == null) return 0;
    final diff = DateTime.now().difference(_lastInsightGenerated!).inDays;
    return diff >= 7 ? 0 : 7 - diff;
  }

  // ─── Load Today ───────────────────────────────
  Future<void> loadToday() async {
    _setStatus(DiaryStatus.loading);
    try {
      final today = _todayDateStr();
      _todayEntry = await _dao.getEntryByDate(today);
      _streak = await _dao.getCurrentStreak();
      await _loadActiveReminders();

      // ✅ Schedule/cancel diary reminder
      if (_todayEntry != null) {
        await NotificationService.instance.cancelDiaryReminder();
      } else {
        await NotificationService.instance.scheduleDiaryReminder();
      }

      _setStatus(DiaryStatus.idle);
    } catch (e) {
      debugPrint('loadToday error: $e');
      _setError('Could not load diary');
    }
  }

  // ─── Load All Entries ─────────────────────────
  Future<void> loadAllEntries() async {
    try {
      _allEntries = await _dao.getAllEntries();
      notifyListeners();
    } catch (e) {
      debugPrint('loadAllEntries error: $e');
    }
  }

  // ─── Load Last N Entries ──────────────────────
  Future<List<DiaryEntryModel>> getLastEntries(int count) async {
    try {
      return await _dao.getLastEntries(count);
    } catch (e) {
      debugPrint('getLastEntries error: $e');
      return [];
    }
  }

  // ─── Load Entries Between Dates ───────────────
  Future<List<DiaryEntryModel>> getEntriesBetween(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _dao.getEntriesBetween(
        start.toIso8601String().split('T')[0],
        end.toIso8601String().split('T')[0],
      );
    } catch (e) {
      debugPrint('getEntriesBetween error: $e');
      return [];
    }
  }

  // ─── Save Check-in ────────────────────────────
  Future<bool> saveCheckIn({
    required int mood,
    required List<String> symptoms,
    required int waterGlasses,
    required List<DiaryMedicine> medicines,
    String? notes,
  }) async {
    _setStatus(DiaryStatus.saving);
    try {
      final entry = DiaryEntryModel(
        date: DateTime.now(),
        mood: mood,
        symptoms: symptoms,
        waterGlasses: waterGlasses,
        medicines: medicines,
        notes: notes,
        createdAt: DateTime.now(),
      );

      // ✅ Entry save karo
      final id = await _dao.insertEntry(entry.toMap());

      // ✅ Medicines seedha pass karo
      if (medicines.isNotEmpty) {
        await _dao.insertMedicines(id, medicines);
      }

      // ✅ Reload
      _todayEntry = await _dao.getEntryByDate(_todayDateStr());
      _streak = await _dao.getCurrentStreak();
      notifyListeners();

      if (medicines.isNotEmpty) {
        await _dao.insertMedicines(id, medicines);
      }

// ✅ Firestore backup
      final savedEntry = await _dao.getEntryByDate(_todayDateStr());
      if (savedEntry != null) {
        await DiaryService.instance.saveEntry(savedEntry);
      }
      await NotificationService.instance.cancelDiaryReminder();
      _setStatus(DiaryStatus.success);
      return true;
    } catch (e) {
      debugPrint('saveCheckIn error: $e');
      _setError('Could not save check-in');
      return false;
    }
  }

  // ─── Load Active Reminders ────────────────────
  Future<void> _loadActiveReminders() async {
    try {
      final rows = await _remindersDao.getActiveReminders();
      _activeReminders = rows.map(ReminderModel.fromMap).toList();
    } catch (e) {
      debugPrint('loadActiveReminders error: $e');
    }
  }

  // ─── Get Medicines for Check-in ───────────────
  List<DiaryMedicine> getMedicinesForCheckIn() {
    return _activeReminders
        .map((r) => DiaryMedicine(
              entryId: 0,
              medicineName: r.medicineName,
              taken: false,
            ))
        .toList();
  }

  // ─── Weekly Stats ─────────────────────────────
  Future<Map<String, dynamic>> getWeeklyStats() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final entries = await getEntriesBetween(weekAgo, now);

      if (entries.isEmpty) return {};
      final avgMood =
          entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
      final allSymptoms = entries.expand((e) => e.symptoms).toList();
      final symptomCount = <String, int>{};
      for (final s in allSymptoms) {
        symptomCount[s] = (symptomCount[s] ?? 0) + 1;
      }

      // Avg water
      final avgWater =
          entries.map((e) => e.waterGlasses).reduce((a, b) => a + b) /
              entries.length;

      // Medicine adherence
      final totalMeds = entries.expand((e) => e.medicines).length;
      final takenMeds =
          entries.expand((e) => e.medicines).where((m) => m.taken).length;
      final adherence =
          totalMeds > 0 ? (takenMeds / totalMeds * 100).round() : 0;

      return {
        'entries': entries,
        'avgMood': avgMood,
        'avgWater': avgWater,
        'adherence': adherence,
        'symptomCount': symptomCount,
        'checkInDays': entries.length,
      };
    } catch (e) {
      debugPrint('getWeeklyStats error: $e');
      return {};
    }
  }

  // ─── Helpers ──────────────────────────────────
  String _todayDateStr() => DateTime.now().toIso8601String().split('T')[0];

  void _setStatus(DiaryStatus s) {
    _status = s;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = DiaryStatus.error;
    _error = msg;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _status = DiaryStatus.idle;
    notifyListeners();
  }

  Future<void> generateAiInsights() async {
    if (_isGeneratingInsights) return;

    // ✅ Week mein sirf ek baar
    if (_lastInsightGenerated != null) {
      final diff = DateTime.now().difference(_lastInsightGenerated!).inDays;
      if (diff < 7) return;
    }

    final stats = await getWeeklyStats();
    if (stats.isEmpty) return;

    // ✅ Loading start pehle
    _isGeneratingInsights = true;
    notifyListeners();

    try {
      final entries = (stats['entries'] as List<DiaryEntryModel>?) ?? [];

      final weekData = {
        'moods': entries.map((e) => e.mood).toList(),
        'avgMood': (stats['avgMood'] as double?)?.toStringAsFixed(1) ?? '0',
        'checkInDays': stats['checkInDays'] ?? 0,
        'symptoms': entries.expand((e) => e.symptoms).toSet().toList(),
        'avgWater': (stats['avgWater'] as double?)?.toStringAsFixed(1) ?? '0',
        'adherence': stats['adherence'] ?? 0,
      };

      _aiInsights = await DiaryService.instance.generateInsights(weekData);

      // ✅ Sirf success pe time save karo
      if (_aiInsights != null) {
        _lastInsightGenerated = DateTime.now();
      }
    } catch (e) {
      debugPrint('generateAiInsights error: $e');
    }

    _isGeneratingInsights = false;
    notifyListeners();
  }
}
