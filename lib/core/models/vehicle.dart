import 'dart:math';

import 'package:isar/isar.dart';
import 'vehicle_record.dart';
import 'package:garage/screen/speed/speedCamera/widgets/vehicle_picker_dialog.dart';

part 'vehicle.g.dart';

@collection
class Vehicle implements PickerOption {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String vehicleId;

  late String carName;

  late int currentMileage;

  late int maintenanceInterval; // e.g., every 5000km or 10000km

  final records = IsarLinks<VehicleRecord>();

  Vehicle();

  /// Factory constructor 用於創建 Vehicle
  factory Vehicle.create({
    required String vehicleId,
    required String carName,
    required int currentMileage,
    required int maintenanceInterval,
  }) {
    return Vehicle()
      ..vehicleId = vehicleId
      ..carName = carName
      ..currentMileage = currentMileage
      ..maintenanceInterval = maintenanceInterval;
  }

  // Empty vehicle for placeholder/initial state
  factory Vehicle.empty() {
    return Vehicle()
      ..vehicleId = ''
      ..carName = ''
      ..currentMileage = 0
      ..maintenanceInterval = 0;
  }

  // Calculate distance to next maintenance
  // Assuming maintenance is needed when (currentMileage % maintenanceInterval) == 0
  // Or simply: remaining = interval - (current % interval)
  int get distanceToNextMaintenance {
    if (maintenanceInterval <= 0) return 0;
    final remainder = currentMileage % maintenanceInterval;
    return maintenanceInterval - remainder;
  }

  // Calculate maintenance health percentage (1.0 = fresh, 0.0 = due)
  double get maintenanceHealth {
    if (maintenanceInterval <= 0) return 0.0;
    return max(0.0, min(1.0, distanceToNextMaintenance / maintenanceInterval));
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
    final formattedTotal = total.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '本月新增 \$$formattedTotal';
  }

  // PickerOption implementation
  @override
  String getIdentifier() => vehicleId;

  @override
  String getTitle() => carName;

  @override
  String getSubTitle() => '$currentMileage km';
}
