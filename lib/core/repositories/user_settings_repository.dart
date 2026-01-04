import 'package:garage/core/models/user_settings.dart';

/// 使用者設定儲存庫介面
abstract class UserSettingsRepository {
  /// 載入使用者設定
  Future<UserSettings> loadSettings();

  /// 取得目前快取的設定（需先呼叫過 loadSettings）
  UserSettings get currentSettings;

  Future<UserSettingsRepository> updateSettings(UserSettings settings);

  /// 儲存使用者設定
  Future<bool> saveSettings(UserSettings settings);

  /// 清除所有設定（重置為預設值）
  Future<bool> clearSettings();
}
