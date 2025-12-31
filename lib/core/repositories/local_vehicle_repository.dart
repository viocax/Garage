import 'package:garage/core/core.dart';
import 'package:isar_community/isar.dart';

class LocalVehicleRepository implements VehicleRepository {
  final IsarService isarService = getIt.service.isarDB;
  List<Vehicle> _cacheList = [];

  @override
  Future<List<Vehicle>> loadVehicles() async {
    if (_cacheList.isNotEmpty) {
      return _cacheList;
    }
    final db = await isarService.isar;
    // Sort by order ascending (smaller order number comes first)
    final vehicles = await db.vehicles.where().sortByOrder().findAll();

    // Load the related records for each vehicle
    for (final vehicle in vehicles) {
      await vehicle.records.load();
    }
    _cacheList = vehicles;

    return vehicles;
  }

  /// 清空快取，強制下次重新從資料庫載入
  void _invalidateCache() {
    _cacheList = [];
  }

  @override
  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      final db = await isarService.isar;
      await db.writeTxn(() async {
        // Get all existing vehicles
        final existingVehicles = await db.vehicles.where().findAll();

        // Create clean vehicle instances without link state to avoid nested transactions
        final updatedVehicles = existingVehicles.map((v) {
          return Vehicle()
            ..id = v.id
            ..vehicleId = v.vehicleId
            ..carName = v.carName
            ..licensePlate = v.licensePlate
            ..currentKm = v.currentKm
            ..maintenanceIntervalKm = v.maintenanceIntervalKm
            ..kmToNextMaintenance = v.kmToNextMaintenance
            ..order = v.order + 1;
        }).toList();

        // Batch update all existing vehicles
        await db.vehicles.putAll(updatedVehicles);

        // Set new vehicle order to 0 (insert at beginning)
        vehicle.order = 0;
        await db.vehicles.put(vehicle);
      });
      _invalidateCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addRecord(String carId, VehicleRecord record) async {
    try {
      final db = await isarService.isar;

      // Find the vehicle by vehicleId
      final vehicle = await db.vehicles
          .filter()
          .vehicleIdEqualTo(carId)
          .findFirst();

      if (vehicle == null) {
        return false;
      }

      // Load records outside of transaction to avoid nested transaction error
      await vehicle.records.load();

      await db.writeTxn(() async {
        // Save the record
        await db.vehicleRecords.put(record);

        // Link the record to the vehicle
        vehicle.records.add(record);
        await vehicle.records.save();
      });

      _invalidateCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeVehicle(String vehicleId) async {
    try {
      final db = await isarService.isar;

      final vehicle = await db.vehicles
          .filter()
          .vehicleIdEqualTo(vehicleId)
          .findFirst();

      if (vehicle == null) {
        return false;
      }

      // Load records outside of transaction to avoid nested transaction error
      await vehicle.records.load();

      await db.writeTxn(() async {
        // Delete all related records
        for (final record in vehicle.records) {
          await db.vehicleRecords.delete(record.id);
        }

        // Delete the vehicle
        await db.vehicles.delete(vehicle.id);
      });

      _invalidateCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeRecords(String vehicleId, List<String> recordIds) async {
    try {
      final db = await isarService.isar;

      final vehicle = await db.vehicles
          .filter()
          .vehicleIdEqualTo(vehicleId)
          .findFirst();

      if (vehicle == null) {
        return false;
      }

      await db.writeTxn(() async {
        // Find and delete records by recordId
        for (final recordId in recordIds) {
          final record = await db.vehicleRecords
              .filter()
              .recordIdEqualTo(recordId)
              .findFirst();

          if (record != null) {
            await db.vehicleRecords.delete(record.id);
          }
        }
      });

      _invalidateCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateRecords(
    String vehicleId,
    List<VehicleRecord> records,
  ) async {
    try {
      final db = await isarService.isar;

      await db.writeTxn(() async {
        for (final record in records) {
          await db.vehicleRecords.put(record);
        }
      });

      _invalidateCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      final db = await isarService.isar;

      await db.writeTxn(() async {
        await db.vehicles.put(vehicle);
      });

      _invalidateCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> saveEdit() async {
    // In this implementation, changes are saved immediately
    // This method can be used for batch operations if needed
    _invalidateCache();
    return true;
  }
}
