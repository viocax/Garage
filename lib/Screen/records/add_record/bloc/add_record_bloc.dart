import 'package:bloc/bloc.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:uuid/uuid.dart';
import 'add_record_event.dart';
import 'add_record_state.dart';

import 'package:garage/core/models/vehicle.dart';

import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/utils/log.dart';

class AddRecordBloc extends Bloc<AddRecordEvent, AddRecordState> {
  final Vehicle vehicle;
  final VehicleRepository _repository;
  final AdRepository _adRepository;
  final UserSettingsRepository _userSettingsRepository;

  AddRecordBloc({
    required this.vehicle,
    VehicleRepository? repository,
    AdRepository? adRepository,
    UserSettingsRepository? userSettingsRepository,
  }) : _repository = repository ?? getIt.repo.vehicle,
       _adRepository = adRepository ?? getIt.repo.ad,
       _userSettingsRepository =
           userSettingsRepository ?? getIt.repo.userSettings,
       super(
         AddRecordState(
           // 預設為加油類型，帶入當前日期和車輛里程
           recordType: RecordTypeFuel(
             data: FuelData(),
             recordDate: DateTime.now(),
             odometer: vehicle.currentKm,
           ),
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
    // 使用者設定
    on<LoadUserSettings>(_onLoadUserSettings);
    // 發票掃描
    on<InvoiceDataApplied>(_onInvoiceDataApplied);

    // 立即載入使用者設定
    add(const LoadUserSettings());
  }

  void _onRecordTypeChanged(
    RecordTypeChanged event,
    Emitter<AddRecordState> emit,
  ) {
    // 切換類型時，保留 date 和 km，並保留該類型的資料
    final currentDate = state.date;
    final currentKm = state.km;

    final RecordType newType = switch (event.type) {
      RecordTypeFuel() =>
        state.recordType is RecordTypeFuel
            ? state.recordType
            : RecordTypeFuel(
                data: FuelData(),
                recordDate: currentDate,
                odometer: currentKm,
              ),
      RecordTypeMaintenance() =>
        state.recordType is RecordTypeMaintenance
            ? state.recordType
            : RecordTypeMaintenance(
                data: [MaintenanceData()],
                recordDate: currentDate,
                odometer: currentKm,
              ),
      RecordTypeOther() =>
        state.recordType is RecordTypeOther
            ? state.recordType
            : RecordTypeOther(
                data: OtherData(),
                recordDate: currentDate,
                odometer: currentKm,
              ),
    };

    emit(
      state.copyWith(
        recordType: newType,
        clearError: true,
        isAmountManuallyEdited: false,
      ),
    );
  }

  void _onAmountChanged(AmountChanged event, Emitter<AddRecordState> emit) {
    // 根據當前類型更新金額
    switch (state.recordType) {
      case RecordTypeFuel():
        if (state.pricePerLiter > 0) {
          emit(
            state.copyWithFuelData(
              fuelAmount: event.amount / state.pricePerLiter,
              isAmountManuallyEdited: true,
            ),
          );
        }
        break;
      case RecordTypeOther():
        emit(state.copyWithOtherData(amount: event.amount));
        break;
      case RecordTypeMaintenance():
        // 保養類型的金額在各項目中輸入，這裡不處理
        break;
    }
  }

  void _onDateChanged(DateChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWithCommonFields(date: event.date));
  }

