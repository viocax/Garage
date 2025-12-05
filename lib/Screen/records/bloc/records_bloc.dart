import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';

part 'records_event.dart';
part 'records_state.dart';

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  RecordsBloc() : super(RecordsLoading()) {
    on<LoadVehicleRecord>(_onLoadVehicleRecord);
    on<SwitchVehicle>(_onSwitchVehicle);
    on<ClickAddButton>(_onClickAddButton);
    add(LoadVehicleRecord());
  }

  void _onClickAddButton(ClickAddButton event, Emitter<RecordsState> emit) {
    // current vehicle
    final currentState = state;
    if (currentState is! RecordsLoaded) {
      return;
    }
    if (currentState.vehicles.isEmpty) {
      // add vehicle
    } else {
      // add record
    }
  }

  Future<void> _onLoadVehicleRecord(
    LoadVehicleRecord event,
    Emitter<RecordsState> emit,
  ) async {
    emit(RecordsLoading());
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));
      // emit(RecordsEmpty());
      // return;

      // Mock Data - Create multiple vehicles
      final mockVehicle1 = Vehicle(
        id: 'v1',
        carName: 'Honda Civic Type R',
        currentMileage: 12450,
        maintenanceInterval: 5000,
        records: [
          VehicleRecord(
            id: 'r1',
            type: RecordType.modification,
            title: '進氣系統升級 (HKS Intake)',
            date: DateTime.now(),
            cost: 32000,
            mileage: 12450,
            notes: 'Stage 1 upgrade',
          ),
          VehicleRecord(
            id: 'r2',
            type: RecordType.maintenance,
            title: '定期保養 (機油/濾網)',
            date: DateTime(2023, 10, 15),
            cost: 3500,
            mileage: 12000,
          ),
          VehicleRecord(
            id: 'r3',
            type: RecordType.fuel,
            title: '98無鉛汽油 (45L)',
            date: DateTime(2023, 10, 10),
            cost: 1500,
            mileage: 11800,
          ),
        ],
      );

      final mockVehicle2 = Vehicle(
        id: 'v2',
        carName: 'Toyota Supra A90',
        currentMileage: 8500,
        maintenanceInterval: 10000,
        records: [
          VehicleRecord(
            id: 'r4',
            type: RecordType.modification,
            title: '排氣系統升級',
            date: DateTime(2023, 11, 1),
            cost: 45000,
            mileage: 8500,
          ),
        ],
      );

      emit(
        RecordsLoaded(
          vehicles: [mockVehicle1, mockVehicle2],
          currentVehicleId: 'v1',
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
        (v) => v.id == event.vehicleId,
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
