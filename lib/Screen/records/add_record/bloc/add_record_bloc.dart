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
        AddRecordState(
          date: DateTime.now(),
          km: vehicle.currentKm,
          // 預設新增一個空的保養項目
          maintenanceEntries: [MaintenanceData()],
        ),
      ) {
    on<RecordTypeChanged>(_onRecordTypeChanged);
    on<AmountChanged>(_onAmountChanged);
    on<DateChanged>(_onDateChanged);
    on<KmChanged>(_onKmChanged);
    on<NoteChanged>(_onNoteChanged);
    on<SubmitRecord>(_onSubmitRecord);
    // 保養項目批次新增事件
    on<AddMaintenanceEntry>(_onAddMaintenanceEntry);
    on<RemoveMaintenanceEntry>(_onRemoveMaintenanceEntry);
    on<UpdateMaintenanceEntry>(_onUpdateMaintenanceEntry);
    // 加油相關事件
    on<FuelTypeChanged>(_onFuelTypeChanged);
    on<FuelAmountChanged>(_onFuelAmountChanged);
    on<PricePerLiterChanged>(_onPricePerLiterChanged);
    on<RemainingFuelChanged>(_onRemainingFuelChanged);
  }

  void _onRecordTypeChanged(
    RecordTypeChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWith(recordType: event.type));
  }

  void _onAmountChanged(AmountChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(amount: event.amount, isAmountManuallyEdited: true));
  }

  void _onDateChanged(DateChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onKmChanged(KmChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(km: event.km));
  }

  void _onNoteChanged(NoteChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(note: event.note));
  }

  // 保養項目批次新增事件處理
  void _onAddMaintenanceEntry(
    AddMaintenanceEntry event,
    Emitter<AddRecordState> emit,
  ) {
    final entries = List<MaintenanceData>.from(state.maintenanceEntries);
    entries.add(MaintenanceData());
    emit(state.copyWith(maintenanceEntries: entries));
  }

  void _onRemoveMaintenanceEntry(
    RemoveMaintenanceEntry event,
    Emitter<AddRecordState> emit,
  ) {
    final entries = List<MaintenanceData>.from(state.maintenanceEntries);
    if (event.index >= 0 && event.index < entries.length) {
      entries.removeAt(event.index);
      emit(state.copyWith(maintenanceEntries: entries));
    }
  }

  void _onUpdateMaintenanceEntry(
    UpdateMaintenanceEntry event,
    Emitter<AddRecordState> emit,
  ) {
    if (event.index < 0 || event.index >= state.maintenanceEntries.length) {
      return;
    }

    final entries = List<MaintenanceData>.from(state.maintenanceEntries);
    final current = entries[event.index];

    entries[event.index] = current.copyWith(
      item: event.item,
      amount: event.amount,
      nextMaintenanceKm: event.nextMaintenanceKm,
      note: event.note,
    );

    emit(state.copyWith(maintenanceEntries: entries));
  }

  // 加油相關事件處理
  void _onFuelTypeChanged(FuelTypeChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWith(fuelType: event.fuelType));
  }

  void _onFuelAmountChanged(
    FuelAmountChanged event,
    Emitter<AddRecordState> emit,
  ) {
    final newFuelAmount = event.amount;
    final calculatedAmount = newFuelAmount * state.pricePerLiter;

    if (state.isAmountManuallyEdited) {
      // 用戶已手動編輯金額，不自動更新
      emit(state.copyWith(fuelAmount: newFuelAmount));
    } else {
      // 自動更新金額
      emit(state.copyWith(fuelAmount: newFuelAmount, amount: calculatedAmount));
    }
  }

  void _onPricePerLiterChanged(
    PricePerLiterChanged event,
    Emitter<AddRecordState> emit,
  ) {
    final newPrice = event.price;
    final calculatedAmount = state.fuelAmount * newPrice;

    if (state.isAmountManuallyEdited) {
      // 用戶已手動編輯金額，不自動更新
      emit(state.copyWith(pricePerLiter: newPrice));
    } else {
      // 自動更新金額
      emit(state.copyWith(pricePerLiter: newPrice, amount: calculatedAmount));
    }
  }

  void _onRemainingFuelChanged(
    RemainingFuelChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWith(remainingFuel: event.remaining));
  }

  Future<void> _onSubmitRecord(
    SubmitRecord event,
    Emitter<AddRecordState> emit,
  ) async {
    // 1. 驗證里程數（依賴 Vehicle 資料，保留在 Bloc）
    if (state.recordType.validationError != null) {
      emit(
        state.copyWith(
          status: AddRecordStatus.failure,
          errorMessage: state.recordType.validationError,
        ),
      );
      return;
    }

    // 2. 取得 activeRecordType 並驗證
    final type = state.activeRecordType;

    emit(state.copyWith(status: AddRecordStatus.submitting));

    try {
      late final String title;
      late final double cost;

      switch (type) {
        case RecordTypeMaintenance(:final validEntries, :final totalAmount):
          title = validEntries.length == 1
              ? validEntries.first.item
              : '${type.label} (${validEntries.length} 項)';
          cost = totalAmount;
        case RecordTypeFuel(:final data):
          title = data.formattedSummary;
          cost = state.amount;
        case RecordTypeOther():
          String tempTitle = type.label;
          if (state.note.isNotEmpty) {
            final firstLine = state.note.split('\n').first;
            if (firstLine.length < 20) {
              tempTitle = '$tempTitle - $firstLine';
            }
          }
          title = tempTitle;
          cost = state.amount;
      }

      final record = VehicleRecord.create(
        recordId: const Uuid().v4(),
        type: type,
        title: title,
        date: state.date,
        cost: cost,
        km: state.km,
        notes: state.note.isNotEmpty ? state.note : null,
      );

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
