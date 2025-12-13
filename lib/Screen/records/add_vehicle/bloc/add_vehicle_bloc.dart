import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

part 'add_vehicle_event.dart';
part 'add_vehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  final VehicleRepository _vehicleRepository = getIt.repo.vehicle;
  final UserSettingsRepository _userSettingsRepository = getIt.repo.userSettings;

  AddVehicleBloc() : super(const AddVehicleState(speedUnit: SpeedUnit.kmh)) {
    on<LoadUserSettings>(_onLoadUserSettings);
    on<VehicleNameChanged>(_onVehicleNameChanged);
    on<VehicleKmChanged>(_onVehicleKmChanged);
    on<MaintenanceIntervalChanged>(_onMaintenanceIntervalChanged);
    on<SubmitVehicle>(_onSubmitVehicle);
    add(const LoadUserSettings());
  }

  Future<void> _onLoadUserSettings(
    LoadUserSettings event,
    Emitter<AddVehicleState> emit,
  ) async {
    try {
      final userSettings = await _userSettingsRepository.loadSettings();
      emit(state.copyWith(speedUnit: userSettings.speedUnit));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onVehicleNameChanged(
    VehicleNameChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(vehicleName: event.name));
  }

  void _onVehicleKmChanged(
    VehicleKmChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(currentKm: event.km));
  }

  void _onMaintenanceIntervalChanged(
    MaintenanceIntervalChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(maintenanceIntervalKm: event.interval));
  }

  Future<void> _onSubmitVehicle(
    SubmitVehicle event,
    Emitter<AddVehicleState> emit,
  ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: AddVehicleStatus.failure,
          errorMessage: '請填寫完整',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddVehicleStatus.submitting));

    try {
      final vehicle = Vehicle.create(
        carName: state.vehicleName,
        currentKm: state.currentKm,
        maintenanceIntervalKm: state.maintenanceIntervalKm,
      );

      final success = await _vehicleRepository.addVehicle(vehicle);

      if (success) {
        emit(
          state.copyWith(
            status: AddVehicleStatus.success,
            createdVehicle: vehicle,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AddVehicleStatus.failure,
            errorMessage: '新增車輛失敗',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AddVehicleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
