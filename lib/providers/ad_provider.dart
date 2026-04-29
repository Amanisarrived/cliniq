import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import '../services/firestore_service.dart';

enum AdStatus { idle, loading, success, error }

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService.instance;
  final FirestoreService _firestoreService;

  AdStatus _status = AdStatus.idle;
  String? _error;
  int _adsWatchedToday = 0;

  static const int maxAdsPerDay = 2;

  AdProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  AdStatus get status => _status;
  String? get error => _error;
  int get adsWatchedToday => _adsWatchedToday;
  bool get isLoading => _status == AdStatus.loading;
  bool get canWatchAd => _adsWatchedToday < maxAdsPerDay;
  bool get isAdReady => _adService.isAdReady;

  // ─── Load Ads Watched Today ───────────────────
  void setAdsWatchedToday(int count) {
    _adsWatchedToday = count;
    notifyListeners();
  }

  // ─── Show Rewarded Ad ─────────────────────────
  Future<bool> showRewardedAd(String uid) async {
    if (!canWatchAd) {
      _setError('Aaj ke liye maximum ads dekh liye!');
      return false;
    }

    if (!_adService.isAdReady) {
      _setError('Ad load nahi hua. Thoda wait karo.');
      await _adService.loadRewardedAd();
      return false;
    }

    _setStatus(AdStatus.loading);

    bool rewarded = false;

    await _adService.showRewardedAd(
      onRewarded: () {
        rewarded = true;
      },
    );

    if (rewarded) {
      // ✅ Firestore mein credits update karo
      await _firestoreService.rewardAdCredits(uid);
      _adsWatchedToday++;
      _setStatus(AdStatus.success);
    } else {
      _setStatus(AdStatus.idle);
    }

    return rewarded;
  }

  void _setStatus(AdStatus s) {
    _status = s;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AdStatus.error;
    _error = msg;
    notifyListeners();
  }

  void clearStatus() {
    _status = AdStatus.idle;
    _error = null;
    notifyListeners();
  }
}
