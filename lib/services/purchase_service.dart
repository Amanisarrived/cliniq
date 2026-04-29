import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static final PurchaseService instance = PurchaseService._internal();
  factory PurchaseService() => instance;
  PurchaseService._internal();

  static const String _entitlementId = 'Cliniq Pro';
  bool _initialized = false;

  // ─── Initialize ───────────────────────────────
  Future<void> initialize(String? userId) async {
    if (_initialized) return;
    try {
      // ✅ Remote Config se API key lo
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();
      final apiKey = remoteConfig.getString('revenuecat_api_key');

      if (apiKey.isEmpty) {
        debugPrint('RevenueCat API key not found in Remote Config');
        return;
      }

      // ✅ Log level
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.error,
      );

      final config = PurchasesConfiguration(apiKey);
      if (userId != null) config.appUserID = userId;
      await Purchases.configure(config);
      _initialized = true;
      debugPrint('RevenueCat initialized ✅ key: ${apiKey.substring(0, 10)}...');
    } catch (e) {
      debugPrint('RevenueCat init error: $e');
    }
  }

  // ─── Check Pro Status ─────────────────────────
  Future<bool> isPro() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(_entitlementId);
    } catch (e) {
      debugPrint('isPro check error: $e');
      return false;
    }
  }

  // ─── Get Offerings ────────────────────────────
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('getOfferings error: $e');
      return null;
    }
  }

  // ─── Purchase ─────────────────────────────────
  Future<bool> purchase(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro =
          customerInfo.entitlements.active.containsKey(_entitlementId);
      if (isPro) await _updateFirestorePlan('pro');
      return isPro;
    } catch (e) {
      if (e is PurchasesErrorCode &&
          e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled');
        return false;
      }
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  // ─── Restore Purchases ────────────────────────
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro =
          customerInfo.entitlements.active.containsKey(_entitlementId);
      if (isPro) await _updateFirestorePlan('pro');
      return isPro;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  // ─── Firestore Plan Update ────────────────────
  Future<void> _updateFirestorePlan(String plan) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'plan': plan});
      debugPrint('Firestore plan updated → $plan ✅');
    } catch (e) {
      debugPrint('Firestore plan update error: $e');
    }
  }
}
