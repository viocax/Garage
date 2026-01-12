import 'package:flutter/widgets.dart';
import 'package:garage/core/config/ad_config.dart';
import 'package:garage/core/config/ad_constants.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/utils/log.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdRepository {
  final UserSettingsRepository _userSettingsRepository;

  AppOpenAdRepository(this._userSettingsRepository);

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;

  /// 廣告 ID
  String get _adUnitId => AdConfig.appOpenAdUnitId;

  /// 載入廣告
  void loadAd() {
    if (_userSettingsRepository.currentSettings.isAdFree) return;

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Log.d('AppOpenAd loaded');
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          Log.e('AppOpenAd failed to load: $error', error);
        },
      ),
    );
  }

  /// 檢查廣告是否可用
  bool get isAdAvailable {
    return _appOpenAd != null && _isAdValid;
  }

  /// 檢查廣告是否過期
  bool get _isAdValid {
    if (_appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!) <
        AdConstants.appOpenCacheDuration;
  }

  /// 顯示廣告
  void showAdIfAvailable() {
    if (_userSettingsRepository.currentSettings.isAdFree) return;

    if (!isAdAvailable) {
      Log.d('Tried to show ad before available.');
      loadAd();
      return;
    }

    if (_isShowingAd) {
      Log.d('Tried to show ad while already showing an ad.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // 預載下一個
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    final ad = _appOpenAd;
    if (ad != null) {
      ad.show();
    }
  }
}
