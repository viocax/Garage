import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:garage/core/core.dart';
import 'package:garage/theme/app_theme.dart';

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // 如果是免廣告，則不載入
    if (getIt.repo.ad.isAdFree) return;

    _nativeAd = NativeAd(
      adUnitId: getIt.repo.ad.nativeAdUnitId,
      factoryId: 'listTile', // 需要在原生端註冊
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('NativeAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (getIt.repo.ad.isAdFree) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 72, // 與 RecordItem 高度相近
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.whiteTransparent08, AppTheme.whiteTransparent04],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.whiteTransparent10, width: 1),
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
