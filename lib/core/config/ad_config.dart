import 'dart:io';
import 'package:flutter/foundation.dart';

/// 廣告配置管理
///
/// 集中管理所有廣告單元 ID，支援測試/生產環境切換
class AdConfig {
  AdConfig._(); // 私有建構子，防止實例化

  static bool get _isTestMode => !kReleaseMode;

  /// 測試環境廣告 ID (Google AdMob 測試 ID)
  static const _testIds = {
    'banner_android': 'ca-app-pub-3940256099942544/6300978111',
    'banner_ios': 'ca-app-pub-3940256099942544/2934735716',
    'interstitial_android': 'ca-app-pub-3940256099942544/1033173712',
    'interstitial_ios': 'ca-app-pub-3940256099942544/4411468910',
    'rewarded_android': 'ca-app-pub-3940256099942544/5224354917',
    'rewarded_ios': 'ca-app-pub-3940256099942544/1712485313',
    'native_android': 'ca-app-pub-3940256099942544/2247696110',
    'native_ios': 'ca-app-pub-3940256099942544/3986624511',
    'app_open_android': 'ca-app-pub-3940256099942544/3419835294',
    'app_open_ios': 'ca-app-pub-3940256099942544/5662855259',
  };

  /// 生產環境廣告 ID
  static const _prodIds = {
    'banner_android': 'ca-app-pub-8569390201968394/5200817139',
    'banner_ios': 'ca-app-pub-8569390201968394/5416261945',
    'interstitial_android': 'ca-app-pub-8569390201968394/9411347278',
    'interstitial_ios': 'ca-app-pub-8569390201968394/4987202322',
    'rewarded_android': 'ca-app-pub-8569390201968394/6785183937',
    'rewarded_ios': 'ca-app-pub-8569390201968394/3751826485',
    'native_android': 'ca-app-pub-8569390201968394/6112581733',
    'native_ios': 'ca-app-pub-8569390201968394/6432145933',
    'app_open_android': 'ca-app-pub-8569390201968394/1457013246',
    'app_open_ios': 'ca-app-pub-8569390201968394/1477016930',
  };

  /// 根據廣告類型和平台獲取對應的廣告 ID
  static String _getAdId(String adType) {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final key = '${adType}_$platform';
    final ids = _isTestMode ? _testIds : _prodIds;

    final adId = ids[key];
    if (adId == null) {
      throw UnsupportedError(
        'Unsupported platform or ad type: $adType on $platform',
      );
    }
    return adId;
  }

  /// 橫幅廣告單元 ID
  static String get bannerAdUnitId => _getAdId('banner');

  /// 插頁式廣告單元 ID
  static String get interstitialAdUnitId => _getAdId('interstitial');

  /// 獎勵廣告單元 ID
  static String get rewardedAdUnitId => _getAdId('rewarded');

  /// 原生廣告單元 ID
  static String get nativeAdUnitId => _getAdId('native');

  /// App Open 廣告單元 ID
  static String get appOpenAdUnitId => _getAdId('app_open');
}
