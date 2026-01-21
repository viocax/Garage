import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdService {
  /// 初始化廣告 SDK
  Future<void> initialize();

  /// 取得各類廣告的 Unit ID
  String get bannerAdUnitId;
  String get interstitialAdUnitId;
  String get rewardedAdUnitId;
  String get nativeAdUnitId;

  /// 顯示插頁式廣告
  Future<void> showInterstitialAd({required VoidCallback onComplete});

  /// 顯示獎勵廣告
  Future<void> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  });
}
