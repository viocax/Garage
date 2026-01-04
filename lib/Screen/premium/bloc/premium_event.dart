import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object?> get props => [];
}

class LoadPremiumOfferings extends PremiumEvent {}

class PurchasePackage extends PremiumEvent {
  final Package package;
  const PurchasePackage(this.package);

  @override
  List<Object?> get props => [package];
}

class RestorePurchases extends PremiumEvent {}
