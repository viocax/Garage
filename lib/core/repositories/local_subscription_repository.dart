import 'package:purchases_flutter/purchases_flutter.dart';
import '../service/subscription/subscription_service.dart';
import 'subscription_repository.dart';

class LocalSubscriptionRepository extends SubscriptionRepository {
  final SubscriptionService _subscriptionService;

  LocalSubscriptionRepository(this._subscriptionService);

  @override
  Stream<bool> get isProStream => _subscriptionService.proStatusStream;

  @override
  Future<bool> isPro() => _subscriptionService.isPro();

  @override
  Future<List<Offering>> getOfferings() => _subscriptionService.getOfferings();

  @override
  Future<bool> purchasePackage(Package package) =>
      _subscriptionService.purchasePackage(package);

  @override
  Future<void> restorePurchases() => _subscriptionService.restorePurchases();

  @override
  bool get isProCached => _subscriptionService.isProCached;
}
