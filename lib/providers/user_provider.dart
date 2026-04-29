// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String plan;
  final int freeCredits;
  final int adCredits;
  final int adsWatchedToday;
  final bool termsAccepted;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.plan,
    required this.freeCredits,
    required this.adCredits,
    required this.adsWatchedToday,
    required this.termsAccepted,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      plan: data['plan'] ?? 'free',
      freeCredits: data['freeCredits'] ?? 5,
      adCredits: data['adCredits'] ?? 0,
      adsWatchedToday: data['adsWatchedToday'] ?? 0,
      termsAccepted: data['termsAccepted'] ?? false,
    );
  }

  bool get isPro => plan == 'pro';
  int get totalCredits => freeCredits + adCredits;
  bool get hasCredits => isPro || totalCredits > 0;
}

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _userSubscription; // ✅ Track subscription

  UserProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUser => _user != null;

  void listenToUser(String uid) {
    // ✅ Pehle wala subscription cancel karo
    _userSubscription?.cancel();

    _userSubscription = _firestoreService.getUserStream(uid).listen(
      (doc) {
        if (doc.exists) {
          _user = UserModel.fromFirestore(doc);
          notifyListeners();
        }
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void clearUser() {
    _userSubscription?.cancel(); // ✅ Logout pe cancel karo
    _userSubscription = null;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
