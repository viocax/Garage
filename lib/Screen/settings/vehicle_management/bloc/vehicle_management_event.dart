import 'package:equatable/equatable.dart';

sealed class VehicleManagementEvent extends Equatable {
  const VehicleManagementEvent();

  @override
  List<Object> get props => [];
}

final class LoadVehicles extends VehicleManagementEvent {
  const LoadVehicles();
}

final class ReorderVehicles extends VehicleManagementEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderVehicles({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object> get props => [oldIndex, newIndex];
}

final class DeleteVehicle extends VehicleManagementEvent {
  final String vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}