  void _onKmChanged(KmChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWithCommonFields(km: event.km));
  }

  void _onNoteChanged(NoteChanged event, Emitter<AddRecordState> emit) {
    // 只有 Other 類型需要處理備註
    if (state.recordType is RecordTypeOther) {
      emit(state.copyWithOtherData(note: event.note));
    }
  }

  // 保養項目批次新增事件處理
  void _onAddMaintenanceEntry(
    AddMaintenanceEntry event,
    Emitter<AddRecordState> emit,
  ) {
    final entries = List<MaintenanceData>.from(state.maintenanceEntries);
    entries.add(MaintenanceData());
    emit(state.copyWithMaintenanceEntries(entries));
  }

  void _onRemoveMaintenanceEntry(
    RemoveMaintenanceEntry event,
    Emitter<AddRecordState> emit,
  ) {
    final entries = List<MaintenanceData>.from(state.maintenanceEntries);
    if (event.index >= 0 && event.index < entries.length) {
      entries.removeAt(event.index);
      emit(state.copyWithMaintenanceEntries(entries));
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

    emit(state.copyWithMaintenanceEntries(entries));
  }

  // 加油相關事件處理
  void _onFuelTypeChanged(FuelTypeChanged event, Emitter<AddRecordState> emit) {
    emit(state.copyWithFuelData(fuelType: event.fuelType));
  }

  void _onFuelAmountChanged(
    FuelAmountChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWithFuelData(fuelAmount: event.amount));
  }

  void _onPricePerLiterChanged(
    PricePerLiterChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWithFuelData(pricePerLiter: event.price));
  }

  void _onRemainingFuelChanged(
    RemainingFuelChanged event,
    Emitter<AddRecordState> emit,
  ) {
    emit(state.copyWithFuelData(remainingFuel: event.remaining));
  }

  Future<void> _onSubmitRecord(
    SubmitRecord event,
    Emitter<AddRecordState> emit,
  ) async {
    // 1. 驗證 RecordType 資料
    if (state.recordType.validationError != null) {
      emit(
        state.copyWith(
          status: AddRecordStatus.failure,
          errorMessage: state.recordType.validationError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddRecordStatus.submitting));

    try {
      late final String title;
      late final double cost;
      String? notes;

      switch (state.recordType) {
        case RecordTypeMaintenance(:final validEntries, :final totalAmount):
          title = validEntries.length == 1
              ? validEntries.first.item
              : '保養 (${validEntries.length} 項)';
          cost = totalAmount;
        case RecordTypeFuel(:final data):
          title = data.formattedSummary;
          cost = data.calculatedCost;
        case RecordTypeOther(:final data):
          String tempTitle = '其他';
          if (data.note.isNotEmpty) {
            final firstLine = data.note.split('\n').first;
            if (firstLine.length < 20) {
              tempTitle = '$tempTitle - $firstLine';
            }
          }
          title = tempTitle;
          cost = data.amount;
          notes = data.note.isNotEmpty ? data.note : null;
      }

      final record = VehicleRecord.create(
        recordId: const Uuid().v4(),
        vehicleId: vehicle.vehicleId,
        type: state.recordType,
        title: title,
        date: state.date,
        cost: cost,
        km: state.km,
        notes: notes,
      );

      await _repository.addRecord(vehicle.vehicleId, record);

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

  /// 載入使用者設定
  Future<void> _onLoadUserSettings(
    LoadUserSettings event,
    Emitter<AddRecordState> emit,
  ) async {
    try {
      final userSettings = await _userSettingsRepository.loadSettings();
      emit(state.copyWith(speedUnit: userSettings.speedUnit));
    } catch (e) {
      Log.e('AddRecordBloc: Failed to load user settings', e);
      emit(state.copyWith(speedUnit: SpeedUnit.kmh));
    }
  }

  /// 顯示廣告邏輯（由 UI 呼叫，封裝規則）
  void showAd({required void Function() onComplete}) {
    _adRepository.showInterstitialAd(onComplete: onComplete);
  }

  /// 套用發票掃描資料
  void _onInvoiceDataApplied(
    InvoiceDataApplied event,
    Emitter<AddRecordState> emit,
  ) {
    // 更新金額和日期
    emit(
      state
          .copyWithCommonFields(date: event.date)
          .copyWithOtherData(amount: event.amount),
    );

    // 如果是加油類型且金額有設定，標記為手動編輯
    if (state.recordType is RecordTypeFuel && event.amount > 0) {
      emit(state.copyWith(isAmountManuallyEdited: true));
    }
  }
}
