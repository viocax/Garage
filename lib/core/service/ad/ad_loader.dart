import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Callback for when an ad is successfully loaded.
typedef OnAdLoaded<T> = void Function(T ad);

/// Callback for when ad loading fails.
typedef OnAdFailedToLoad = void Function(LoadAdError error);

/// Interface for ad loading operations, allowing injection for testing.
abstract class AdLoader {
  /// Load an interstitial ad.
  void loadInterstitialAd({
    required String adUnitId,
    required OnAdLoaded<InterstitialAd> onAdLoaded,
    required OnAdFailedToLoad onAdFailedToLoad,
  });

  /// Load a rewarded ad.
  void loadRewardedAd({
    required String adUnitId,
    required OnAdLoaded<RewardedAd> onAdLoaded,
    required OnAdFailedToLoad onAdFailedToLoad,
  });

  /// Initialize the Mobile Ads SDK.
  Future<InitializationStatus> initialize();

  /// Update request configuration for test devices.
  void updateRequestConfiguration(RequestConfiguration configuration);
}

/// Default implementation using actual google_mobile_ads SDK.
class DefaultAdLoader implements AdLoader {
  const DefaultAdLoader();

  @override
  void loadInterstitialAd({
    required String adUnitId,
    required OnAdLoaded<InterstitialAd> onAdLoaded,
    required OnAdFailedToLoad onAdFailedToLoad,
  }) {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  @override
  void loadRewardedAd({
    required String adUnitId,
    required OnAdLoaded<RewardedAd> onAdLoaded,
    required OnAdFailedToLoad onAdFailedToLoad,
  }) {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  @override
  Future<InitializationStatus> initialize() {
    return MobileAds.instance.initialize();
  }

  @override
  void updateRequestConfiguration(RequestConfiguration configuration) {
    MobileAds.instance.updateRequestConfiguration(configuration);
  }
}
