import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'vehicle_record.g.dart';

/// 燃油種類
enum FuelType {
  octane92,
  octane95,
  octane98,
  diesel;

  String get label {
    switch (this) {
      case FuelType.octane92:
        return '92';
      case FuelType.octane95:
        return '95';
      case FuelType.octane98:
        return '98';
      case FuelType.diesel:
        return '柴油';
    }
  }
}

/// 加油記錄專屬資料（embedded object）
@embedded
class FuelData {
  @Enumerated(EnumType.name)
  FuelType fuelType;

  double fuelAmount; // 加油量（公升）

  double pricePerLiter; // 每公升油價

  int remainingFuel; // 剩餘油量百分比（50-100）

  FuelData({
    this.fuelType = FuelType.octane95,
    this.fuelAmount = 0,
    this.pricePerLiter = 0,
    this.remainingFuel = 90,
  });

  FuelData copyWith({
    FuelType? fuelType,
    double? fuelAmount,
    double? pricePerLiter,
    int? remainingFuel,
  }) {
    return FuelData(
      fuelType: fuelType ?? this.fuelType,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      remainingFuel: remainingFuel ?? this.remainingFuel,
    );
  }

  /// 計算總金額
  double get calculatedCost => fuelAmount * pricePerLiter;

  /// 格式化顯示
  String get formattedSummary {
    final amount = '${fuelAmount.toStringAsFixed(1)}L';
    switch (fuelType) {
      case FuelType.diesel:
        return '柴油  $amount';
      default:
        return '無鉛${fuelType.label}  $amount';
    }
  }
    
}

/// 保養項目資料（embedded object）
@embedded
class MaintenanceData {
  String item; // 保養項目名稱
  double amount; // 金額
  int? nextMaintenanceKm; // 下次保養里程
  String note; // 備註

  MaintenanceData({
    this.item = '',
    this.amount = 0,
    this.nextMaintenanceKm,
    this.note = '',
  });

  MaintenanceData copyWith({
    String? item,
    double? amount,
    int? nextMaintenanceKm,
    String? note,
  }) {
    return MaintenanceData(
      item: item ?? this.item,
      amount: amount ?? this.amount,
      nextMaintenanceKm: nextMaintenanceKm ?? this.nextMaintenanceKm,
      note: note ?? this.note,
    );
  }
}

/// 其他記錄專屬資料（embedded object）
@embedded
class OtherData {
  double amount; // 金額
  String note; // 備註

  OtherData({
    this.amount = 0,
    this.note = '',
  });

  OtherData copyWith({
    double? amount,
    String? note,
  }) {
    return OtherData(
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}

/// Sealed class for record types with associated data
sealed class RecordType {
  final DateTime recordDate;
  final int odometer;

  const RecordType({
    required this.recordDate,
    required this.odometer,
  });

  String get label;
  IconData get icon;
  Color get color;
  String get typeName;

  /// 驗證資料是否有效，回傳 null 表示有效，否則回傳錯誤訊息
  String? get validationError;

  static RecordType fromTypeName(
    String typeName, {
    required DateTime recordDate,
    required int odometer,
    FuelData? fuelData,
    List<MaintenanceData>? maintenanceData,
    OtherData? otherData,
  }) {
    switch (typeName) {
      case 'fuel':
        return RecordTypeFuel(
          data: fuelData ?? FuelData(),
          recordDate: recordDate,
          odometer: odometer,
        );
      case 'maintenance':
        return RecordTypeMaintenance(
          data: maintenanceData ?? [],
          recordDate: recordDate,
          odometer: odometer,
        );
      case 'other':
      default:
        return RecordTypeOther(
          data: otherData ?? OtherData(),
          recordDate: recordDate,
          odometer: odometer,
        );
    }
  }
}

class RecordTypeFuel extends RecordType {
  final FuelData data;

  const RecordTypeFuel({
    required this.data,
    required super.recordDate,
    required super.odometer,
  });

  @override
  String get label => '加油';

  @override
  IconData get icon => Icons.local_gas_station;

  @override
  Color get color => const Color(0xFFD9923B); // Orange

  @override
  String get typeName => 'fuel';

  @override
  String? get validationError {
    if (data.fuelAmount <= 0) {
      return '請輸入有效的加油量';
    }
    return null;
  }
}

class RecordTypeMaintenance extends RecordType {
  final List<MaintenanceData> data;

  const RecordTypeMaintenance({
    required this.data,
    required super.recordDate,
    required super.odometer,
  });

  @override
  String get label => '保養';

  @override
  IconData get icon => Icons.build;

  @override
  Color get color => const Color(0xFF7A8A99); // Grey Blue

  @override
  String get typeName => 'maintenance';

  /// 取得有效的保養項目
  List<MaintenanceData> get validEntries =>
      data.where((e) => e.item.trim().isNotEmpty).toList();

  /// 計算總金額
  double get totalAmount => validEntries.fold(0, (sum, e) => sum + e.amount);

  @override
  String? get validationError {
    if (validEntries.isEmpty) {
      return '請至少輸入一個保養項目';
    }
    return null;
  }
}

class RecordTypeOther extends RecordType {
  final OtherData data;

  const RecordTypeOther({
    required this.data,
    required super.recordDate,
    required super.odometer,
  });

  @override
  String get label => '其他';

  @override
  IconData get icon => Icons.receipt;

  @override
  Color get color => const Color(0xFF8E8E93); // Grey

  @override
  String get typeName => 'other';

  @override
  String? get validationError => null; // 其他類別無特殊驗證
}

@collection
class VehicleRecord {
  static const _uuid = Uuid();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String recordId;

  /// 記錄類型名稱（fuel, maintenance, other）
  @Index()
  late String typeName;

  late String title;

  @Index()
  late DateTime date;

  late double cost;

  @Index()
  late int km;

  String? notes;

  /// 加油記錄專屬資料（僅當 typeName == 'fuel' 時使用）
  FuelData? fuelData;

  /// 保養記錄專屬資料（僅當 typeName == 'maintenance' 時使用）
  List<MaintenanceData>? maintenanceData;

  /// 其他記錄專屬資料（僅當 typeName == 'other' 時使用）
  OtherData? otherData;

  VehicleRecord();

  /// 取得 RecordType sealed class
  @ignore
  RecordType get type => RecordType.fromTypeName(
        typeName,
        recordDate: date,
        odometer: km,
        fuelData: fuelData,
        maintenanceData: maintenanceData,
        otherData: otherData,
      );

  /// Factory constructor 用於創建 VehicleRecord
  /// 如果不提供 recordId，會自動生成 UUID
  factory VehicleRecord.create({
    String? recordId,
    required RecordType type,
    required String title,
    required DateTime date,
    required double cost,
    required int km,
    String? notes,
  }) {
    final record = VehicleRecord()
      ..recordId = recordId ?? _uuid.v4()
      ..typeName = type.typeName
      ..title = title
      ..date = date
      ..cost = cost
      ..km = km
      ..notes = notes;

    // 根據類型設置對應的資料
    switch (type) {
      case RecordTypeFuel(:final data):
        record.fuelData = data;
      case RecordTypeMaintenance(:final data):
        record.maintenanceData = data;
      case RecordTypeOther(:final data):
        record.otherData = data;
    }

    return record;
  }

  // Helper to format cost
  String get formattedCost =>
      '\$${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  // Helper to format km
  String get formattedKm =>
      '${km.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km';
}
