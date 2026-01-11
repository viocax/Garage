import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics 服務
/// 負責錯誤報告和崩潰追蹤
class CrashlyticsService {
  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

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
