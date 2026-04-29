import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/prescription_model.dart';
import 'firestore_service.dart';

class PrescriptionService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  // ─── Upload Images ────────────────────────────────────

  Future<List<String>> uploadImages(String uid, List<File> files) async {
    final List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      final ref = _storage.ref().child(
          'users/$uid/prescriptions/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      final task = await ref.putFile(
        files[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await task.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  // ─── Delete Image ─────────────────────────────────────

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Image delete error: $e');
    }
  }

  // ─── OCR ─────────────────────────────────────────────

  Future<AiExtracted> extractTextFromImage(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await textRecognizer.processImage(inputImage);
      final rawText = recognized.text;
      final medicines = _parseMedicines(rawText);
      return AiExtracted(
        medicines: medicines,
        rawText: rawText,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('OCR error: $e');
      return AiExtracted(
        medicines: [],
        rawText: '',
        scannedAt: DateTime.now(),
      );
    } finally {
      textRecognizer.close();
    }
  }

  List<String> _parseMedicines(String text) {
    final lines = text.split('\n');
    final medicines = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (RegExp(
        r'(Tab|Cap|Syp|Inj|Tablet|Capsule|Syrup|Injection|mg|ml)',
        caseSensitive: false,
      ).hasMatch(trimmed)) {
        medicines.add(trimmed);
      }
    }
    return medicines.take(15).toList();
  }

  // ─── AI Summary via Cloud Function ───────────────────

  Future<String?> summarizePrescription(String ocrText) async {
    if (ocrText.trim().isEmpty) return null;
    try {
      final callable = _functions.httpsCallable('summarizePrescription');
      final result = await callable.call({'ocrText': ocrText});
      final data = Map<String, dynamic>.from(result.data);
      if (data['success'] == true && data['summary'] != null) {
        return data['summary'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('AI summary error: $e');
      return null;
    }
  }

  // ─── CRUD ─────────────────────────────────────────────

  Future<String> addPrescription(
    String uid,
    PrescriptionModel prescription,
  ) async {
    final ref = await _firestoreService.addPrescription(
      uid,
      prescription.toMap(),
    );
    return ref.id;
  }

  Stream<List<PrescriptionModel>> getPrescriptions(String uid) =>
      _firestoreService.getPrescriptionsStream(uid).map(
            (snap) => snap.docs
                .map((doc) => PrescriptionModel.fromFirestore(doc))
                .toList(),
          );

  Future<void> updatePrescription(
    String uid,
    PrescriptionModel prescription,
  ) =>
      _firestoreService.updatePrescription(
        uid,
        prescription.id!,
        prescription.toMap(),
      );

  Future<void> deletePrescription(
    String uid,
    PrescriptionModel prescription,
  ) async {
    for (final url in prescription.imageUrls) {
      await deleteImage(url);
    }
    await _firestoreService.deletePrescription(uid, prescription.id!);
  }

  Future<int> getPrescriptionCount(String uid) =>
      _firestoreService.getPrescriptionCount(uid);
}
