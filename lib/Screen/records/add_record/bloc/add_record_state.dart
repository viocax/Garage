import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle_record.dart';

enum AddRecordStatus { initial, valid, submitting, success, failure }

class AddRecordState extends Equatable {
  final RecordType recordType;
  final double amount; // 用於加油、其他類型
  final DateTime date;
  final int km;
  final String note; // 用於其他類型
  final AddRecordStatus status;
  final String? errorMessage;
  final List<VehicleRecord> createdRecords;

  // 保養相關狀態 - 支援批次新增
  final List<MaintenanceData> maintenanceEntries;

  // 加油相關狀態
  final FuelType fuelType;
  final double fuelAmount; // 加油量（公升）
  final double pricePerLiter; // 每公升油價
  final int remainingFuel; // 剩餘油量百分比
  final bool isAmountManuallyEdited; // 追蹤金額是否被手動編輯

  AddRecordState({
    RecordType? recordType,
    this.amount = 0,
    required this.date,
    this.km = 0,
    this.note = '',
    this.status = AddRecordStatus.initial,
    this.errorMessage,
    this.createdRecords = const [],
    // 保養相關預設值
    this.maintenanceEntries = const [],
    // 加油相關預設值
    this.fuelType = FuelType.octane95,
    this.fuelAmount = 0,
    this.pricePerLiter = 0,
    this.remainingFuel = 90,
    this.isAmountManuallyEdited = false,
  }) : recordType = recordType ?? RecordTypeMaintenance(MaintenanceData());

  /// 計算保養項目總金額
  double get totalMaintenanceAmount =>
      maintenanceEntries.fold(0, (sum, entry) => sum + entry.amount);

  AddRecordState copyWith({
    RecordType? recordType,
    double? amount,
    DateTime? date,
    int? km,
    String? note,
    AddRecordStatus? status,
    String? errorMessage,
    List<VehicleRecord>? createdRecords,
    // 保養相關
    List<MaintenanceData>? maintenanceEntries,
    // 加油相關
    FuelType? fuelType,
    double? fuelAmount,
    double? pricePerLiter,
    int? remainingFuel,
    bool? isAmountManuallyEdited,
  }) {
    return AddRecordState(
      recordType: recordType ?? this.recordType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      km: km ?? this.km,
      note: note ?? this.note,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdRecords: createdRecords ?? this.createdRecords,
      // 保養相關
      maintenanceEntries: maintenanceEntries ?? this.maintenanceEntries,
      // 加油相關
      fuelType: fuelType ?? this.fuelType,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      remainingFuel: remainingFuel ?? this.remainingFuel,
      isAmountManuallyEdited:
          isAmountManuallyEdited ?? this.isAmountManuallyEdited,
    );
  }

  @override
  List<Object?> get props => [
    recordType,
    amount,
    date,
    km,
    note,
    status,
    errorMessage,
    createdRecords,
    // 保養相關
    maintenanceEntries,
    // 加油相關
    fuelType,
    fuelAmount,
    pricePerLiter,
    remainingFuel,
    isAmountManuallyEdited,
  ];
}
