import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

part 'add_vehicle_event.dart';
part 'add_vehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  final VehicleRepository _vehicleRepository = getIt.repo.vehicle;
  final UserSettingsRepository _userSettingsRepository = getIt.repo.userSettings;

  AddVehicleBloc() : super(const AddVehicleState()) {
    on<VehicleNameChanged>(_onVehicleNameChanged);
    on<VehicleMileageChanged>(_onVehicleMileageChanged);
    on<MaintenanceIntervalChanged>(_onMaintenanceIntervalChanged);
    on<SubmitVehicle>(_onSubmitVehicle);
  }

  void _onVehicleNameChanged(
    VehicleNameChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(vehicleName: event.name));
  }

  void _onVehicleMileageChanged(
    VehicleMileageChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(currentMileage: event.mileage));
  }

  void _onMaintenanceIntervalChanged(
    MaintenanceIntervalChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(maintenanceInterval: event.interval));
  }

  Future<void> _onSubmitVehicle(
    SubmitVehicle event,
    Emitter<AddVehicleState> emit,
  ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: AddVehicleStatus.failure,
          errorMessage: '請填寫車輛名稱',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddVehicleStatus.submitting));

    try {
      final vehicle = Vehicle.create(
        carName: state.vehicleName,
        currentMileage: state.currentMileage,
        maintenanceInterval: state.maintenanceInterval,
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
