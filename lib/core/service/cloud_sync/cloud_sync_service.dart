import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:garage/core/core.dart';
import 'package:isar_community/isar.dart';

/// Cloud sync result with status and optional error
class CloudSyncResult {
  final bool success;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const CloudSyncResult({
    required this.success,
    this.errorMessage,
    this.lastSyncTime,
  });

  factory CloudSyncResult.success({DateTime? syncTime}) => CloudSyncResult(
        success: true,
        lastSyncTime: syncTime ?? DateTime.now(),
      );

  factory CloudSyncResult.failure(String message) => CloudSyncResult(
        success: false,
        errorMessage: message,
      );
}

/// Cloud provider types
enum CloudProvider {
  iCloud,
  googleDrive;

  String get displayName {
    switch (this) {
      case CloudProvider.iCloud:
        return 'iCloud';
      case CloudProvider.googleDrive:
        return 'Google Drive';
    }
  }
}

/// Abstract interface for cloud sync operations
abstract class CloudSyncService {
  /// Get the provider type
  CloudProvider get provider;

  /// Check if the provider is available on this platform
  Future<bool> isAvailable();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Authenticate with the cloud provider
  Future<CloudSyncResult> authenticate();

  /// Sign out from the cloud provider
  Future<void> signOut();

  /// Upload all data to cloud
  Future<CloudSyncResult> uploadData();

  /// Download and restore data from cloud
  Future<CloudSyncResult> downloadData();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();

  /// Delete backup data from cloud
  Future<CloudSyncResult> deleteBackup();
}

