import 'package:equatable/equatable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

sealed class BannerAdState extends Equatable {
  const BannerAdState();

  @override
  List<Object?> get props => [];
}

final class BannerAdInitial extends BannerAdState {
  const BannerAdInitial();
}

final class BannerAdHidden extends BannerAdState {
  const BannerAdHidden();
}

final class BannerAdLoading extends BannerAdState {
  const BannerAdLoading();
}

final class BannerAdLoaded extends BannerAdState {
  final BannerAd ad;

  const BannerAdLoaded(this.ad);

  @override
  List<Object?> get props => [ad];
}

final class BannerAdLoadError extends BannerAdState {
  final String message;

  const BannerAdLoadError(this.message);

  @override
  List<Object?> get props => [message];
}
