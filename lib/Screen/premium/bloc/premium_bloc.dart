import 'package:bloc/bloc.dart';
import 'package:garage/core/repositories/repositories.dart';
import 'premium_event.dart';
import 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final SubscriptionRepository _subscriptionRepository;

  PremiumBloc({required SubscriptionRepository subscriptionRepository})
    : _subscriptionRepository = subscriptionRepository,
      super(const PremiumState()) {
    on<LoadPremiumOfferings>(_onLoadOfferings);
    on<PurchasePackage>(_onPurchasePackage);
    on<RestorePurchases>(_onRestorePurchases);

    add(LoadPremiumOfferings());
  }

  Future<void> _onLoadOfferings(
    LoadPremiumOfferings event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(status: PremiumStatus.loading));
    try {
      final isPro = await _subscriptionRepository.isPro();
      final offerings = await _subscriptionRepository.getOfferings();
      emit(
        state.copyWith(
          status: PremiumStatus.success,
          offerings: offerings,
          isPro: isPro,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PremiumStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPurchasePackage(
    PurchasePackage event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(status: PremiumStatus.purchasing));
    try {
      final success = await _subscriptionRepository.purchasePackage(
        event.package,
      );
      if (success) {
        emit(state.copyWith(status: PremiumStatus.success, isPro: true));
      } else {
        emit(
          state.copyWith(
            status: PremiumStatus.failure,
            errorMessage: "購買失敗，請稍後再試",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PremiumStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(status: PremiumStatus.purchasing));
    try {
      await _subscriptionRepository.restorePurchases();
      final isPro = await _subscriptionRepository.isPro();
      emit(state.copyWith(status: PremiumStatus.success, isPro: isPro));
    } catch (e) {
      emit(
        state.copyWith(
          status: PremiumStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
