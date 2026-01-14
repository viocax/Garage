import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Interface for Crashlytics operations, allowing injection for testing.
abstract class CrashlyticsWrapper {
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
  Future<void> recordFlutterFatalError(FlutterErrorDetails details);
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal,
  });
  Future<void> log(String message);
  Future<void> setUserIdentifier(String identifier);
  Future<void> setCustomKey(String key, Object value);
  void crash();
}

/// Default implementation using actual FirebaseCrashlytics.
class DefaultCrashlyticsWrapper implements CrashlyticsWrapper {
  const DefaultCrashlyticsWrapper();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) {
    return _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterFatalError(details);
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> log(String message) {
    return _crashlytics.log(message);
  }

  @override
  Future<void> setUserIdentifier(String identifier) {
    return _crashlytics.setUserIdentifier(identifier);
  }

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }

  @override
  void crash() {
    _crashlytics.crash();
  }
}

/// Crashlytics 服務
/// 負責錯誤報告和崩潰追蹤
class CrashlyticsService {
  final CrashlyticsWrapper _crashlytics;

  /// Creates a CrashlyticsService with optional dependency injection.
  ///
  /// For production, use the default constructor without parameters.
  /// For testing, inject a mock CrashlyticsWrapper.
  CrashlyticsService({CrashlyticsWrapper? crashlytics})
    : _crashlytics = crashlytics ?? const DefaultCrashlyticsWrapper();

  /// 初始化 Crashlytics
  /// 設置 Flutter 和 Dart 錯誤處理器
  Future<void> initialize() async {
    // 在 debug 模式下停用 Crashlytics
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // 捕獲 Flutter framework 錯誤
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
      originalOnError?.call(errorDetails);
    };

    // 捕獲平台層錯誤（Platform Dispatcher）
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// 記錄非致命錯誤
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// 記錄日誌（用於除錯上下文）
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// 設置用戶識別碼
  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  /// 設置自定義鍵值對
  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// 觸發測試崩潰（僅用於測試）
  void triggerTestCrash() {
    _crashlytics.crash();
  }
}
