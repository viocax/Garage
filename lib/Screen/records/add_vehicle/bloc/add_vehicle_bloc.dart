import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/utils/log.dart';

part 'add_vehicle_event.dart';
part 'add_vehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  final VehicleRepository _vehicleRepository;
  final UserSettingsRepository _userSettingsRepository;
  final AdRepository _adRepository;

  AddVehicleBloc({
    VehicleRepository? vehicleRepository,
    UserSettingsRepository? userSettingsRepository,
    AdRepository? adRepository,
    Vehicle? vehicleToEdit,
  }) : _vehicleRepository = vehicleRepository ?? getIt.repo.vehicle,
       _userSettingsRepository =
           userSettingsRepository ?? getIt.repo.userSettings,
       _adRepository = adRepository ?? getIt.repo.ad,
       super(
         AddVehicleState(
           speedUnit: SpeedUnit.kmh,
           // Update initial state if editing
           vehicleName: vehicleToEdit?.carName ?? '',
           licensePlate: vehicleToEdit?.licensePlate ?? '',
           currentKm: vehicleToEdit?.currentKm ?? 0,
           maintenanceIntervalKm: vehicleToEdit?.maintenanceIntervalKm ?? 0,
           editingVehicle: vehicleToEdit,
         ),
       ) {
    on<LoadUserSettings>(_onLoadUserSettings);
    on<VehicleNameChanged>(_onVehicleNameChanged);
    on<LicensePlateChanged>(_onLicensePlateChanged);
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
      // If editing, we might want to keep the unit consistent with settings,
      // OR we might want to respect the vehicle's original context?
      // Usually miles/km is a global display setting.
      // The stored values are usually raw (e.g. km).
      emit(state.copyWith(speedUnit: userSettings.speedUnit));
    } catch (e) {
      Log.e('AddVehicleBloc: Failed to load user settings', e);
    }
  }

  void _onVehicleNameChanged(
    VehicleNameChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(vehicleName: event.name));
  }

  void _onLicensePlateChanged(
    LicensePlateChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(licensePlate: event.licensePlate));
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
          errorMessage: 'addVehicle.fillAllFields'.tr(),
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddVehicleStatus.submitting));

    try {
      final isEditing = state.isEditing;
      final editingVehicle = state.editingVehicle;

      final vehicle = isEditing && editingVehicle != null
          ? (Vehicle()
              ..id = editingVehicle.id
              ..vehicleId = editingVehicle.vehicleId
              ..carName = state.vehicleName
              ..licensePlate = state.licensePlate
              ..currentKm = state.currentKm
              ..maintenanceIntervalKm = state.maintenanceIntervalKm
              ..order = editingVehicle.order
              ..kmToNextMaintenance = state.currentKm + state.maintenanceIntervalKm)
          : Vehicle.create(
              carName: state.vehicleName,
              licensePlate: state.licensePlate,
              currentKm: state.currentKm,
              maintenanceIntervalKm: state.maintenanceIntervalKm,
            );

      final success = isEditing
          ? await _vehicleRepository.updateVehicle(vehicle)
          : await _vehicleRepository.addVehicle(vehicle);

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
            errorMessage: isEditing
                ? 'addVehicle.updateVehicleFailed'.tr()
                : 'addVehicle.addVehicleFailed'.tr(),
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

  /// 顯示廣告邏輯（由 UI 呼叫，封裝規則）
  void showAd({required void Function() onComplete}) {
    // 如果是編輯模式，直接完成（不顯示廣告）
    if (state.isEditing) {
      onComplete();
      return;
    }
    _adRepository.showInterstitialAd(onComplete: onComplete);
  }
}
