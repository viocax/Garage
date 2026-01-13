import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';

/// 抽象的記錄提供器接口，用於測試時注入
abstract class IRecordsProvider {
  Future<List<VehicleRecord>> loadRecords();
}

/// 實際的記錄提供器，使用 Isar Vehicle
class VehicleRecordsProvider implements IRecordsProvider {
  final Vehicle vehicle;

  VehicleRecordsProvider(this.vehicle);

  @override
  Future<List<VehicleRecord>> loadRecords() async {
    await vehicle.records.load();
    return vehicle.records.toList();
  }
}
