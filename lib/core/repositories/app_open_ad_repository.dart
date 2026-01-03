import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdRepository {
  final UserSettingsRepository _userSettingsRepository;

  AppOpenAdRepository(this._userSettingsRepository);

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;

  /// 廣告快取時效 (4小時)
  static const Duration maxCacheDuration = Duration(hours: 4);

  /// 廣告測試 ID
  String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/3419835294';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5662855259';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 載入廣告
  void loadAd() {
    if (_userSettingsRepository.currentSettings.isAdFree) return;

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd loaded');
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
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
    return DateTime.now().difference(_appOpenLoadTime!) < maxCacheDuration;
  }

  /// 顯示廣告
  void showAdIfAvailable() {
    if (_userSettingsRepository.currentSettings.isAdFree) return;

    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAd();
      return;
    }

    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
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

    _appOpenAd!.show();
  }
}
