import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:garage/core/core.dart';
import 'banner_ad_state.dart';

class BannerAdCubit extends Cubit<BannerAdState> {
  final AdRepository _adRepository = getIt.repo.ad;
  final AdSize adSize;

  BannerAdCubit({this.adSize = AdSize.banner}) : super(const BannerAdInitial());

  void loadAd() {
    if (_adRepository.isBannerAdFree) {
      emit(const BannerAdHidden());
      return;
    }

    emit(const BannerAdLoading());

    final bannerAd = BannerAd(
      adUnitId: _adRepository.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (isClosed) {
            ad.dispose();
            return;
          }
          emit(BannerAdLoaded(ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          Log.e('BannerAd failed to load: $error');
          ad.dispose();
          if (!isClosed) {
            emit(BannerAdLoadError(error.message));
          }
        },
      ),
    );

    bannerAd.load();
  }

  @override
  Future<void> close() {
    final state = this.state;
    if (state is BannerAdLoaded) {
      state.ad.dispose();
    }
    return super.close();
  }
}
