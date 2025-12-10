import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'vehicle_record.g.dart';

enum RecordType {
  fuel,
  maintenance,
  modification,
  other;

  String get label {
    switch (this) {
      case RecordType.fuel:
        return '加油';
      case RecordType.maintenance:
        return '保養';
      case RecordType.modification:
        return '改裝';
      case RecordType.other:
        return '其他';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.fuel:
        return Icons.local_gas_station;
      case RecordType.maintenance:
        return Icons.build;
      case RecordType.modification:
        return Icons.settings;
      case RecordType.other:
        return Icons.receipt;
    }
  }

  Color get color {
    switch (this) {
      case RecordType.fuel:
        return const Color(0xFFD9923B); // Orange
      case RecordType.maintenance:
        return const Color(0xFF7A8A99); // Grey Blue
      case RecordType.modification:
        return const Color(0xFFD64045); // Red
      case RecordType.other:
        return const Color(0xFF8E8E93); // Grey
    }
  }
}

@collection
class VehicleRecord {
  static const _uuid = Uuid();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String recordId;

  @Enumerated(EnumType.name)
  late RecordType type;

  late String title;

  @Index()
  late DateTime date;

  late double cost;

  @Index()
  late int mileage;

  String? notes;

  VehicleRecord();

  /// Factory constructor 用於創建 VehicleRecord
  /// 如果不提供 recordId，會自動生成 UUID
  factory VehicleRecord.create({
    String? recordId,
    required RecordType type,
    required String title,
    required DateTime date,
    required double cost,
    required int mileage,
    String? notes,
  }) {
    return VehicleRecord()
      ..recordId = recordId ?? _uuid.v4()
      ..type = type
      ..title = title
      ..date = date
      ..cost = cost
      ..mileage = mileage
      ..notes = notes;
  }

  // Helper to format cost
  String get formattedCost =>
      '\$${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  // Helper to format mileage
  String get formattedMileage =>
      '${mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km';
}
