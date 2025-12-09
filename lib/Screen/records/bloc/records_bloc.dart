import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

part 'records_event.dart';
part 'records_state.dart';

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final VehicleRepository vehicleRepository = getIt.repo.vehicle;

  RecordsBloc() : super(RecordsLoading()) {
    on<LoadVehicleRecord>(_onLoadVehicleRecord);
    on<SwitchVehicle>(_onSwitchVehicle);
    on<ClickAddButton>(_onClickAddButton);
    on<AddVehicleRecord>(_onAddVehicleRecord);
    add(LoadVehicleRecord());
  }

  void _onClickAddButton(ClickAddButton event, Emitter<RecordsState> emit) {
    // This is now handled by the UI opening the sheet, and dispatching AddVehicleRecord on success
  }

  void _onAddVehicleRecord(AddVehicleRecord event, Emitter<RecordsState> emit) {
    final currentState = state;
    if (currentState is! RecordsLoaded) {
      // Find current vehicle
      return;
    }
    if (currentState.vehicles.isEmpty) {
      emit(currentState.copyWith(clickAddEvent: ClickAddEvent.addVehicle));
    } else {
      emit(currentState.copyWith(clickAddEvent: ClickAddEvent.addRecord));
    }
    emit(currentState.copyWith(clickAddEvent: null));
  }

  Future<void> _onLoadVehicleRecord(
    LoadVehicleRecord event,
    Emitter<RecordsState> emit,
  ) async {
    emit(RecordsLoading());
    try {
      final vehicles = await vehicleRepository.loadVehicles();

      if (vehicles.isEmpty) {
        emit(RecordsEmpty());
        return;
      }

      // Use the first vehicle as the default current vehicle
      emit(
        RecordsLoaded(
          vehicles: vehicles,
          currentVehicleId: vehicles.first.vehicleId,
        ),
      );
    } catch (e) {
      emit(RecordsError(e.toString()));
    }
  }

  void _onSwitchVehicle(SwitchVehicle event, Emitter<RecordsState> emit) {
    final currentState = state;
    if (currentState is RecordsLoaded) {
      // Check if the requested vehicle exists
      final vehicleExists = currentState.vehicles.any(
        (v) => v.vehicleId == event.vehicleId,
      );
      if (vehicleExists) {
        emit(
          RecordsLoaded(
            vehicles: currentState.vehicles,
            currentVehicleId: event.vehicleId,
          ),
        );
      }
    }
  }
}
