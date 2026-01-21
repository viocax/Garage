part of 'add_vehicle_bloc.dart';

enum AddVehicleStatus { initial, submitting, success, failure }

class AddVehicleState extends Equatable {
  final String vehicleName;
  final String licensePlate;
  final int currentKm;
  final SpeedUnit speedUnit;
  final int maintenanceIntervalKm;
  final AddVehicleStatus status;
  final Vehicle? createdVehicle;
  final String? errorMessage;
  final Vehicle? editingVehicle;

  const AddVehicleState({
    this.vehicleName = '',
    this.licensePlate = '',
    this.currentKm = 0,
    required this.speedUnit,
    this.maintenanceIntervalKm = 0,
    this.status = AddVehicleStatus.initial,
    this.createdVehicle,
    this.errorMessage,
    this.editingVehicle,
  });

  bool get isValid =>
      vehicleName.trim().isNotEmpty &&
      licensePlate.trim().isNotEmpty &&
      currentKm >= 0;

  bool get isEditing => editingVehicle != null;

  @override
  List<Object?> get props => [
    vehicleName,
    licensePlate,
    currentKm,
    speedUnit,
    maintenanceIntervalKm,
    status,
    createdVehicle,
    errorMessage,
    editingVehicle,
  ];

  AddVehicleState copyWith({
    String? vehicleName,
    String? licensePlate,
    int? currentKm,
    SpeedUnit? speedUnit,
    int? maintenanceIntervalKm,
    AddVehicleStatus? status,
    Vehicle? createdVehicle,
    String? errorMessage,
    Vehicle? editingVehicle,
    bool clearError = false,
    bool clearCreatedVehicle = false,
  }) {
    return AddVehicleState(
      vehicleName: vehicleName ?? this.vehicleName,
      licensePlate: licensePlate ?? this.licensePlate,
      currentKm: currentKm ?? this.currentKm,
      speedUnit: speedUnit ?? this.speedUnit,
      maintenanceIntervalKm:
          maintenanceIntervalKm ?? this.maintenanceIntervalKm,
      status: status ?? this.status,
      createdVehicle:
          clearCreatedVehicle ? null : (createdVehicle ?? this.createdVehicle),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      editingVehicle: editingVehicle ?? this.editingVehicle,
    );
  }
}
