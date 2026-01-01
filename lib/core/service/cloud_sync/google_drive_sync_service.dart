import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_sync_service.dart';

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
  /// TODO: Implement actual data export from Isar database
  Future<String?> _getExportData() async {
    try {
      // Placeholder: Export data from database
      // This should be replaced with actual Isar database export
      final exportData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'vehicles': [],
        'records': [],
        // Add more data collections as needed
      };

      return jsonEncode(exportData);
    } catch (e) {
      return null;
    }
  }

  /// Restore app data from JSON string
  /// TODO: Implement actual data import to Isar database
  Future<bool> _restoreData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as int?;
      if (version == null || version > 1) {
        return false;
      }

      // Placeholder: Import data to database
      // This should be replaced with actual Isar database import

      return true;
    } catch (e) {
      return false;
    }
  }
}
