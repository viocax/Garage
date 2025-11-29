import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPreferencesInterface {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);

  Future<bool> setInt(String key, int value);
  Future<int?> getInt(String key);

  Future<bool> setDouble(String key, double value);
  Future<double?> getDouble(String key);

  Future<bool> setBool(String key, bool value);
  Future<bool?> getBool(String key);

  Future<bool> setStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);

  Future<bool> containsKey(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
  Future<Set<String>> getKeys();
  Future<void> reload();
}

class SharedPreferencesWrapper implements SharedPreferencesInterface {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<bool> setString(String key, String value) async {
    final p = await prefs;
    return p.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    final p = await prefs;
    return p.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    final p = await prefs;
    return p.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    final p = await prefs;
    return p.getDouble(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    final p = await prefs;
    return p.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    final p = await prefs;
    return p.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final p = await prefs;
    return p.getStringList(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    final p = await prefs;
    return p.containsKey(key);
  }

  @override
  Future<bool> remove(String key) async {
    final p = await prefs;
    return p.remove(key);
  }

  @override
  Future<bool> clear() async {
    final p = await prefs;
    return p.clear();
  }

  @override
  Future<Set<String>> getKeys() async {
    final p = await prefs;
    return p.getKeys();
  }

  @override
  Future<void> reload() async {
    final p = await prefs;
    await p.reload();
  }
}
