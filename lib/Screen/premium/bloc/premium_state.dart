import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum PremiumStatus { initial, loading, success, failure, purchasing }

class PremiumState extends Equatable {
  final PremiumStatus status;
  final List<Offering> offerings;
  final bool isPro;
  final String? errorMessage;

  const PremiumState({
    this.status = PremiumStatus.initial,
    this.offerings = const [],
    this.isPro = false,
    this.errorMessage,
  });

  PremiumState copyWith({
    PremiumStatus? status,
    List<Offering>? offerings,
    bool? isPro,
    String? errorMessage,
  }) {
    return PremiumState(
      status: status ?? this.status,
      offerings: offerings ?? this.offerings,
      isPro: isPro ?? this.isPro,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, offerings, isPro, errorMessage];
}
