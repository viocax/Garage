import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:garage/core/core.dart';
import 'banner_ad_state.dart';

typedef BannerAdFactory =
    BannerAd Function({
      required String adUnitId,
      required AdSize size,
      required AdRequest request,
      required BannerAdListener listener,
    });

class BannerAdCubit extends Cubit<BannerAdState> {
  final AdRepository _adRepository;
  final AdSize adSize;
  final BannerAdFactory _bannerAdFactory;

  BannerAdCubit({
    this.adSize = AdSize.banner,
    AdRepository? adRepository,
    BannerAdFactory? bannerAdFactory,
  }) : _adRepository = adRepository ?? getIt.repo.ad,
       _bannerAdFactory =
           bannerAdFactory ??
           (({
             required String adUnitId,
             required AdSize size,
             required AdRequest request,
             required BannerAdListener listener,
           }) => BannerAd(
             adUnitId: adUnitId,
             size: size,
             request: request,
             listener: listener,
           )),
       super(const BannerAdInitial());

  void loadAd() {
    if (_adRepository.isBannerAdFree) {
      emit(const BannerAdHidden());
      return;
    }

    emit(const BannerAdLoading());

    final bannerAd = _bannerAdFactory(
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
