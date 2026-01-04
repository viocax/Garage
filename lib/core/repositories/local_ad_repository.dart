import 'package:flutter/widgets.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/subscription_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/service/ad/ad_service.dart';

class LocalAdRepository implements AdRepository {
  final AdService _adService;
  final UserSettingsRepository _userSettings;
  final SubscriptionRepository _subscriptionRepository;

  LocalAdRepository(
    this._adService,
    this._userSettings,
    this._subscriptionRepository,
  );

  @override
  bool get isAdFree =>
      _userSettings.currentSettings.isAdFree ||
      _subscriptionRepository.isProCached;

  @override
  bool get isBannerAdFree {
    if (isAdFree) return true;
    final expiry = _userSettings.currentSettings.bannerAdFreeUntil;
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  @override
  int get adTicketCount => _userSettings.currentSettings.adTicketCount;

  @override
  Future<void> showInterstitialAd({required VoidCallback onComplete}) async {
    // 邏輯封裝在 Repository：如果是免廣告，直接執行回調
    if (isAdFree) {
      onComplete();
      return;
    }

    // 檢查是否有廣告票券
    if (adTicketCount > 0) {
      await consumeAdTicket();
      debugPrint('Used 1 Ad Ticket. Remaining: $adTicketCount');
      onComplete();
      return;
    }

    await _adService.showInterstitialAd(onComplete: onComplete);
  }

  @override
  Future<void> loadNativeAd() async {
    if (isAdFree) return;
    await _adService.loadNativeAd();
  }

  @override
  String get nativeAdUnitId => _adService.nativeAdUnitId;

  @override
  String get bannerAdUnitId => _adService.bannerAdUnitId;

  @override
  Future<void> consumeAdTicket() async {
    final current = adTicketCount;
    if (current > 0) {
      final settings = _userSettings.currentSettings.copyWith(
        adTicketCount: current - 1,
      );
      await _userSettings.saveSettings(settings);
    }
  }

  @override
  Future<void> grantAdTicket(int amount) async {
    final current = adTicketCount;
    final settings = _userSettings.currentSettings.copyWith(
      adTicketCount: current + amount,
    );
    await _userSettings.saveSettings(settings);
  }

  @override
  Future<void> grantBannerAdFree(Duration duration) async {
    final now = DateTime.now();
    // 如果原本還有剩餘時間，則從剩餘時間繼續疊加? 或者直接從現在開始加?
    // 簡單起見：如果還在有效期內，則展延。如果過期，則從現在開始算。
    final currentExpiry = _userSettings.currentSettings.bannerAdFreeUntil;
    final baseTime = (currentExpiry != null && currentExpiry.isAfter(now))
        ? currentExpiry
        : now;

    final newExpiry = baseTime.add(duration);
    final settings = _userSettings.currentSettings.copyWith(
      bannerAdFreeUntil: newExpiry,
    );
    await _userSettings.saveSettings(settings);
  }

  @override
  Future<void> showRewardedAd({required VoidCallback onReward}) async {
    await _adService.showRewardedAd(
      onUserEarnedReward: (reward) {
        onReward();
      },
    );
  }
}
