import 'package:garage/core/core.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
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
    final vehicles = await db.vehicles.where().findAll();

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

      await db.writeTxn(() async {
        // Save the record
        await db.vehicleRecords.put(record);

        // Link the record to the vehicle
        await vehicle.records.load();
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

      await db.writeTxn(() async {
        // Load and delete all related records
        await vehicle.records.load();
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
  Future<bool> updateRecords(String vehicleId, List<VehicleRecord> records) async {
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
