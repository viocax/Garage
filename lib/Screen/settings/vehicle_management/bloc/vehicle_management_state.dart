import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle.dart';

class VehicleManagementState extends Equatable {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? errorMessage;

  const VehicleManagementState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [vehicles, isLoading, errorMessage];

  VehicleManagementState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VehicleManagementState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
