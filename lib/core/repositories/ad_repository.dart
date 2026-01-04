import 'package:flutter/widgets.dart';

abstract class AdRepository {
  /// 是否為免廣告狀態 (VIP)
  bool get isAdFree;

  /// 橫幅廣告是否免除 (VIP 或 獎勵期間)
  bool get isBannerAdFree;

  /// 廣告票券數量
  int get adTicketCount;

  /// 顯示插頁式廣告
  Future<void> showInterstitialAd({required VoidCallback onComplete});

  /// 載入原生廣告
  Future<void> loadNativeAd();

  /// 取得原生廣告 ID
  String get nativeAdUnitId;

  /// 取得橫幅廣告 ID
  String get bannerAdUnitId;

  /// 消耗一張廣告票券
  Future<void> consumeAdTicket();

  /// 給予廣告票券
  Future<void> grantAdTicket(int amount);

  /// 給予橫幅廣告免除時間
  Future<void> grantBannerAdFree(Duration duration);

  /// 顯示獎勵廣告
  Future<void> showRewardedAd({required VoidCallback onReward});
}
