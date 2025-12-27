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

final class LicensePlateChanged extends AddVehicleEvent {
  final String licensePlate;

  const LicensePlateChanged(this.licensePlate);

  @override
  List<Object> get props => [licensePlate];
}

final class VehicleKmChanged extends AddVehicleEvent {
  final int km;

  const VehicleKmChanged(this.km);

  @override
  List<Object> get props => [km];
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

final class LoadUserSettings extends AddVehicleEvent {
  const LoadUserSettings();
}
