import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getUserStream(String uid) =>
      _db.collection('users').doc(uid).snapshots();

  Future<DocumentSnapshot> getUser(String uid) =>
      _db.collection('users').doc(uid).get();

  Future<void> updateFcmToken(String uid, String token) =>
      _db.collection('users').doc(uid).update({
        'fcmToken': token,
      });

  Stream<DocumentSnapshot> getAppConfig() =>
      _db.collection('appConfig').doc('config').snapshots();

  // ─── Prescriptions ───────────────────────────────────────────

  Future<DocumentReference> addPrescription(
    String uid,
    Map<String, dynamic> data,
  ) =>
      _db.collection('users').doc(uid).collection('prescriptions').add(data);

  Stream<QuerySnapshot> getPrescriptionsStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('prescriptions')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> updatePrescription(
    String uid,
    String prescriptionId,
    Map<String, dynamic> data,
  ) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('prescriptions')
          .doc(prescriptionId)
          .update(data);

  Future<void> deletePrescription(String uid, String prescriptionId) => _db
      .collection('users')
      .doc(uid)
      .collection('prescriptions')
      .doc(prescriptionId)
      .delete();

  Future<int> getPrescriptionCount(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('prescriptions')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> rewardAdCredits(String uid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable('rewardAdCredits');
      await callable.call({'uid': uid});
      debugPrint('Ad credits rewarded ✅');
    } catch (e) {
      debugPrint('rewardAdCredits error: $e');
    }
  }
}
