import 'package:equatable/equatable.dart';
import 'package:garage/core/models/tabbar_type.dart';

sealed class GarageHomeState extends Equatable {
  final TabbarType tabbarType;

  const GarageHomeState({required this.tabbarType});

  @override
  List<Object?> get props => [tabbarType];
}

class GarageHomeInitialState extends GarageHomeState {
  const GarageHomeInitialState() : super(tabbarType: const SpeedCameraTab());
}

class GarageHomeTabChanged extends GarageHomeState {
  const GarageHomeTabChanged(TabbarType tabbarType)
    : super(tabbarType: tabbarType);
}
