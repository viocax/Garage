import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/cloud_sync/icloud_sync_service.dart';
import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock implementations

class MockPlatformChecker implements PlatformChecker {
  bool _isIOS;
  bool _isAndroid;

  MockPlatformChecker({bool isIOS = false, bool isAndroid = false})
    : _isIOS = isIOS,
      _isAndroid = isAndroid;

  @override
  bool get isIOS => _isIOS;

  @override
  bool get isAndroid => _isAndroid;

  void setIOS(bool value) => _isIOS = value;
  void setAndroid(bool value) => _isAndroid = value;
}

class MockICloudStorageWrapper implements ICloudStorageWrapper {
  final List<ICloudFileInfo> _files = [];
  final Map<String, String> _fileContents = {};

  bool shouldFailOnGather = false;
  bool shouldFailOnUpload = false;
  bool shouldFailOnDownload = false;
  bool shouldFailOnDelete = false;

  String? lastUploadedFilePath;
  String? lastUploadedDestination;
  String? lastDownloadedRelativePath;
  String? lastDownloadedDestination;
  String? lastDeletedRelativePath;

  void reset() {
    _files.clear();
    _fileContents.clear();
    shouldFailOnGather = false;
    shouldFailOnUpload = false;
    shouldFailOnDownload = false;
    shouldFailOnDelete = false;
    lastUploadedFilePath = null;
    lastUploadedDestination = null;
    lastDownloadedRelativePath = null;
    lastDownloadedDestination = null;
    lastDeletedRelativePath = null;
  }

  void addFile(String relativePath, {String? content}) {
    _files.add(ICloudFileInfo(relativePath: relativePath));
    if (content != null) {
      _fileContents[relativePath] = content;
    }
  }

  bool hasFile(String relativePath) {
    return _files.any((f) => f.relativePath == relativePath);
  }

  @override
  Future<List<ICloudFileInfo>> gather({required String containerId}) async {
    if (shouldFailOnGather) {
      throw Exception('Mock gather failure');
    }
    return List.from(_files);
  }

  @override
  Future<void> upload({
    required String containerId,
    required String filePath,
    required String destinationRelativePath,
    void Function(double)? onProgress,
  }) async {
    if (shouldFailOnUpload) {
      throw Exception('Mock upload failure');
    }
    lastUploadedFilePath = filePath;
    lastUploadedDestination = destinationRelativePath;

    // Simulate reading file content
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      _fileContents[destinationRelativePath] = content;
    }

    // Add to files list if not exists
    if (!_files.any((f) => f.relativePath == destinationRelativePath)) {
      _files.add(ICloudFileInfo(relativePath: destinationRelativePath));
    }

    onProgress?.call(1.0);
  }

  @override
  Future<void> download({
    required String containerId,
    required String relativePath,
    required String destinationFilePath,
    void Function(double)? onProgress,
  }) async {
    if (shouldFailOnDownload) {
      throw Exception('Mock download failure');
    }
    lastDownloadedRelativePath = relativePath;
    lastDownloadedDestination = destinationFilePath;

    // Write content to destination file
    final content = _fileContents[relativePath];
    if (content != null) {
      final file = File(destinationFilePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    }

    onProgress?.call(1.0);
  }

  @override
  Future<void> delete({
    required String containerId,
    required String relativePath,
  }) async {
    if (shouldFailOnDelete) {
      throw Exception('Mock delete failure');
    }
    lastDeletedRelativePath = relativePath;
    _files.removeWhere((f) => f.relativePath == relativePath);
    _fileContents.remove(relativePath);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ICloudSyncService', () {
    late MockPlatformChecker mockPlatformChecker;
    late MockICloudStorageWrapper mockICloudStorage;
    late ICloudSyncService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockPlatformChecker = MockPlatformChecker();
      mockICloudStorage = MockICloudStorageWrapper();
      service = ICloudSyncService(
        platformChecker: mockPlatformChecker,
        iCloudStorage: mockICloudStorage,
      );
    });

    tearDown(() {
      mockICloudStorage.reset();
    });

    group('provider', () {
      test('should return iCloud', () {
        expect(service.provider, CloudProvider.iCloud);
      });
    });

    group('isAvailable', () {
      test('should return false when not on iOS', () async {
        mockPlatformChecker.setIOS(false);

        final result = await service.isAvailable();

        expect(result, isFalse);
      });

      test('should return true when on iOS and iCloud is accessible', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.shouldFailOnGather = false;

        final result = await service.isAvailable();

        expect(result, isTrue);
      });

      test('should return false when on iOS but iCloud gather fails', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.shouldFailOnGather = true;

        final result = await service.isAvailable();

        expect(result, isFalse);
      });
    });

    group('isAuthenticated', () {
      test('should return same as isAvailable', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.shouldFailOnGather = false;

        final isAuth = await service.isAuthenticated();
        final isAvail = await service.isAvailable();

        expect(isAuth, equals(isAvail));
      });
    });

    group('authenticate', () {
      test('should return failure when not on iOS', () async {
        mockPlatformChecker.setIOS(false);

        final result = await service.authenticate();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('iOS'));
      });

      test('should return success when on iOS and iCloud available', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.shouldFailOnGather = false;

        final result = await service.authenticate();

        expect(result.success, isTrue);
      });

      test(
        'should return failure when on iOS but iCloud not available',
        () async {
          mockPlatformChecker.setIOS(true);
          mockICloudStorage.shouldFailOnGather = true;

          final result = await service.authenticate();

          expect(result.success, isFalse);
          expect(result.errorMessage, contains('iCloud'));
        },
      );
    });

    group('signOut', () {
      test('should complete without error', () async {
        // iCloud sign out is no-op in code, just verify it doesn't throw
        await expectLater(service.signOut(), completes);
      });
    });

    group('getLastSyncTime', () {
      test('should return null when no sync time saved', () async {
        final result = await service.getLastSyncTime();
        expect(result, isNull);
      });

      test('should return saved sync time', () async {
        final prefs = await SharedPreferences.getInstance();
        final timestamp = DateTime(2026, 1, 14, 12, 0).millisecondsSinceEpoch;
        await prefs.setInt('icloud_last_sync', timestamp);

        final result = await service.getLastSyncTime();

        expect(result, isNotNull);
        expect(result!.year, 2026);
        expect(result.month, 1);
        expect(result.day, 14);
      });
    });

    group('deleteBackup', () {
      test('should return failure when iCloud not available', () async {
        mockPlatformChecker.setIOS(false);

        final result = await service.deleteBackup();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('不可用'));
      });

      test('should return failure when no backup exists', () async {
        mockPlatformChecker.setIOS(true);
        // No files in mockICloudStorage

        final result = await service.deleteBackup();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('沒有備份'));
      });

      test('should delete backup successfully', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.addFile('garage_backup.json');

        final result = await service.deleteBackup();

        expect(result.success, isTrue);
        expect(mockICloudStorage.hasFile('garage_backup.json'), isFalse);
        expect(mockICloudStorage.lastDeletedRelativePath, 'garage_backup.json');
      });

      test('should clear sync time after delete', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.addFile('garage_backup.json');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('icloud_last_sync', 12345);

        await service.deleteBackup();

        expect(prefs.getInt('icloud_last_sync'), isNull);
      });

      test('should return failure when delete fails', () async {
        mockPlatformChecker.setIOS(true);
        mockICloudStorage.addFile('garage_backup.json');
        mockICloudStorage.shouldFailOnDelete = true;

        final result = await service.deleteBackup();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('刪除失敗'));
      });
    });
  });
}
