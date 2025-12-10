import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

part 'records_event.dart';
part 'records_state.dart';

enum ClickAddEvent { addVehicle, addRecord }

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final VehicleRepository vehicleRepository = getIt.repo.vehicle;

  RecordsBloc() : super(RecordsLoading()) {
    on<LoadVehicleRecord>(_onLoadVehicleRecord);
    on<SwitchVehicle>(_onSwitchVehicle);
    on<AddVehicle>(_onAddVehicle);
    on<AddRecord>(_onAddRecord);
    add(LoadVehicleRecord());
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<RecordsState> emit,
  ) async {
    if (event.vehicle == null) {
      // TODO: error handle
      emit(RecordsError('Vehicle is null'));
      return;
    }
    emit(RecordsLoading());
    try {
      await vehicleRepository.addVehicle(event.vehicle!);
      add(LoadVehicleRecord());
    } catch (e) {
      emit(RecordsError(e.toString()));
    }
  }

  Future<void> _onAddRecord(
    AddRecord event,
    Emitter<RecordsState> emit,
  ) async {
    if (event.record == null) {
      // TODO: error handle
      emit(RecordsError('Record is null'));
      return;
    }
    if (state is! RecordsLoaded) {
      return;
    }
    final currentState = state as RecordsLoaded;
    final carId = currentState.currentVehicleId;
    emit(RecordsLoading());
    try {
      await vehicleRepository.addRecord(carId, event.record!);
      add(LoadVehicleRecord(vehicleId: carId));
    } catch (e) {
      emit(RecordsError(e.toString()));
    }
  }

  ClickAddEvent clickAction() {
    final state = this.state;
    if (state is RecordsEmpty) {
      return ClickAddEvent.addVehicle;
    }
    if (state is RecordsLoaded) {
      if (state.vehicles.isEmpty) {
        return ClickAddEvent.addVehicle;
      }
    }
    return ClickAddEvent.addRecord;
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
          currentVehicleId: event.vehicleId ?? vehicles.first.vehicleId,
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
