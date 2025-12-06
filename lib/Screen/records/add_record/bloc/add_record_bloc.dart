import 'package:bloc/bloc.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:uuid/uuid.dart';
import 'add_record_event.dart';
import 'add_record_state.dart';

import 'package:garage/core/models/vehicle.dart';

class AddRecordBloc extends Bloc<AddRecordEvent, AddRecordState> {
  final Vehicle vehicle;

  AddRecordBloc({required this.vehicle})
    : super(
        AddRecordState(date: DateTime.now(), mileage: vehicle.currentMileage),
      ) {
    on<RecordTypeChanged>(_onRecordTypeChanged);
    on<AmountChanged>(_onAmountChanged);
    on<DateChanged>(_onDateChanged);
    on<MileageChanged>(_onMileageChanged);
    on<NextMaintenanceMileageChanged>(_onNextMaintenanceMileageChanged);
    on<MaintenanceItemToggled>(_onMaintenanceItemToggled);
    on<NoteChanged>(_onNoteChanged);
    on<SubmitRecord>(_onSubmitRecord);
  }

  void _onRecordTypeChanged(
    RecordTypeChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWith(recordType: event.type));
  }

  void _onAmountChanged(AmountChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onDateChanged(DateChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onMileageChanged(MileageChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(mileage: event.mileage));
  }

  void _onNextMaintenanceMileageChanged(
    NextMaintenanceMileageChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWith(nextMaintenanceMileage: event.mileage));
  }

  void _onMaintenanceItemToggled(
    MaintenanceItemToggled event,
    Emitter<AddRecordState> emit,
  ) {
    final items = List<String>.from(state.selectedMaintenanceItems);
    if (items.contains(event.item)) {
      items.remove(event.item);
    } else {
      items.add(event.item);
    }
    emit(state.copyWith(selectedMaintenanceItems: items));
  }

  void _onNoteChanged(NoteChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(note: event.note));
  }

  Future<void> _onSubmitRecord(
    SubmitRecord event,
    Emitter<AddRecordState> emit,
  ) async {
    emit(state.copyWith(status: AddRecordStatus.submitting));

    try {
      // Create title based on collected data
      String title = state.recordType.label;
      if (state.recordType == RecordType.maintenance &&
          state.selectedMaintenanceItems.isNotEmpty) {
        title = state.selectedMaintenanceItems.join('、');
      } else if (state.note.isNotEmpty) {
        // Use first line of note as part of title if generic
        final firstLine = state.note.split('\n').first;
        if (firstLine.length < 20) {
          title = '$title - $firstLine'; // e.g. "其他 - 買東西"
        }
      }

      final record = VehicleRecord(
        id: const Uuid().v4(),
        type: state.recordType,
        title: title,
        date: state.date,
        cost: state.amount,
        mileage: state.mileage,
        notes: state.note,
      );

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        state.copyWith(status: AddRecordStatus.success, createdRecord: record),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddRecordStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
