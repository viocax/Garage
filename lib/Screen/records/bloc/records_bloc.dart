import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

part 'records_event.dart';
part 'records_state.dart';

enum ClickAddEvent { addVehicle, addRecord }

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final VehicleRepository vehicleRepository = getIt.repo.vehicle;
  final UserSettingsRepository userSettingsRepository = getIt.repo.userSettings;

  RecordsBloc() : super(RecordsLoading()) {
    on<LoadVehicleRecord>(_onLoadVehicleRecord);
    on<SwitchVehicle>(_onSwitchVehicle);
    on<AddVehicle>(_onAddVehicle);
    on<AddRecord>(_onAddRecord);
    add(LoadVehicleRecord());
  }

  String get odometer {
    return switch (state) {
      RecordsLoading() => '',
      RecordsEmpty() => '0',
      RecordsLoaded(:final currentVehicle, :final userSettings) => () {
          final km = currentVehicle.currentKm;
          final unit = userSettings.speedUnit;

          return switch (unit) {
            SpeedUnit.kmh => '$km',
            SpeedUnit.mph => () {
                final miles = km.toDouble().mile;
                return '$miles';
              }(),
          };
        }(),
      RecordsError() => '',
    };
  }
  String get unitString {
        return switch (state) {
      RecordsLoading() => '',
      RecordsEmpty(:final userSettings) => userSettings.speedUnit.displayName,
      RecordsLoaded(:final userSettings) => userSettings.speedUnit.displayName,
      RecordsError() => '',
    };
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<RecordsState> emit,
  ) async {
    if (event.vehicle == null) {
      // cancel add vehicle, do not doing anything
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
      // cancel add record, do not doing anything
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
      final userSettings = await userSettingsRepository.loadSettings();

      if (vehicles.isEmpty) {
        emit(RecordsEmpty(userSettings: userSettings));
        return;
      }

      // Use the first vehicle as the default current vehicle
      emit(
        RecordsLoaded(
          vehicles: vehicles,
          currentVehicleId: event.vehicleId ?? vehicles.first.vehicleId,
          userSettings: userSettings,
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
          currentState.copyWith(
            currentVehicleId: event.vehicleId,
          ),
        );
      }
    }
  }
}
