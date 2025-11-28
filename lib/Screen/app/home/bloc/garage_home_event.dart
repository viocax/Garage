import 'package:equatable/equatable.dart';
import 'package:garage/core/models/tabbar_type.dart';

sealed class GarageHomeEvent extends Equatable {
  const GarageHomeEvent();

  @override
  List<Object?> get props => [];
}

final class TabChanged extends GarageHomeEvent {
  final TabbarType tabbarType;

  const TabChanged(this.tabbarType);

  @override
  List<Object?> get props => [tabbarType];
}
