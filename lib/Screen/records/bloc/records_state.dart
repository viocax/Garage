part of 'records_bloc.dart';

enum RecordsSideEffect {
  navigateToAddVehicle,
  navigateToAddRecord,
}

class RecordsState extends Equatable {
  final List<Vehicle> vehicles;
  final String currentVehicleId;
  final UserSettings? userSettings;
  final String odometerString;
  final String unitString;
  final bool isLoading;
  final String? errorMessage;
  final RecordsSideEffect? sideEffect;

  const RecordsState({
    this.vehicles = const [],
    this.currentVehicleId = '',
    this.userSettings,
    this.odometerString = '0',
    this.unitString = 'km',
    this.isLoading = false,
    this.errorMessage,
    this.sideEffect,
  });

  bool get isEmpty => vehicles.isEmpty;

  // Helper to get the current vehicle
  Vehicle get currentVehicle =>
      vehicles.firstWhere(
        (v) => v.vehicleId == currentVehicleId,
        orElse: () => Vehicle.empty(),
      );

  @override
  List<Object?> get props => [
    vehicles,
    currentVehicleId,
    userSettings,
    odometerString,
    unitString,
    isLoading,
    errorMessage,
    sideEffect,
  ];

  RecordsState copyWith({
    List<Vehicle>? vehicles,
    String? currentVehicleId,
    UserSettings? userSettings,
    String? odometerString,
    String? unitString,
    bool? isLoading,
    String? errorMessage,
    RecordsSideEffect? sideEffect,
    bool clearSideEffect = false,
    bool clearError = false,
  }) {
    return RecordsState(
      vehicles: vehicles ?? this.vehicles,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      userSettings: userSettings ?? this.userSettings,
      odometerString: odometerString ?? this.odometerString,
      unitString: unitString ?? this.unitString,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sideEffect: clearSideEffect ? null : sideEffect,
    );
  }
}
