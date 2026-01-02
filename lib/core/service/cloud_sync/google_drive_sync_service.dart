import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:garage/core/core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleDriveSyncService implements CloudSyncService {
  static const _backupFileName = 'garage_backup.json';
  static const _lastSyncKey = 'google_drive_last_sync';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  drive.DriveApi? _driveApi;

  @override
  CloudProvider get provider => CloudProvider.googleDrive;

  @override
  Future<bool> isAvailable() async {
    // Google Drive is available on both iOS and Android
    return true;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _googleSignIn.currentUser != null ||
        await _googleSignIn.isSignedIn();
  }

  @override
  Future<CloudSyncResult> authenticate() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return CloudSyncResult.failure('登入已取消');
      }

      // Initialize Drive API
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        return CloudSyncResult.failure('無法取得認證');
      }
      _driveApi = drive.DriveApi(httpClient);

      return CloudSyncResult.success();
    } catch (e) {
      return CloudSyncResult.failure('登入失敗：${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _driveApi = null;
  }

  @override
  Future<CloudSyncResult> uploadData() async {
    try {
      // Ensure we have a valid Drive API client
      if (!await _ensureDriveApi()) {
        return CloudSyncResult.failure('請先登入 Google 帳號');
      }

      // Get app data to export
      final exportData = await _getExportData();
      if (exportData == null) {
        return CloudSyncResult.failure('無法取得匯出資料');
      }

      // Check if backup file already exists
      final existingFileId = await _findBackupFile();

      // Create or update the backup file
      final media = drive.Media(
        Stream.value(utf8.encode(exportData)),
        utf8.encode(exportData).length,
      );

      if (existingFileId != null) {
        // Update existing file
        await _driveApi!.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new file in app data folder
        final driveFile = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await _driveApi!.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      // Save sync time
      final syncTime = DateTime.now();
      await _saveLastSyncTime(syncTime);

      return CloudSyncResult.success(syncTime: syncTime);
    } catch (e) {
      return CloudSyncResult.failure('上傳失敗：${e.toString()}');
    }
  }

  @override
  Future<CloudSyncResult> downloadData() async {
    try {
      // Ensure we have a valid Drive API client
      if (!await _ensureDriveApi()) {
        return CloudSyncResult.failure('請先登入 Google 帳號');
      }

      // Find the backup file
      final fileId = await _findBackupFile();
      if (fileId == null) {
        return CloudSyncResult.failure('雲端沒有備份資料');
      }

      // Download the file content
      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }
      final jsonString = utf8.decode(bytes);

      // Restore the data
      final success = await _restoreData(jsonString);
      if (!success) {
        return CloudSyncResult.failure('還原資料失敗');
      }

      // Save sync time
      final syncTime = DateTime.now();
      await _saveLastSyncTime(syncTime);

      return CloudSyncResult.success(syncTime: syncTime);
    } catch (e) {
      return CloudSyncResult.failure('下載失敗：${e.toString()}');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Private helper methods

  Future<bool> _ensureDriveApi() async {
    if (_driveApi != null) return true;

    // Try to restore from silent sign-in
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return false;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return false;

      _driveApi = drive.DriveApi(httpClient);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _findBackupFile() async {
    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName'",
        $fields: 'files(id, name)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return null;
      }

      return fileList.files!.first.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  /// Export app data to JSON string
  Future<String?> _getExportData() async {
    try {
      final isar = await getIt.service.isarDB.isar;

      // 取得所有車輛
      final vehicles = await isar.vehicles.where().findAll();

      // 取得所有記錄
      final records = await isar.vehicleRecords.where().findAll();

      debugPrint('CloudSync: 匯出 ${vehicles.length} 輛車, ${records.length} 筆記錄');

      final exportData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'vehicles': vehicles.map((v) => _vehicleToJson(v)).toList(),
        'records': records.map((r) => _recordToJson(r)).toList(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('CloudSync: 匯出失敗 - $e');
      return null;
    }
  }

  /// 將 Vehicle 轉換為 JSON Map
  Map<String, dynamic> _vehicleToJson(Vehicle vehicle) {
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
  Map<String, dynamic> _recordToJson(VehicleRecord record) {
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

  /// Restore app data from JSON string
  Future<bool> _restoreData(String jsonString) async {
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

      debugPrint('CloudSync: 還原 ${vehiclesJson.length} 輛車, ${recordsJson.length} 筆記錄');

      await isar.writeTxn(() async {
        // 清空現有資料
        await isar.vehicles.clear();
        await isar.vehicleRecords.clear();

        // 還原車輛
        final vehicles = <Vehicle>[];
        for (final vJson in vehiclesJson) {
          final vehicle = _vehicleFromJson(vJson as Map<String, dynamic>);
          vehicles.add(vehicle);
        }
        await isar.vehicles.putAll(vehicles);

        // 還原記錄
        final records = <VehicleRecord>[];
        for (final rJson in recordsJson) {
          final record = _recordFromJson(rJson as Map<String, dynamic>);
          records.add(record);
        }
        await isar.vehicleRecords.putAll(records);

        // 重建 IsarLinks 關聯
        for (final vehicle in vehicles) {
          final vehicleRecords = records
              .where((r) => r.vehicleId == vehicle.vehicleId)
              .toList();
          vehicle.records.addAll(vehicleRecords);
          await vehicle.records.save();
        }
      });

      debugPrint('CloudSync: 還原完成');
      return true;
    } catch (e) {
      debugPrint('CloudSync: 還原失敗 - $e');
      return false;
    }
  }

  /// 從 JSON Map 建立 Vehicle
  Vehicle _vehicleFromJson(Map<String, dynamic> json) {
    return Vehicle()
      ..vehicleId = json['vehicleId'] as String? ?? ''
      ..carName = json['carName'] as String? ?? ''
      ..licensePlate = json['licensePlate'] as String? ?? ''
      ..currentKm = json['currentKm'] as int? ?? 0
      ..maintenanceIntervalKm = json['maintenanceIntervalKm'] as int? ?? 5000
      ..kmToNextMaintenance = json['kmToNextMaintenance'] as int? ?? 5000
      ..order = json['order'] as int? ?? 0;
  }

  /// 從 JSON Map 建立 VehicleRecord
  VehicleRecord _recordFromJson(Map<String, dynamic> json) {
    final record = VehicleRecord()
      ..recordId = json['recordId'] as String? ?? ''
      ..vehicleId = json['vehicleId'] as String? ?? ''
      ..typeName = json['typeName'] as String? ?? 'other'
      ..title = json['title'] as String? ?? ''
      ..date = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now()
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
