import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import 'vehicle_record.dart';
import 'package:garage/screen/speed/speedCamera/widgets/vehicle_picker_dialog.dart';

part 'vehicle.g.dart';

@collection
class Vehicle implements PickerOption {
  static const _uuid = Uuid();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String vehicleId = '';
  String carName = '';
  String licensePlate = ''; // 車牌號碼
  int currentKm = 0;
  int maintenanceIntervalKm = 5000; // e.g., every 5000km or 10000km
  int kmToNextMaintenance = 5000;
  int order = 0; // 排序順序，數字越小越前面

  final records = IsarLinks<VehicleRecord>();

  Vehicle();

  /// Factory constructor 用於創建 Vehicle
  /// 如果不提供 vehicleId，會自動生成 UUID
  factory Vehicle.create({
    String? vehicleId,
    required String carName,
    String licensePlate = '',
    required int currentKm,
    required int maintenanceIntervalKm,
    order = 0,
  }) {
    return Vehicle()
      ..vehicleId = vehicleId ?? _uuid.v4()
      ..carName = carName
      ..licensePlate = licensePlate
      ..currentKm = currentKm
      ..maintenanceIntervalKm = maintenanceIntervalKm
      ..kmToNextMaintenance = currentKm + maintenanceIntervalKm
      ..order = order;
  }

  // Empty vehicle for placeholder/initial state
  factory Vehicle.empty() {
    return Vehicle()
      ..vehicleId = ''
      ..carName = ''
      ..licensePlate = ''
      ..currentKm = 0
      ..maintenanceIntervalKm = 0
      ..kmToNextMaintenance = 0
      ..order = 0;
  }

  // Calculate maintenance health percentage (1.0 = fresh, 0.0 = due)
  double get maintenanceHealth {
    if (maintenanceIntervalKm <= 0) return 1.0;
    return max(0.0, min(1.0, remindKm / maintenanceIntervalKm));
  }

  int get remindKm {
    return max(kmToNextMaintenance - currentKm, 0);
  }

  // Helper to get total spent from records
  String get totalSpent {
    final recordsList = records.toList();
    double total = recordsList.fold(0, (sum, record) => sum + record.cost);
    return '\$ ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get spentThisMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    // Filter records from this month
    final recordsList = records.toList();
    final thisMonthRecords = recordsList.where((record) {
      return record.date.isAfter(thisMonth.subtract(const Duration(days: 1))) &&
          record.date.isBefore(nextMonth);
    });

    // Calculate total spent this month
    final total = thisMonthRecords.fold<double>(
      0,
      (sum, record) => sum + record.cost,
    );

    // Format the result
    final formattedTotal = total
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return '\$$formattedTotal';
  }

  // PickerOption implementation
  @override
  String getIdentifier() => vehicleId;

  @override
  String getTitle() => carName;

  @override
  String getSubTitle() => '$currentKm km';
}
