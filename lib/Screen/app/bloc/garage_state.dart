import 'package:equatable/equatable.dart';
import 'package:garage/core/models/tabbar_type.dart';

sealed class GarageState extends Equatable {
  final TabbarType tabbarType;

  const GarageState({required this.tabbarType});

  @override
  List<Object?> get props => [tabbarType];
}

class GarageInitialState extends GarageState {
  const GarageInitialState() : super(tabbarType: const SpeedCameraTab());
}

class GarageTabChanged extends GarageState {
  const GarageTabChanged(TabbarType tabbarType) : super(tabbarType: tabbarType);
}
