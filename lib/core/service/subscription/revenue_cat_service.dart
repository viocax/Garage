import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'subscription_service.dart';

class RevenueCatService extends SubscriptionService {
  final _proStatusController = StreamController<bool>.broadcast();
  bool _isProCached = false;

  @override
  Stream<bool> get proStatusStream => _proStatusController.stream;

  @override
  bool get isProCached => _isProCached;

  @override
  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      // TODO: Add Android API Key
      configuration = PurchasesConfiguration("goog_placeholder_key");
    } else if (Platform.isIOS) {
      // TODO: Add iOS API Key
      configuration = PurchasesConfiguration("appl_placeholder_key");
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      await _updateProStatus();
    }

    // Listen for purchaser info changes
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateProStatusFromInfo(customerInfo);
    });
  }

  Future<void> _updateProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatusFromInfo(customerInfo);
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
    }
  }

  void _updateProStatusFromInfo(CustomerInfo customerInfo) {
    // We assume the entitlement ID is "pro"
    final isPro = customerInfo.entitlements.active.containsKey("pro");
    _isProCached = isPro;
    _proStatusController.add(isPro);
  }

  @override
  Future<bool> isPro() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey("pro");
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Offering>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return [offerings.current!];
      }
    } catch (e) {
      debugPrint('Error getting offerings: $e');
    }
    return [];
  }

  @override
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      final customerInfo = result.customerInfo;
      final isPro = customerInfo.entitlements.active.containsKey("pro");
      _proStatusController.add(isPro);
      return isPro;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatusFromInfo(customerInfo);
    } catch (e) {
      debugPrint('Restore failed: $e');
    }
  }
}
