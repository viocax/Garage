import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

class LocalVehicleRepository implements VehicleRepository {

  @override
  Future<List<Vehicle>> loadVehicles() {
    throw UnimplementedError();
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