import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/crashlytics_service.dart';

// Mock CrashlyticsWrapper
class MockCrashlyticsWrapper implements CrashlyticsWrapper {
  bool collectionEnabled = false;
  List<String> logs = [];
  List<Map<String, dynamic>> recordedErrors = [];
  String? userIdentifier;
  Map<String, Object> customKeys = {};
  bool crashCalled = false;
  FlutterErrorDetails? lastFlutterError;

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    lastFlutterError = details;
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    recordedErrors.add({
      'exception': exception,
      'stack': stack,
      'reason': reason,
      'fatal': fatal,
    });
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifier = identifier;
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  void crash() {
    crashCalled = true;
  }

  void reset() {
    collectionEnabled = false;
    logs.clear();
    recordedErrors.clear();
    userIdentifier = null;
    customKeys.clear();
    crashCalled = false;
    lastFlutterError = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrashlyticsService', () {
    late MockCrashlyticsWrapper mockCrashlytics;
    late CrashlyticsService service;

    setUp(() {
      mockCrashlytics = MockCrashlyticsWrapper();
      service = CrashlyticsService(crashlytics: mockCrashlytics);
    });

    tearDown(() {
      mockCrashlytics.reset();
    });

    group('initialize', () {
      test('should disable collection in debug mode', () async {
        await service.initialize();

        // kDebugMode is true in tests, so collection should be disabled
        expect(mockCrashlytics.collectionEnabled, isFalse);
      });
    });

    group('recordError', () {
      test('should record non-fatal error', () async {
        final exception = Exception('Test error');
        final stack = StackTrace.current;

        await service.recordError(exception, stack);

        expect(mockCrashlytics.recordedErrors.length, 1);
        expect(mockCrashlytics.recordedErrors.first['exception'], exception);
        expect(mockCrashlytics.recordedErrors.first['fatal'], false);
      });

      test('should record fatal error', () async {
        final exception = Exception('Fatal error');
        final stack = StackTrace.current;

        await service.recordError(exception, stack, fatal: true);

        expect(mockCrashlytics.recordedErrors.length, 1);
        expect(mockCrashlytics.recordedErrors.first['fatal'], true);
      });

      test('should record error with reason', () async {
        final exception = Exception('Error with reason');
        const reason = 'Network failure';

        await service.recordError(exception, null, reason: reason);

        expect(mockCrashlytics.recordedErrors.first['reason'], reason);
      });
    });

    group('log', () {
      test('should log message', () async {
        const message = 'Debug log message';

        await service.log(message);

        expect(mockCrashlytics.logs, contains(message));
      });

      test('should log multiple messages', () async {
        await service.log('Message 1');
        await service.log('Message 2');
        await service.log('Message 3');

        expect(mockCrashlytics.logs.length, 3);
      });
    });

    group('setUserIdentifier', () {
      test('should set user identifier', () async {
        const userId = 'user-123';

        await service.setUserIdentifier(userId);

        expect(mockCrashlytics.userIdentifier, userId);
      });
    });

    group('setCustomKey', () {
      test('should set string custom key', () async {
        await service.setCustomKey('app_version', '1.0.0');

        expect(mockCrashlytics.customKeys['app_version'], '1.0.0');
      });

      test('should set int custom key', () async {
        await service.setCustomKey('vehicle_count', 5);

        expect(mockCrashlytics.customKeys['vehicle_count'], 5);
      });

      test('should set bool custom key', () async {
        await service.setCustomKey('is_premium', true);

        expect(mockCrashlytics.customKeys['is_premium'], true);
      });
    });

    group('triggerTestCrash', () {
      test('should call crash method', () {
        service.triggerTestCrash();

        expect(mockCrashlytics.crashCalled, isTrue);
      });
    });
  });
}
