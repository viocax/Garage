import 'dart:math';

import 'vehicle_record.dart';
import 'package:garage/screen/speed/speedCamera/widgets/vehicle_picker_dialog.dart';

class Vehicle implements PickerOption {
  final String id;
  final String carName;
  final int currentMileage;
  final int maintenanceInterval; // e.g., every 5000km or 10000km
  final List<VehicleRecord> records;

  const Vehicle({
    required this.id,
    required this.carName,
    required this.currentMileage,
    required this.maintenanceInterval,
    this.records = const [],
  });

  // Empty vehicle for placeholder/initial state
  factory Vehicle.empty() {
    return const Vehicle(
      id: '',
      carName: '',
      currentMileage: 0,
      maintenanceInterval: 0,
      records: [],
    );
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
    double total = records.fold(0, (sum, record) => sum + record.cost);
    return '\$ ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get spentThisMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    // Filter records from this month
    final thisMonthRecords = records.where((record) {
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
  String getIdentifier() => id;

  @override
  String getTitle() => carName;

  @override
  String getSubTitle() => '$currentMileage km';
}
