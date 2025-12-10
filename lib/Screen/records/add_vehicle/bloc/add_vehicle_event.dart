part of 'add_vehicle_bloc.dart';

sealed class AddVehicleEvent extends Equatable {
  const AddVehicleEvent();

  @override
  List<Object> get props => [];
}

final class VehicleNameChanged extends AddVehicleEvent {
  final String name;

  const VehicleNameChanged(this.name);

  @override
  List<Object> get props => [name];
}

final class VehicleMileageChanged extends AddVehicleEvent {
  final int mileage;

  const VehicleMileageChanged(this.mileage);

  @override
  List<Object> get props => [mileage];
}

final class MaintenanceIntervalChanged extends AddVehicleEvent {
  final int interval;

  const MaintenanceIntervalChanged(this.interval);

  @override
  List<Object> get props => [interval];
}

final class SubmitVehicle extends AddVehicleEvent {
  const SubmitVehicle();
}
