import 'package:flutter/foundation.dart';
import 'package:garage/core/config/ad_config.dart';
import 'package:garage/core/config/ad_constants.dart';
import 'package:garage/core/utils/log.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_loader.dart';
import 'ad_service.dart';

class MobileAdService extends AdService {
  final AdLoader _adLoader;

  /// Creates a MobileAdService with optional dependency injection.
  ///
  /// For production, use the default constructor without parameters.
  /// For testing, inject a mock AdLoader.
  MobileAdService({AdLoader? adLoader})
    : _adLoader = adLoader ?? const DefaultAdLoader();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  DateTime? _lastInterstitialShowTime;

  /// For testing: set the last interstitial show time.
  @visibleForTesting
  void setLastInterstitialShowTime(DateTime? time) {
    _lastInterstitialShowTime = time;
  }

  /// For testing: get the current interstitial ad.
  @visibleForTesting
  InterstitialAd? get interstitialAdForTesting => _interstitialAd;

  /// For testing: set the interstitial ad directly.
  @visibleForTesting
  void setInterstitialAdForTesting(InterstitialAd? ad) {
    _interstitialAd = ad;
  }

  /// For testing: set the rewarded ad directly.
  @visibleForTesting
  void setRewardedAdForTesting(RewardedAd? ad) {
    _rewardedAd = ad;
  }

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
    // 配置測試設備（僅在開發階段）
    if (!kReleaseMode) {
      final List<String> testDeviceIds = [
        // 'YOUR_ANDROID_DEVICE_ID',
        // 'YOUR_IOS_DEVICE_ID',
      ];

      if (testDeviceIds.isNotEmpty) {
        final configuration = RequestConfiguration(
          testDeviceIds: testDeviceIds,
        );
        _adLoader.updateRequestConfiguration(configuration);
        Log.i('✅ AdMob 測試設備已配置: $testDeviceIds');
      } else {
        Log.d('⚠️ 尚未配置測試設備 ID，廣告將使用正式模式（請小心不要點擊！）');
      }
    }

    await _adLoader.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadInterstitialAd([int retryCount = 0]) {
    _adLoader.loadInterstitialAd(
      adUnitId: interstitialAdUnitId,
      onAdLoaded: (ad) {
        Log.d('InterstitialAd loaded successfully');
        _interstitialAd = ad;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadInterstitialAd(); // Preload next ad
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            Log.e('InterstitialAd failed to show: $error', error);
            ad.dispose();
            _loadInterstitialAd();
          },
        );
      },
      onAdFailedToLoad: (error) {
        Log.e(
          'InterstitialAd failed to load (attempt ${retryCount + 1}): $error',
          error,
        );
        // 指數退避重試
        if (retryCount < AdConstants.interstitialRetryDelays.length) {
          final delay = AdConstants.interstitialRetryDelays[retryCount];
          Log.d('Retrying in ${delay.inSeconds}s...');
          Future.delayed(delay, () {
            _loadInterstitialAd(retryCount + 1);
          });
        } else {
          Log.e('InterstitialAd: Max retry attempts reached');
        }
      },
    );
  }

  @override
  Future<void> showInterstitialAd({required VoidCallback onComplete}) async {
    // 檢查冷卻時間
    if (_lastInterstitialShowTime != null &&
        DateTime.now().difference(_lastInterstitialShowTime!) <
            AdConstants.interstitialCooldown) {
      Log.d('InterstitialAd: Skipping due to cooldown period');
      onComplete();
      return;
    }

    if (_interstitialAd == null) {
      Log.d('InterstitialAd: Ad not ready, attempting to reload...');
      _loadInterstitialAd();
      onComplete();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        Log.d('InterstitialAd: User dismissed ad');
        ad.dispose();
        _loadInterstitialAd();
        _lastInterstitialShowTime = DateTime.now();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.e('InterstitialAd: Failed to show: $error', error);
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
    _adLoader.loadRewardedAd(
      adUnitId: rewardedAdUnitId,
      onAdLoaded: (ad) {
        Log.d('RewardedAd loaded successfully');
        _rewardedAd = ad;
      },
      onAdFailedToLoad: (error) {
        Log.e(
          'RewardedAd failed to load (attempt ${retryCount + 1}): $error',
          error,
        );
        // 指數退避重試
        if (retryCount < AdConstants.interstitialRetryDelays.length) {
          final delay = AdConstants.interstitialRetryDelays[retryCount];
          Log.d('Retrying in ${delay.inSeconds}s...');
          Future.delayed(delay, () {
            _loadRewardedAd(retryCount + 1);
          });
        } else {
          Log.e('RewardedAd: Max retry attempts reached');
        }
      },
    );
  }

  @override
  Future<void> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  }) async {
    if (_rewardedAd == null) {
      Log.d('RewardedAd: Ad not ready, attempting to reload...');
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        Log.d('RewardedAd: User dismissed ad');
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.e('RewardedAd: Failed to show: $error', error);
        ad.dispose();
        _loadRewardedAd();
      },
    );

    final ad = _rewardedAd;
    if (ad != null) {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          Log.d(
            'RewardedAd: User earned reward: ${reward.amount} ${reward.type}',
          );
          onUserEarnedReward(reward);
        },
      );
    }
    _rewardedAd = null;
  }
}
