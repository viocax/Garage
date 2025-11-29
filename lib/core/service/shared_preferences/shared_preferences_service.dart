import 'package:flutter/foundation.dart';
import 'package:garage/core/service/shared_preferences/shared_preferences_interface.dart';

/// SharedPreferences 服務
class SharedPreferencesService {
  final SharedPreferencesInterface preferences;

  SharedPreferencesService({SharedPreferencesInterface? preferences})
      : preferences = preferences ?? SharedPreferencesWrapper();

  // MARK: - String 操作

  /// 儲存字串
  Future<bool> setString(String key, String value) async {
    final result = await preferences.setString(key, value);
    debugPrint('SharedPreferencesService: 儲存字串 $key = $value');
    return result;
  }

  /// 取得字串
  Future<String?> getString(String key) async {
    return await preferences.getString(key);
  }

  // MARK: - Int 操作

  /// 儲存整數
  Future<bool> setInt(String key, int value) async {
    final result = await preferences.setInt(key, value);
    debugPrint('SharedPreferencesService: 儲存整數 $key = $value');
    return result;
  }

  /// 取得整數
  Future<int?> getInt(String key) async {
    return await preferences.getInt(key);
  }

  // MARK: - Double 操作

  /// 儲存浮點數
  Future<bool> setDouble(String key, double value) async {
    final result = await preferences.setDouble(key, value);
    debugPrint('SharedPreferencesService: 儲存浮點數 $key = $value');
    return result;
  }

  /// 取得浮點數
  Future<double?> getDouble(String key) async {
    return await preferences.getDouble(key);
  }

  // MARK: - Bool 操作

  /// 儲存布林值
  Future<bool> setBool(String key, bool value) async {
    final result = await preferences.setBool(key, value);
    debugPrint('SharedPreferencesService: 儲存布林值 $key = $value');
    return result;
  }

  /// 取得布林值
  Future<bool?> getBool(String key) async {
    return await preferences.getBool(key);
  }

  // MARK: - StringList 操作

  /// 儲存字串列表
  Future<bool> setStringList(String key, List<String> value) async {
    final result = await preferences.setStringList(key, value);
    debugPrint('SharedPreferencesService: 儲存字串列表 $key = $value');
    return result;
  }

  /// 取得字串列表
  Future<List<String>?> getStringList(String key) async {
    return await preferences.getStringList(key);
  }

  // MARK: - 通用操作

  /// 檢查 key 是否存在
  Future<bool> containsKey(String key) async {
    return await preferences.containsKey(key);
  }

  /// 移除指定 key 的值
  Future<bool> remove(String key) async {
    final result = await preferences.remove(key);
    debugPrint('SharedPreferencesService: 移除 $key');
    return result;
  }

  /// 清空所有資料
  Future<bool> clear() async {
    final result = await preferences.clear();
    debugPrint('SharedPreferencesService: 清空所有資料');
    return result;
  }

  /// 取得所有 keys
  Future<Set<String>> getKeys() async {
    return await preferences.getKeys();
  }

  /// 重新載入資料（從持久化儲存重新讀取）
  Future<void> reload() async {
    await preferences.reload();
    debugPrint('SharedPreferencesService: 重新載入資料');
  }

  /// 取得所有儲存的資料統計
  Future<Map<String, dynamic>> getStats() async {
    final keys = await preferences.getKeys();

    return {
      'totalKeys': keys.length,
      'keys': keys.toList(),
    };
  }
}
