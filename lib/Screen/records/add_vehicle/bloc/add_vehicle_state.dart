part of 'add_vehicle_bloc.dart';

enum AddVehicleStatus { initial, submitting, success, failure }

class AddVehicleState extends Equatable {
  final String vehicleName;
  final int currentKm;
  final SpeedUnit speedUnit;
  final int maintenanceIntervalKm;
  final AddVehicleStatus status;
  final Vehicle? createdVehicle;
  final String? errorMessage;

  const AddVehicleState({
    this.vehicleName = '',
    this.currentKm = 0,
    required this.speedUnit,
    this.maintenanceIntervalKm = 0,
    this.status = AddVehicleStatus.initial,
    this.createdVehicle,
    this.errorMessage,
  });

  bool get isValid =>
      vehicleName.trim().isNotEmpty &&
      currentKm >= 0;

  @override
  List<Object?> get props => [
    vehicleName,
    currentKm,
    speedUnit,
    maintenanceIntervalKm,
    status,
    createdVehicle,
    errorMessage,
  ];

  AddVehicleState copyWith({
    String? vehicleName,
    int? currentKm,
    SpeedUnit? speedUnit,
    int? maintenanceIntervalKm,
    AddVehicleStatus? status,
    Vehicle? createdVehicle,
    String? errorMessage,
  }) {
    return AddVehicleState(
      vehicleName: vehicleName ?? this.vehicleName,
      currentKm: currentKm ?? this.currentKm,
      speedUnit: speedUnit ?? this.speedUnit,
      maintenanceIntervalKm: maintenanceIntervalKm ?? this.maintenanceIntervalKm,
      status: status ?? this.status,
      createdVehicle: createdVehicle ?? this.createdVehicle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
