import 'package:flutter/widgets.dart';
import 'package:garage/core/config/ad_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class MobileAdService extends AdService {
  MobileAdService();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  @override
  String get bannerAdUnitId => AdConfig.bannerAdUnitId;

  @override
  String get interstitialAdUnitId => AdConfig.interstitialAdUnitId;

  @override
  String get rewardedAdUnitId => AdConfig.rewardedAdUnitId;

  @override
  String get nativeAdUnitId => AdConfig.nativeAdUnitId;

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  /// 重試延遲時間（秒）：2s, 4s, 8s
  static const List<int> _retryDelays = [2, 4, 8];

  void _loadInterstitialAd([int retryCount = 0]) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded successfully');
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _loadInterstitialAd(); // Preload next ad
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('InterstitialAd failed to show: $error');
                  ad.dispose();
                  _loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load (attempt ${retryCount + 1}): $error');
          // 指數退避重試：2s, 4s, 8s
          if (retryCount < _retryDelays.length) {
            final delay = Duration(seconds: _retryDelays[retryCount]);
            debugPrint('Retrying in ${delay.inSeconds}s...');
            Future.delayed(delay, () {
              _loadInterstitialAd(retryCount + 1);
            });
          } else {
            debugPrint('InterstitialAd: Max retry attempts reached');
          }
        },
      ),
    );
  }

  DateTime? _lastInterstitialShowTime;
  static const Duration _interstitialCooldown = Duration(minutes: 5);

  @override
  Future<void> showInterstitialAd({required VoidCallback onComplete}) async {
    // 檢查冷卻時間
    if (_lastInterstitialShowTime != null &&
        DateTime.now().difference(_lastInterstitialShowTime!) <
            _interstitialCooldown) {
      debugPrint('InterstitialAd: Skipping due to cooldown period');
      onComplete();
      return;
    }

    if (_interstitialAd == null) {
      debugPrint('InterstitialAd: Ad not ready, attempting to reload...');
      _loadInterstitialAd();
      onComplete();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd: User dismissed ad');
        ad.dispose();
        _loadInterstitialAd();
        _lastInterstitialShowTime = DateTime.now();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd: Failed to show: $error');
        ad.dispose();
        _loadInterstitialAd();
        onComplete();
      },
    );

    final ad = _interstitialAd;
    if (ad != null) {
      await ad.show();
    }
    _interstitialAd = null;
  }

  void _loadRewardedAd([int retryCount = 0]) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded successfully');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load (attempt ${retryCount + 1}): $error');
          // 指數退避重試：2s, 4s, 8s
          if (retryCount < _retryDelays.length) {
            final delay = Duration(seconds: _retryDelays[retryCount]);
            debugPrint('Retrying in ${delay.inSeconds}s...');
            Future.delayed(delay, () {
              _loadRewardedAd(retryCount + 1);
            });
          } else {
            debugPrint('RewardedAd: Max retry attempts reached');
          }
        },
      ),
    );
  }

  @override
  Future<void> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  }) async {
    if (_rewardedAd == null) {
      debugPrint('RewardedAd: Ad not ready, attempting to reload...');
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardedAd: User dismissed ad');
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd: Failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
      },
    );

    final ad = _rewardedAd;
    if (ad != null) {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('RewardedAd: User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
    }
    _rewardedAd = null;
  }
}
