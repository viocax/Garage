import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/ad/ad_loader.dart';
import 'package:garage/core/service/ad/mobile_ad_service.dart';
import 'package:garage/core/config/ad_constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Mock AdLoader
class MockAdLoader implements AdLoader {
  int loadInterstitialAdCallCount = 0;
  int loadRewardedAdCallCount = 0;
  int initializeCallCount = 0;

  OnAdLoaded<InterstitialAd>? lastInterstitialOnLoaded;
  OnAdFailedToLoad? lastInterstitialOnFailed;
  OnAdLoaded<RewardedAd>? lastRewardedOnLoaded;
  OnAdFailedToLoad? lastRewardedOnFailed;

  @override
  void loadInterstitialAd({
    required String adUnitId,
    required OnAdLoaded<InterstitialAd> onAdLoaded,
    required OnAdFailedToLoad onAdFailedToLoad,
  }) {
    loadInterstitialAdCallCount++;
    lastInterstitialOnLoaded = onAdLoaded;
    lastInterstitialOnFailed = onAdFailedToLoad;
  }

  @override
  void loadRewardedAd({
    required String adUnitId,
    required OnAdLoaded<RewardedAd> onAdLoaded,
    required OnAdFailedToLoad onAdFailedToLoad,
  }) {
    loadRewardedAdCallCount++;
    lastRewardedOnLoaded = onAdLoaded;
    lastRewardedOnFailed = onAdFailedToLoad;
  }

  @override
  Future<InitializationStatus> initialize() async {
    initializeCallCount++;
    return _MockInitializationStatus();
  }

  @override
  void updateRequestConfiguration(RequestConfiguration configuration) {
    // No-op for testing
  }

  void reset() {
    loadInterstitialAdCallCount = 0;
    loadRewardedAdCallCount = 0;
    initializeCallCount = 0;
    lastInterstitialOnLoaded = null;
    lastInterstitialOnFailed = null;
    lastRewardedOnLoaded = null;
    lastRewardedOnFailed = null;
  }
}

class _MockInitializationStatus implements InitializationStatus {
  @override
  Map<String, AdapterStatus> get adapterStatuses => {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileAdService', () {
    late MockAdLoader mockAdLoader;
    late MobileAdService service;

    setUp(() {
      mockAdLoader = MockAdLoader();
      service = MobileAdService(adLoader: mockAdLoader);
    });

    tearDown(() {
      mockAdLoader.reset();
    });

    group('Ad Unit IDs', () {
      test('bannerAdUnitId should return correct ID', () {
        expect(service.bannerAdUnitId, isNotEmpty);
      });

      test('interstitialAdUnitId should return correct ID', () {
        expect(service.interstitialAdUnitId, isNotEmpty);
      });

      test('rewardedAdUnitId should return correct ID', () {
        expect(service.rewardedAdUnitId, isNotEmpty);
      });

      test('nativeAdUnitId should return correct ID', () {
        expect(service.nativeAdUnitId, isNotEmpty);
      });
    });

    group('initialize', () {
      test('should initialize ads SDK', () async {
        await service.initialize();

        expect(mockAdLoader.initializeCallCount, 1);
      });

      test('should load interstitial and rewarded ads after init', () async {
        await service.initialize();

        expect(mockAdLoader.loadInterstitialAdCallCount, 1);
        expect(mockAdLoader.loadRewardedAdCallCount, 1);
      });
    });

    group('showInterstitialAd', () {
      test('should skip ad during cooldown period', () async {
        // Set last show time to now (within cooldown)
        service.setLastInterstitialShowTime(DateTime.now());

        var completeCalled = false;
        await service.showInterstitialAd(
          onComplete: () => completeCalled = true,
        );

        expect(completeCalled, isTrue);
        // Should not try to reload
        expect(mockAdLoader.loadInterstitialAdCallCount, 0);
      });

      test('should show ad when cooldown expired', () async {
        // Set last show time to past (beyond cooldown)
        service.setLastInterstitialShowTime(
          DateTime.now().subtract(
            AdConstants.interstitialCooldown + const Duration(seconds: 1),
          ),
        );

        var completeCalled = false;
        await service.showInterstitialAd(
          onComplete: () => completeCalled = true,
        );

        // Ad is null, should trigger reload and complete
        expect(completeCalled, isTrue);
        expect(mockAdLoader.loadInterstitialAdCallCount, 1);
      });

      test('should trigger reload when ad not ready', () async {
        var completeCalled = false;
        await service.showInterstitialAd(
          onComplete: () => completeCalled = true,
        );

        expect(completeCalled, isTrue);
        expect(mockAdLoader.loadInterstitialAdCallCount, 1);
      });
    });

    group('showRewardedAd', () {
      test('should trigger reload when ad not ready', () async {
        await service.showRewardedAd(onUserEarnedReward: (_) {});

        expect(mockAdLoader.loadRewardedAdCallCount, 1);
      });
    });

    group('Cooldown Logic', () {
      test('cooldown should be 5 minutes', () {
        expect(AdConstants.interstitialCooldown, const Duration(minutes: 5));
      });

      test('should skip multiple ads during cooldown', () async {
        service.setLastInterstitialShowTime(DateTime.now());

        var callCount = 0;
        for (var i = 0; i < 3; i++) {
          await service.showInterstitialAd(onComplete: () => callCount++);
        }

        expect(callCount, 3); // All should complete immediately
        expect(
          mockAdLoader.loadInterstitialAdCallCount,
          0,
        ); // None should reload
      });
    });
  });
}
