part of 'records_bloc.dart';

sealed class RecordsEvent extends Equatable {
  const RecordsEvent();

  @override
  List<Object> get props => [];
}

final class LoadVehicleRecord extends RecordsEvent {
  const LoadVehicleRecord();
}

final class SwitchVehicle extends RecordsEvent {
  final String vehicleId;

  const SwitchVehicle(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}

final class ClickAddButton extends RecordsEvent {
  const ClickAddButton();
}

final class AddVehicleRecord extends RecordsEvent {
  final VehicleRecord record;

  const AddVehicleRecord(this.record);

  @override
  List<Object> get props => [record];
}
