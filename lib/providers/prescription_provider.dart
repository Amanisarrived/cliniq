import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/prescription_model.dart';
import '../services/prescription_service.dart';

enum PrescriptionStatus { idle, loading, uploading, success, error }

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionService _service = PrescriptionService();

  List<PrescriptionModel> _prescriptions = [];
  PrescriptionStatus _status = PrescriptionStatus.idle;
  String? _error;

  List<PrescriptionModel> get prescriptions => _prescriptions;
  PrescriptionStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == PrescriptionStatus.loading;
  bool get isUploading => _status == PrescriptionStatus.uploading;

  // Free limit
  static const int freePrescriptionLimit = 5;

  bool canAddMore(bool isPro) =>
      isPro || _prescriptions.length < freePrescriptionLimit;

  // ─── Listen to prescriptions stream ──────────────────────────

  void listenToPrescriptions(String uid) {
    _setStatus(PrescriptionStatus.loading);

    _service.getPrescriptions(uid).listen(
      (list) {
        _prescriptions = list;
        _setStatus(PrescriptionStatus.idle);
      },
      onError: (e) {
        debugPrint('Prescriptions stream error: $e');
        _setError('Load nahi ho saka');
      },
    );
  }

  // ─── Add Prescription ─────────────────────────────────────────

  Future<bool> addPrescription({
    required String uid,
    required bool isPro,
    required PrescriptionModel prescription,
    required List<File> imageFiles,
  }) async {
    if (!canAddMore(isPro)) {
      _setError('Free limit reached. Upgrade to Pro for unlimited!');
      return false;
    }

    try {
      _setStatus(PrescriptionStatus.uploading);

      // 1. Images upload karo
      final imageUrls = imageFiles.isNotEmpty
          ? await _service.uploadImages(uid, imageFiles)
          : <String>[];

      // 2. OCR already hua hai — rawText lelo
      final ocrText = prescription.aiExtracted?.rawText ?? '';

      // 3. AI Summary generate karo (silently — no error if fails)
      String? aiSummary;
      if (ocrText.isNotEmpty) {
        aiSummary = await _service.summarizePrescription(ocrText);
      }

      // 4. Prescription with imageUrls + aiSummary
      final updated = prescription.copyWith(
        imageUrls: imageUrls,
        aiSummary: aiSummary,
      );

      // 5. Firestore mein save
      await _service.addPrescription(uid, updated);

      _setStatus(PrescriptionStatus.success);
      return true;
    } catch (e) {
      debugPrint('Add prescription error: $e');
      _setError('Could not save. Please try again.');
      return false;
    }
  }

  // ─── Delete Prescription ──────────────────────────────────────

  Future<bool> deletePrescription(String uid, PrescriptionModel p) async {
    try {
      _setStatus(PrescriptionStatus.loading);
      await _service.deletePrescription(uid, p);
      _setStatus(PrescriptionStatus.idle);
      return true;
    } catch (e) {
      debugPrint('Delete prescription error: $e');
      _setError('Delete nahi ho saka');
      return false;
    }
  }

  // ─── OCR Scan ────────────────────────────────────────────────

  Future<AiExtracted?> scanPrescription(File imageFile) async {
    try {
      return await _service.extractTextFromImage(imageFile);
    } catch (e) {
      debugPrint('OCR error: $e');
      return null;
    }
  }

  void _setStatus(PrescriptionStatus s) {
    _status = s;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = PrescriptionStatus.error;
    _error = msg;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _status = PrescriptionStatus.idle;
    notifyListeners();
  }
}
