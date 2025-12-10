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

final class VehicleKmChanged extends AddVehicleEvent {
  final int km;

  const VehicleKmChanged(this.km);

  @override
  List<Object> get props => [km];
}

final class SubmitVehicle extends AddVehicleEvent {
  const SubmitVehicle();
}

final class LoadUserSettings extends AddVehicleEvent {
  const LoadUserSettings();
}
