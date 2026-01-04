import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'bloc/banner_ad/banner_ad_cubit.dart';
import 'bloc/banner_ad/banner_ad_state.dart';

class BannerAdWidget extends StatelessWidget {
  final AdSize adSize;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BannerAdCubit(adSize: adSize)..loadAd(),
      child: BlocBuilder<BannerAdCubit, BannerAdState>(
        builder: (context, state) {
          if (state is BannerAdLoaded) {
            return Container(
              width: adSize.width.toDouble(),
              height: adSize.height.toDouble(),
              alignment: Alignment.center,
              child: AdWidget(ad: state.ad),
            );
          }
          // Initial, Loading, Error, Hidden return empty
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
