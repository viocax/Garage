part of 'records_bloc.dart';

sealed class RecordsEvent extends Equatable {
  const RecordsEvent();

  @override
  List<Object> get props => [];
}

final class LoadVehicleRecord extends RecordsEvent {
  final String? vehicleId;
  const LoadVehicleRecord({this.vehicleId});
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

final class AddRecord extends RecordsEvent {
  final VehicleRecord? record;
  const AddRecord(this.record);
}
