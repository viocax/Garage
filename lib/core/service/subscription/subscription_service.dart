import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionService {
  Future<void> initialize();
  Future<bool> isPro();
  Future<List<Offering>> getOfferings();
  Future<bool> purchasePackage(Package package);
  Future<void> restorePurchases();
  Stream<bool> get proStatusStream;
}
