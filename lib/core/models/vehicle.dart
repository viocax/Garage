import 'vehicle_record.dart';

class Vehicle {
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
    if (maintenanceInterval <= 0) return 1.0;
    return distanceToNextMaintenance / maintenanceInterval;
  }

  // Helper to get total spent from records
  double get totalSpent {
    return records.fold(0, (sum, record) => sum + record.cost);
  }
}
