import 'package:bloc/bloc.dart';
import 'package:garage/core/core.dart';
import 'vehicle_management_event.dart';
import 'vehicle_management_state.dart';

class VehicleManagementBloc
    extends Bloc<VehicleManagementEvent, VehicleManagementState> {
  final VehicleRepository vehicleRepository;

  VehicleManagementBloc({
    VehicleRepository? vehicleRepository,
  })  : vehicleRepository = vehicleRepository ?? getIt.repo.vehicle,
        super(const VehicleManagementState()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<ReorderVehicles>(_onReorderVehicles);
    on<DeleteVehicle>(_onDeleteVehicle);
    add(const LoadVehicles());
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final vehicles = await vehicleRepository.loadVehicles();
      emit(VehicleManagementState(
        vehicles: vehicles,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onReorderVehicles(
    ReorderVehicles event,
    Emitter<VehicleManagementState> emit,
  ) async {
    final vehicles = List<Vehicle>.from(state.vehicles);

    int oldIndex = event.oldIndex;
    int newIndex = event.newIndex;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = vehicles.removeAt(oldIndex);
    vehicles.insert(newIndex, item);

    // Update order field for all vehicles
    for (int i = 0; i < vehicles.length; i++) {
      vehicles[i].order = i;
    }

    emit(state.copyWith(vehicles: vehicles));

    // Persist the new order to database
    try {
      for (final vehicle in vehicles) {
        await vehicleRepository.updateVehicle(vehicle);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: '更新排序失敗: ${e.toString()}'));
      emit(state.copyWith(clearError: true));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleManagementState> emit,
  ) async {
    try {
      await vehicleRepository.removeVehicle(event.vehicleId);

      // Remove from local state
      final vehicles = state.vehicles
          .where((v) => v.vehicleId != event.vehicleId)
          .toList();

      emit(state.copyWith(vehicles: vehicles));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      // Clear error after showing
      emit(state.copyWith(clearError: true));
    }
  }
}
