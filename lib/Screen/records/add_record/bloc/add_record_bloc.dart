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
    // 驗證欄位
    final validationError = _validateFields();
    if (validationError != null) {
      emit(
        state.copyWith(
          status: AddRecordStatus.failure,
          errorMessage: validationError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddRecordStatus.submitting));

    try {
      final List<VehicleRecord> records = [];

      // 根據記錄類型建立記錄
      switch (state.recordType) {
        case RecordTypeMaintenance():
          // 保養類型：為每個有效的保養項目建立獨立記錄
          final validEntries = state.maintenanceEntries
              .where((e) => e.item.isNotEmpty)
              .toList();

          for (final entry in validEntries) {
            final record = VehicleRecord.create(
              recordId: const Uuid().v4(),
              type: RecordTypeMaintenance(entry),
              title: entry.item,
              date: state.date,
              cost: entry.amount,
              km: state.km,
              notes: entry.note.isNotEmpty ? entry.note : null,
            );
            records.add(record);
          }

        case RecordTypeFuel():
          // 加油類型建立單筆記錄
          final fuelData = FuelData(
            fuelType: state.fuelType,
            fuelAmount: state.fuelAmount,
            pricePerLiter: state.pricePerLiter,
            remainingFuel: state.remainingFuel,
          );

          final record = VehicleRecord.create(
            recordId: const Uuid().v4(),
            type: RecordTypeFuel(fuelData),
            title: fuelData.formattedSummary,
            date: state.date,
            cost: state.amount,
            km: state.km,
            notes: state.note.isNotEmpty ? state.note : null,
          );
          records.add(record);

        case RecordTypeOther():
          // 其他類型建立單筆記錄
          String title = state.recordType.label;
          if (state.note.isNotEmpty) {
            final firstLine = state.note.split('\n').first;
            if (firstLine.length < 20) {
              title = '$title - $firstLine';
            }
          }

          final record = VehicleRecord.create(
            recordId: const Uuid().v4(),
            type: const RecordTypeOther(),
            title: title,
            date: state.date,
            cost: state.amount,
            km: state.km,
            notes: state.note.isNotEmpty ? state.note : null,
          );
          records.add(record);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        state.copyWith(
          status: AddRecordStatus.success,
          createdRecords: records,
        ),
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

  String? _validateFields() {
    // 1. 驗證里程數：輸入的目前里程數要高於車輛目前的里程
    if (state.km <= vehicle.currentKm) {
      return '目前里程數 必須大於車輛目前里程';
    }

    // 2. 根據類別驗證
    switch (state.recordType) {
      case RecordTypeMaintenance():
        // 保養類別：檢查是否有有效的保養項目
        final validEntries = state.maintenanceEntries
            .where((e) => e.item.trim().isNotEmpty)
            .toList();

        if (validEntries.isEmpty) {
          return '請至少輸入一個保養項目';
        }

      case RecordTypeFuel():
        // 加油類別：檢查加油量
        if (state.fuelAmount <= 0) {
          return '請輸入有效的加油量';
        }

      case RecordTypeOther():
        // 其他類別無特殊驗證
        break;
    }

    // 備註欄位都是 optional，無需驗證

    return null;
  }
}
