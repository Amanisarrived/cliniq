import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  static const String _rewardedAdId = 'ca-app-pub-2590111716650280/3616813007';

  static const String _testRewardedAdId =
      'ca-app-pub-3940256099942544/5224354917';

  static String get rewardedAdId =>
      kDebugMode ? _testRewardedAdId : _rewardedAdId;

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isAdReady = false;
  bool get isAdReady => _isAdReady;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized ✅');
    await loadRewardedAd();
  }

  Future<void> loadRewardedAd() async {
    if (_isLoading || _isAdReady) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdReady = true;
          _isLoading = false;
          debugPrint('Rewarded ad loaded ✅');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isAdReady = false;
          _isLoading = false;
          debugPrint('Rewarded ad failed: $error');
        },
      ),
    );
  }

  Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
  }) async {
    if (!_isAdReady || _rewardedAd == null) {
      debugPrint('Ad not ready — loading...');
      await loadRewardedAd();
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isAdReady = false;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isAdReady = false;
        loadRewardedAd();
        debugPrint('Ad show failed: $error');
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
        onRewarded();
        debugPrint('User rewarded ✅');
      },
    );

    return rewarded;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
  }
}
