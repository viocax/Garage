import 'package:flutter/widgets.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/service/ad/ad_service.dart';

class LocalAdRepository implements AdRepository {
  final AdService _adService;
  final UserSettingsRepository _userSettings;

  LocalAdRepository(this._adService, this._userSettings);

  @override
  bool get isAdFree => _userSettings.currentSettings.isAdFree;

  @override
  Future<void> showInterstitialAd({required VoidCallback onComplete}) async {
    // 邏輯封裝在 Repository：如果是免廣告，直接執行回調
    if (isAdFree) {
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
}
