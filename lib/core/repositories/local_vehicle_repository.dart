import 'package:garage/core/core.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:isar_community/isar.dart';

class LocalVehicleRepository implements VehicleRepository {
  final IsarService isarService = getIt.service.isarDB;

  @override
  Future<List<Vehicle>> loadVehicles() async {
    final db = await isarService.isar;
    final vehicles = await db.vehicles.where().findAll();

    // Load the related records for each vehicle
    for (final vehicle in vehicles) {
      await vehicle.records.load();
    }

    return vehicles;
  }

  @override
  Future<bool> addVehicle(Vehicle vehicle) {
    throw UnimplementedError();
  }

  @override
  Future<bool> addRecord(String carId, VehicleRecord record) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeVehicle(String vehicleId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeRecords(String vehicleId, List<String> recordIds) {
    throw UnimplementedError();
  }

  @override
  Future<bool> updateRecords(String vehicleId, List<VehicleRecord> records) {
    throw UnimplementedError();
  }

  @override
  Future<bool> updateVehicle(Vehicle vehicle) {
    throw UnimplementedError();
  }

  @override
  Future<bool> saveEdit() {
    throw UnimplementedError();
  }
}
