import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:garage/core/config/ad_config.dart';
import 'package:garage/core/config/ad_constants.dart';
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
    // 配置測試設備（僅在開發階段）
    if (!kReleaseMode) {
      // 🔍 如何獲取設備 ID：
      // 1. 運行應用並觸發任何廣告
      // 2. 查看 Console/Logcat 輸出
      // 3. 找到類似這樣的訊息：
      //    "To get test ads on this device, set: GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"33BE2250B43518CCDA7DE426D04EE231" ];"
      // 4. 將設備 ID 添加到下面的列表中

      final List<String> testDeviceIds = [
        // 'YOUR_ANDROID_DEVICE_ID',  // 例如: '33BE2250B43518CCDA7DE426D04EE231'
        // 'YOUR_IOS_DEVICE_ID',      // 例如: 'F5C84E9E-5F3A-4B5D-9D8A-8F9E3D2C1B0A'
      ];

      if (testDeviceIds.isNotEmpty) {
        final configuration = RequestConfiguration(
          testDeviceIds: testDeviceIds,
        );
        MobileAds.instance.updateRequestConfiguration(configuration);
        debugPrint('✅ AdMob 測試設備已配置: $testDeviceIds');
      } else {
        debugPrint('⚠️ 尚未配置測試設備 ID，廣告將使用正式模式（請小心不要點擊！）');
      }
    }

    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

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
          // 指數退避重試
          if (retryCount < AdConstants.interstitialRetryDelays.length) {
            final delay = AdConstants.interstitialRetryDelays[retryCount];
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

  @override
  Future<void> showInterstitialAd({required VoidCallback onComplete}) async {
    // 檢查冷卻時間
    if (_lastInterstitialShowTime != null &&
        DateTime.now().difference(_lastInterstitialShowTime!) <
            AdConstants.interstitialCooldown) {
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
          // 指數退避重試
          if (retryCount < AdConstants.interstitialRetryDelays.length) {
            final delay = AdConstants.interstitialRetryDelays[retryCount];
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
