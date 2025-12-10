part of 'records_bloc.dart';

sealed class RecordsState extends Equatable {
  const RecordsState();

  @override
  List<Object> get props => [];
}

class RecordsLoading extends RecordsState {}

class RecordsEmpty extends RecordsState {}


class RecordsLoaded extends RecordsState {
  final List<Vehicle> vehicles;
  final String currentVehicleId;

  RecordsLoaded({required this.vehicles, required this.currentVehicleId})
    : assert(vehicles.isNotEmpty, 'vehicles list cannot be empty'),
      assert(
        vehicles.any((v) => v.vehicleId == currentVehicleId),
        'currentVehicleId must exist in vehicles list',
      );

  // Helper to get the current vehicle
  // Safe to use firstWhere because we validate in constructor
  Vehicle get currentVehicle =>
      vehicles.firstWhere((v) => v.vehicleId == currentVehicleId);

  @override
  List<Object> get props => [vehicles, currentVehicleId];

  RecordsLoaded copyWith({List<Vehicle>? vehicles, String? currentVehicleId}) {
    return RecordsLoaded(
      vehicles: vehicles ?? this.vehicles,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
    );
  }
}

class RecordsError extends RecordsState {
  final String message;

  const RecordsError(this.message);

  @override
  List<Object> get props => [message];
}