/// Mixin containing shared data serialization and restore logic
/// for cloud sync services
mixin CloudSyncDataMixin {
  /// Export app data to JSON string
  Future<String?> getExportData() async {
    try {
      final isar = await getIt.service.isarDB.isar;

      // 取得所有車輛
      final vehicles = await isar.vehicles.where().findAll();

      // 取得所有記錄
      final records = await isar.vehicleRecords.where().findAll();

      debugPrint(
          'CloudSync: 匯出 ${vehicles.length} 輛車, ${records.length} 筆記錄');

      final exportData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'vehicles': vehicles.map((v) => vehicleToJson(v)).toList(),
        'records': records.map((r) => recordToJson(r)).toList(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('CloudSync: 匯出失敗 - $e');
      return null;
    }
  }

  /// Restore app data from JSON string
  Future<bool> restoreData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // 驗證版本
      final version = data['version'] as int?;
      if (version == null || version > 1) {
        debugPrint('CloudSync: 不支援的備份版本 $version');
        return false;
      }

      final isar = await getIt.service.isarDB.isar;

      // 解析車輛資料
      final vehiclesJson = data['vehicles'] as List<dynamic>? ?? [];
      final recordsJson = data['records'] as List<dynamic>? ?? [];

      debugPrint(
          'CloudSync: 還原 ${vehiclesJson.length} 輛車, ${recordsJson.length} 筆記錄');

      await isar.writeTxn(() async {
        // 清空現有資料
        await isar.vehicles.clear();
        await isar.vehicleRecords.clear();

        // 還原車輛
        for (final vJson in vehiclesJson) {
          final vehicle = vehicleFromJson(vJson as Map<String, dynamic>);
          await isar.vehicles.put(vehicle);
        }

        // 還原記錄
        for (final rJson in recordsJson) {
          final record = recordFromJson(rJson as Map<String, dynamic>);
          await isar.vehicleRecords.put(record);
        }
      });

      // 在事務外重新查詢並建立 IsarLinks 關聯
      // 這樣可以確保物件有正確的 Isar id
      final vehicles = await isar.vehicles.where().findAll();
      final records = await isar.vehicleRecords.where().findAll();

      debugPrint(
          'CloudSync: 查詢到 ${vehicles.length} 輛車, ${records.length} 筆記錄');

      await isar.writeTxn(() async {
        for (final vehicle in vehicles) {
          final vehicleRecords =
              records.where((r) => r.vehicleId == vehicle.vehicleId).toList();
          vehicle.records.addAll(vehicleRecords);
          await vehicle.records.save();
        }
      });

      debugPrint('CloudSync: 還原完成，已建立 ${vehicles.length} 輛車的關聯');
      return true;
    } catch (e) {
      debugPrint('CloudSync: 還原失敗 - $e');
      return false;
    }
  }

  /// 將 Vehicle 轉換為 JSON Map
  Map<String, dynamic> vehicleToJson(Vehicle vehicle) {
    return {
      'vehicleId': vehicle.vehicleId,
      'carName': vehicle.carName,
      'licensePlate': vehicle.licensePlate,
      'currentKm': vehicle.currentKm,
      'maintenanceIntervalKm': vehicle.maintenanceIntervalKm,
      'kmToNextMaintenance': vehicle.kmToNextMaintenance,
      'order': vehicle.order,
    };
  }

  /// 將 VehicleRecord 轉換為 JSON Map
  Map<String, dynamic> recordToJson(VehicleRecord record) {
    final json = <String, dynamic>{
      'recordId': record.recordId,
      'vehicleId': record.vehicleId,
      'typeName': record.typeName,
      'title': record.title,
      'date': record.date.toIso8601String(),
      'cost': record.cost,
      'km': record.km,
      'notes': record.notes,
    };

    // 根據類型加入對應的資料
    if (record.fuelData != null) {
      json['fuelData'] = {
        'fuelType': record.fuelData!.fuelType.name,
        'fuelAmount': record.fuelData!.fuelAmount,
        'pricePerLiter': record.fuelData!.pricePerLiter,
        'remainingFuel': record.fuelData!.remainingFuel,
      };
    }

    if (record.maintenanceData != null) {
      json['maintenanceData'] = record.maintenanceData!
          .map((m) => {
                'item': m.item,
                'amount': m.amount,
                'nextMaintenanceKm': m.nextMaintenanceKm,
                'note': m.note,
              })
          .toList();
    }

    if (record.otherData != null) {
      json['otherData'] = {
        'amount': record.otherData!.amount,
        'note': record.otherData!.note,
      };
    }

    return json;
  }

  /// 從 JSON Map 建立 Vehicle
  Vehicle vehicleFromJson(Map<String, dynamic> json) {
    return Vehicle()
      ..vehicleId = json['vehicleId'] as String? ?? ''
      ..carName = json['carName'] as String? ?? ''
      ..licensePlate = json['licensePlate'] as String? ?? ''
      ..currentKm = json['currentKm'] as int? ?? 0
      ..maintenanceIntervalKm = json['maintenanceIntervalKm'] as int? ?? 5000
      ..kmToNextMaintenance = json['kmToNextMaintenance'] as int? ?? 5000
      ..order = json['order'] as int? ?? 0;
  }

  /// 清除本地所有資料（車輛和記錄）
  Future<bool> clearLocalData() async {
    try {
      final isar = await getIt.service.isarDB.isar;

      await isar.writeTxn(() async {
        await isar.vehicles.clear();
        await isar.vehicleRecords.clear();
      });

      debugPrint('CloudSync: 已清除本地所有資料');
      return true;
    } catch (e) {
      debugPrint('CloudSync: 清除本地資料失敗 - $e');
      return false;
    }
  }

  /// 從 JSON Map 建立 VehicleRecord
  VehicleRecord recordFromJson(Map<String, dynamic> json) {
    final record = VehicleRecord()
      ..recordId = json['recordId'] as String? ?? ''
      ..vehicleId = json['vehicleId'] as String? ?? ''
      ..typeName = json['typeName'] as String? ?? 'other'
      ..title = json['title'] as String? ?? ''
      ..date =
          DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now()
      ..cost = (json['cost'] as num?)?.toDouble() ?? 0
      ..km = json['km'] as int? ?? 0
      ..notes = json['notes'] as String?;

    // 還原加油資料
    final fuelJson = json['fuelData'] as Map<String, dynamic>?;
    if (fuelJson != null) {
      record.fuelData = FuelData(
        fuelType: FuelType.values.firstWhere(
          (e) => e.name == fuelJson['fuelType'],
          orElse: () => FuelType.octane95,
        ),
        fuelAmount: (fuelJson['fuelAmount'] as num?)?.toDouble() ?? 0,
        pricePerLiter: (fuelJson['pricePerLiter'] as num?)?.toDouble() ?? 0,
        remainingFuel: fuelJson['remainingFuel'] as int? ?? 90,
      );
    }

    // 還原保養資料
    final maintenanceJson = json['maintenanceData'] as List<dynamic>?;
    if (maintenanceJson != null) {
      record.maintenanceData = maintenanceJson
          .map((m) => MaintenanceData(
                item: m['item'] as String? ?? '',
                amount: (m['amount'] as num?)?.toDouble() ?? 0,
                nextMaintenanceKm: m['nextMaintenanceKm'] as int?,
                note: m['note'] as String? ?? '',
              ))
          .toList();
    }

    // 還原其他資料
    final otherJson = json['otherData'] as Map<String, dynamic>?;
    if (otherJson != null) {
      record.otherData = OtherData(
        amount: (otherJson['amount'] as num?)?.toDouble() ?? 0,
        note: otherJson['note'] as String? ?? '',
      );
    }

    return record;
  }
}
