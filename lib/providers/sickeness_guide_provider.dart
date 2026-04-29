import 'package:flutter/foundation.dart';
import '../services/sickness_guide_service.dart';

enum GuideStatus {
  idle,
  questioning,
  waitingAnswer,
  guiding,
  success,
  followingUp,
  error,
  noCredits,
}

class FollowUpMessage {
  final String question;
  final String? answer;
  const FollowUpMessage({required this.question, this.answer});
}

class SicknessGuideProvider extends ChangeNotifier {
  final SicknessGuideService _service = SicknessGuideService();

  GuideStatus _status = GuideStatus.idle;
  String? _questions;
  String? _guide;
  String? _error;
  String _symptoms = '';

  // Follow ups
  final List<FollowUpMessage> _followUps = [];
  static const int maxFollowUps = 2;

  // Getters
  GuideStatus get status => _status;
  String? get questions => _questions;
  String? get guide => _guide;
  String? get error => _error;
  String get symptoms => _symptoms;
  List<FollowUpMessage> get followUps => List.unmodifiable(_followUps);
  bool get isLoading =>
      _status == GuideStatus.questioning ||
      _status == GuideStatus.guiding ||
      _status == GuideStatus.followingUp;
  bool get hasResult => _status == GuideStatus.success;
  bool get isWaitingAnswer => _status == GuideStatus.waitingAnswer;
  bool get canFollowUp =>
      _status == GuideStatus.success && _followUps.length < maxFollowUps;
  int get followUpsRemaining => maxFollowUps - _followUps.length;

  // ─── Step 1: Submit symptoms ──────────────────────────
  Future<void> submitSymptoms(String symptoms) async {
    if (symptoms.trim().length < 3) {
      _setError('Please describe your symptoms in more detail');
      return;
    }

    _symptoms = symptoms.trim();
    _setStatus(GuideStatus.questioning);

    try {
      final result = await _service.getQuestions(symptoms.trim());
      if (!_handleNoCredits(result)) return;

      _questions = result['guide'] as String;
      _setStatus(GuideStatus.waitingAnswer);
    } catch (e) {
      debugPrint('submitSymptoms error: $e');
      _setError('Could not connect. Please try again.');
    }
  }

  // ─── Step 2: Submit answers ───────────────────────────
  Future<void> submitAnswers(String answers) async {
    if (answers.trim().isEmpty) return;

    _setStatus(GuideStatus.guiding);

    try {
      final result = await _service.getGuide(_symptoms, answers.trim());
      if (!_handleNoCredits(result)) return;

      _guide = result['guide'] as String;
      _setStatus(GuideStatus.success);
    } catch (e) {
      debugPrint('submitAnswers error: $e');
      _setError('Could not fetch guide. Please try again.');
    }
  }

  // ─── Step 3: Follow up ────────────────────────────────
  Future<void> submitFollowUp(String question) async {
    if (question.trim().isEmpty || !canFollowUp) return;

    // Add question to list (answer pending)
    _followUps.add(FollowUpMessage(question: question.trim()));
    _setStatus(GuideStatus.followingUp);

    try {
      final result = await _service.getFollowUp(
        _symptoms,
        _guide ?? '',
        question.trim(),
      );
      if (!_handleNoCredits(result)) return;

      // Update last follow up with answer
      final answer = result['guide'] as String;
      final updated = FollowUpMessage(
        question: _followUps.last.question,
        answer: answer,
      );
      _followUps[_followUps.length - 1] = updated;
      _setStatus(GuideStatus.success);
    } catch (e) {
      debugPrint('submitFollowUp error: $e');
      // Remove last follow up on error
      _followUps.removeLast();
      _setError('Could not get answer. Please try again.');
    }
  }

  // ─── No credits check ─────────────────────────────────
  bool _handleNoCredits(Map<String, dynamic> result) {
    if (result['success'] == false && result['error'] == 'no_credits') {
      _status = GuideStatus.noCredits;
      notifyListeners();
      return false;
    }
    return true;
  }

  void reset() {
    _status = GuideStatus.idle;
    _questions = null;
    _guide = null;
    _error = null;
    _symptoms = '';
    _followUps.clear();
    notifyListeners();
  }

  void _setStatus(GuideStatus s) {
    _status = s;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = GuideStatus.error;
    _error = msg;
    notifyListeners();
  }
}
