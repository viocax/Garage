import 'package:flutter/widgets.dart';

abstract class AdRepository {
  /// 是否為免廣告狀態
  bool get isAdFree;

  /// 顯示插頁式廣告
  Future<void> showInterstitialAd({required VoidCallback onComplete});

  /// 載入原生廣告
  Future<void> loadNativeAd();

  /// 取得原生廣告 ID
  String get nativeAdUnitId;
}
