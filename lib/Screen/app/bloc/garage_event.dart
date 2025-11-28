import 'package:equatable/equatable.dart';
import 'package:garage/core/models/tabbar_type.dart';

sealed class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

final class TabChanged extends GarageEvent {
  final TabbarType tabbarType;

  const TabChanged(this.tabbarType);

  @override
  List<Object?> get props => [tabbarType];
}
