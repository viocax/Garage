import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';

/// 車輛儲存庫介面
abstract class VehicleRepository {
  /// 載入所有車輛
  Future<List<Vehicle>> loadVehicles();

  /// 新增車輛
  Future<bool> addVehicle(Vehicle vehicle);

  /// 根據車輛 ID 新增記錄
  Future<bool> addRecord(String carId, VehicleRecord record);

  /// 移除車輛
  Future<bool> removeVehicle(String vehicleId);

  /// 移除多筆記錄
  Future<bool> removeRecords(String vehicleId, List<String> recordIds);

  /// 更新多筆記錄
  Future<bool> updateRecords(String vehicleId, List<VehicleRecord> records);

  /// 更新車輛資訊
  Future<bool> updateVehicle(Vehicle vehicle);

  /// 儲存編輯（批次保存所有變更）
  Future<bool> saveEdit();

  /// 移除所有車輛及其記錄
  Future<bool> removeAll();
}
