import 'package:equatable/equatable.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/vehicle_record.dart';

enum AddRecordStatus { initial, valid, submitting, success, failure }

class AddRecordState extends Equatable {
  /// 記錄類型（包含該類型的所有資料，包括 recordDate 和 odometer）
  final RecordType recordType;

  /// 狀態相關
  final AddRecordStatus status;
  final String? errorMessage;
  final VehicleRecord? createdRecord;

  /// 加油專用：追蹤金額是否被手動編輯
  final bool isAmountManuallyEdited;

  /// 使用者設定的速度單位
  final SpeedUnit speedUnit;

  const AddRecordState({
    required this.recordType,
    this.status = AddRecordStatus.initial,
    this.errorMessage,
    this.createdRecord,
    this.isAmountManuallyEdited = false,
    this.speedUnit = SpeedUnit.kmh,
  });

  // ============ 共用欄位 Getter（從 RecordType 取得）============

  DateTime get date => recordType.recordDate;
  int get km => recordType.odometer;

  // ============ Fuel 相關 Getter ============

  /// 取得 FuelData（僅當 recordType 為 Fuel 時有效）
  FuelData get fuelData => recordType is RecordTypeFuel
      ? (recordType as RecordTypeFuel).data
      : FuelData();

  FuelType get fuelType => fuelData.fuelType;
  double get fuelAmount => fuelData.fuelAmount;
  double get pricePerLiter => fuelData.pricePerLiter;
  int get remainingFuel => fuelData.remainingFuel;

  /// 加油金額（自動計算或手動輸入）
  double get amount => fuelData.calculatedCost;

  // ============ Maintenance 相關 Getter ============

  /// 取得保養項目列表
  List<MaintenanceData> get maintenanceEntries =>
      recordType is RecordTypeMaintenance
      ? (recordType as RecordTypeMaintenance).data
      : [];

  /// 計算保養項目總金額
  double get totalMaintenanceAmount => recordType is RecordTypeMaintenance
      ? (recordType as RecordTypeMaintenance).totalAmount
      : 0;

  // ============ Other 相關 Getter ============

  /// 取得 OtherData（僅當 recordType 為 Other 時有效）
  OtherData get otherData => recordType is RecordTypeOther
      ? (recordType as RecordTypeOther).data
      : OtherData();

  String get note => otherData.note;
  double get otherAmount => otherData.amount;

  // ============ copyWith ============

  AddRecordState copyWith({
    RecordType? recordType,
    AddRecordStatus? status,
    String? errorMessage,
    VehicleRecord? createdRecord,
    bool? isAmountManuallyEdited,
    SpeedUnit? speedUnit,
  }) {
    return AddRecordState(
      recordType: recordType ?? this.recordType,
      status: status ?? AddRecordStatus.valid,
      errorMessage: errorMessage,
      createdRecord: createdRecord ?? this.createdRecord,
      isAmountManuallyEdited:
          isAmountManuallyEdited ?? this.isAmountManuallyEdited,
      speedUnit: speedUnit ?? this.speedUnit,
    );
  }

  /// 更新共用欄位（date, km）
  AddRecordState copyWithCommonFields({DateTime? date, int? km}) {
    final newDate = date ?? this.date;
    final newKm = km ?? this.km;

    final RecordType newType = switch (recordType) {
      RecordTypeFuel(:final data) => RecordTypeFuel(
        data: data,
        recordDate: newDate,
        odometer: newKm,
      ),
      RecordTypeMaintenance(:final data) => RecordTypeMaintenance(
        data: data,
        recordDate: newDate,
        odometer: newKm,
      ),
      RecordTypeOther(:final data) => RecordTypeOther(
        data: data,
        recordDate: newDate,
        odometer: newKm,
      ),
    };

    return copyWith(recordType: newType);
  }

  /// 更新 FuelData 的便捷方法
  AddRecordState copyWithFuelData({
    FuelType? fuelType,
    double? fuelAmount,
    double? pricePerLiter,
    int? remainingFuel,
    bool? isAmountManuallyEdited,
  }) {
    final currentData = fuelData;
    final newData = currentData.copyWith(
      fuelType: fuelType,
      fuelAmount: fuelAmount,
      pricePerLiter: pricePerLiter,
      remainingFuel: remainingFuel,
    );
    return copyWith(
      recordType: RecordTypeFuel(data: newData, recordDate: date, odometer: km),
      isAmountManuallyEdited: isAmountManuallyEdited ?? false,
    );
  }

  /// 更新 MaintenanceData 列表的便捷方法
  AddRecordState copyWithMaintenanceEntries(List<MaintenanceData> entries) {
    return copyWith(
      recordType: RecordTypeMaintenance(
        data: entries,
        recordDate: date,
        odometer: km,
      ),
    );
  }

  /// 更新 OtherData 的便捷方法
  AddRecordState copyWithOtherData({double? amount, String? note}) {
    final currentData = otherData;
    final newData = currentData.copyWith(amount: amount, note: note);
    return copyWith(
      recordType: RecordTypeOther(
        data: newData,
        recordDate: date,
        odometer: km,
      ),
    );
  }

  @override
  List<Object?> get props => [
    recordType,
    status,
    errorMessage,
    createdRecord,
    isAmountManuallyEdited,
    speedUnit,
  ];
}
