part of 'records_bloc.dart';

sealed class RecordsState extends Equatable {
  const RecordsState();

  @override
  List<Object> get props => [];
}

class RecordsLoading extends RecordsState {}

class RecordsEmpty extends RecordsState {
  final UserSettings userSettings;

  const RecordsEmpty({required this.userSettings});

  @override
  List<Object> get props => [userSettings];
}


class RecordsLoaded extends RecordsState {
  final List<Vehicle> vehicles;
  final String currentVehicleId;
  final UserSettings userSettings;

  RecordsLoaded({
    required this.vehicles,
    required this.currentVehicleId,
    required this.userSettings,
  })  : assert(vehicles.isNotEmpty, 'vehicles list cannot be empty'),
        assert(
          vehicles.any((v) => v.vehicleId == currentVehicleId),
          'currentVehicleId must exist in vehicles list',
        );

  // Helper to get the current vehicle
  // Safe to use firstWhere because we validate in constructor
  Vehicle get currentVehicle =>
      vehicles.firstWhere((v) => v.vehicleId == currentVehicleId);

  @override
  List<Object> get props => [vehicles, currentVehicleId, userSettings];

  RecordsLoaded copyWith({
    List<Vehicle>? vehicles,
    String? currentVehicleId,
    UserSettings? userSettings,
  }) {
    return RecordsLoaded(
      vehicles: vehicles ?? this.vehicles,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      userSettings: userSettings ?? this.userSettings,
    );
  }
}

class RecordsError extends RecordsState {
  final String message;

  const RecordsError(this.message);

  @override
  List<Object> get props => [message];
}
