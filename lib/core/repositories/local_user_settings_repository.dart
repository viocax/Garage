import 'dart:convert';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/service/shared_preferences/shared_preferences_service.dart';
import 'package:garage/core/di/service_locator.dart';
import 'user_settings_repository.dart';

/// 使用者設定儲存庫實作
class LocalUserSettingsRepository implements UserSettingsRepository {
  static const String _settingsKey = 'user_settings';

  final SharedPreferencesService _prefs;
  UserSettings? _cachedSettings;

  /// Creates a LocalUserSettingsRepository with optional dependency injection.
  ///
  /// For production, use the default constructor without parameters.
  /// For testing, inject a mock SharedPreferencesService.
  LocalUserSettingsRepository({SharedPreferencesService? preferencesService})
    : _prefs = preferencesService ?? getIt.service.preferences;

  @override
  UserSettings get currentSettings =>
      _cachedSettings ?? UserSettings.defaults();

  /// 載入使用者設定
  @override
  Future<UserSettings> loadSettings() async {
    // 如果有快取，直接返回
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final jsonString = await _prefs.getString(_settingsKey);

      if (jsonString == null || jsonString.isEmpty) {
        // 如果沒有儲存的設定，返回預設值
        _cachedSettings = UserSettings.defaults();
        return _cachedSettings!;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedSettings = UserSettings.fromJson(json);
      return _cachedSettings!;
    } catch (e) {
      // 如果解析失敗，返回預設值
      _cachedSettings = UserSettings.defaults();
      return _cachedSettings!;
    }
  }

  /// 更新使用者設定（更新快取但不保存）
  @override
  Future<UserSettingsRepository> updateSettings(UserSettings settings) async {
    _cachedSettings = settings;
    return this;
  }

  /// 儲存使用者設定
  @override
  Future<bool> saveSettings(UserSettings settings) async {
    try {
      final jsonString = jsonEncode(settings.toJson());
      final success = await _prefs.setString(_settingsKey, jsonString);
      if (success) {
        _cachedSettings = settings;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// 清除所有設定（重置為預設值）
  @override
  Future<bool> clearSettings() async {
    final success = await _prefs.remove(_settingsKey);
    if (success) {
      _cachedSettings = null;
    }
    return success;
  }
}
