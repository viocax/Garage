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

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final VehicleRepository vehicleRepository = getIt.repo.vehicle;
  final UserSettingsRepository userSettingsRepository = getIt.repo.userSettings;

  RecordsBloc() : super(const RecordsState()) {
    on<LoadVehicleRecord>(_onLoadVehicleRecord);
    on<SwitchVehicle>(_onSwitchVehicle);
    on<ClickAddVehicleButton>(_onClickAddVehicleButton);
    on<ClickAddRecordButton>(_onClickAddRecordButton);
    on<ClickEditVehicleButton>(_onClickEditVehicleButton);
    on<AddRecords>(_onAddRecords);
    add(const LoadVehicleRecord());
  }

  Future<void> _onAddRecords(
    AddRecords event,
    Emitter<RecordsState> emit,
  ) async {
    if (event.records.isEmpty || state.isEmpty) {
      return;
    }

    final carId = state.currentVehicleId;

    try {
      for (final record in event.records) {
        await vehicleRepository.addRecord(carId, record);
      }

      // 更新車輛里程數為記錄中的最高里程
      
      final maxKm = event.records.reduce((a, b) => a.km > b.km ? a : b).km;
      final vehicle = state.vehicles.firstWhere((v) => v.vehicleId == carId);
      if (maxKm > vehicle.currentKm) {
        vehicle.currentKm = maxKm;
        await vehicleRepository.updateVehicle(vehicle);
      }

      add(LoadVehicleRecord(vehicleId: carId));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        clearSideEffect: true,
      ));
      // Clear error after showing
      emit(state.copyWith(clearError: true));
    }
  }

  void _onClickAddVehicleButton(
    ClickAddVehicleButton event,
    Emitter<RecordsState> emit,
  ) {
    emit(state.copyWith(sideEffect: RecordsSideEffect.navigateToAddVehicle));
    // Clear side effect immediately after emitting
    emit(state.copyWith(clearSideEffect: true));
  }
  void _onClickAddRecordButton(
    ClickAddRecordButton event,
    Emitter<RecordsState> emit,
  ) {
    emit(state.copyWith(sideEffect: RecordsSideEffect.navigateToAddRecord));
    // Clear side effect immediately after emitting
    emit(state.copyWith(clearSideEffect: true));
  }

  void _onClickEditVehicleButton(
    ClickEditVehicleButton event,
    Emitter<RecordsState> emit,
  ) {
    emit(state.copyWith(sideEffect: RecordsSideEffect.navigateToEditVehicle));
    // Clear side effect immediately after emitting
    emit(state.copyWith(clearSideEffect: true));
  }

  Future<void> _onLoadVehicleRecord(
    LoadVehicleRecord event,
    Emitter<RecordsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearSideEffect: true, clearError: true));

    try {
      final vehicles = await vehicleRepository.loadVehicles();
      final userSettings = await userSettingsRepository.loadSettings();

      final unitString = userSettings.speedUnit.displayName;
      final currentVehicleId = event.vehicleId ??
          (vehicles.isEmpty ? '' : vehicles.first.vehicleId);

      final km = vehicles.isEmpty
          ? 0
          : vehicles.firstWhere(
              (v) => v.vehicleId == currentVehicleId,
              orElse: () => vehicles.first,
            ).currentKm;

      final odometerString = switch (userSettings.speedUnit) {
        SpeedUnit.kmh => '$km',
        SpeedUnit.mph => '${km.toDouble().mile}',
      };

      emit(RecordsState(
        vehicles: vehicles,
        currentVehicleId: currentVehicleId,
        userSettings: userSettings,
        odometerString: odometerString,
        unitString: unitString,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      // Clear error after showing
      emit(state.copyWith(clearError: true));
    }
  }

  void _onSwitchVehicle(SwitchVehicle event, Emitter<RecordsState> emit) {
    if (state.isEmpty) {
      return;
    }

    final vehicleExists = state.vehicles.any(
      (v) => v.vehicleId == event.vehicleId,
    );

    if (!vehicleExists) {
      return;
    }

    final vehicle = state.vehicles.firstWhere(
      (v) => v.vehicleId == event.vehicleId,
    );

    final km = vehicle.currentKm;
    final speedUnit = state.userSettings?.speedUnit ?? SpeedUnit.kmh;
    final odometerString = switch (speedUnit) {
      SpeedUnit.kmh => '$km',
      SpeedUnit.mph => '${km.toDouble().mile}',
    };

    emit(state.copyWith(
      currentVehicleId: event.vehicleId,
      odometerString: odometerString,
    ));
  }
}
