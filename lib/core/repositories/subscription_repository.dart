import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionRepository {
  Stream<bool> get isProStream;
  Future<bool> isPro();
  Future<List<Offering>> getOfferings();
  Future<bool> purchasePackage(Package package);
  Future<void> restorePurchases();
}
