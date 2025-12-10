part of 'add_vehicle_bloc.dart';

enum AddVehicleStatus {
  initial,
  submitting,
  success,
  failure,
}

class AddVehicleState extends Equatable {
  final String vehicleName;
  final int currentMileage;
  final int maintenanceInterval;
  final AddVehicleStatus status;
  final Vehicle? createdVehicle;
  final String? errorMessage;

  const AddVehicleState({
    this.vehicleName = '',
    this.currentMileage = 0,
    this.maintenanceInterval = 5000,
    this.status = AddVehicleStatus.initial,
    this.createdVehicle,
    this.errorMessage,
  });

  bool get isValid =>
      vehicleName.trim().isNotEmpty &&
      currentMileage >= 0 &&
      maintenanceInterval > 0;

  @override
  List<Object?> get props => [
        vehicleName,
        currentMileage,
        maintenanceInterval,
        status,
        createdVehicle,
        errorMessage,
      ];

  AddVehicleState copyWith({
    String? vehicleName,
    int? currentMileage,
    int? maintenanceInterval,
    AddVehicleStatus? status,
    Vehicle? createdVehicle,
    String? errorMessage,
  }) {
    return AddVehicleState(
      vehicleName: vehicleName ?? this.vehicleName,
      currentMileage: currentMileage ?? this.currentMileage,
      maintenanceInterval: maintenanceInterval ?? this.maintenanceInterval,
      status: status ?? this.status,
      createdVehicle: createdVehicle ?? this.createdVehicle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
