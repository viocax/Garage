import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/shared_preferences/shared_preferences_service.dart';
import 'package:garage/core/service/shared_preferences/shared_preferences_interface.dart';

/// Mock SharedPreferencesInterface for testing
class MockSharedPreferences implements SharedPreferencesInterface {
  final Map<String, dynamic> _data = {};

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    return _data[key] as String?;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    return _data[key] as int?;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _data[key] as double?;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _data[key] as bool?;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _data[key] as List<String>?;
  }

  @override
  Future<bool> containsKey(String key) async {
    return _data.containsKey(key);
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<Set<String>> getKeys() async {
    return _data.keys.toSet();
  }

  @override
  Future<void> reload() async {
    // Mock implementation - do nothing
  }
}

void main() {
  group('SharedPreferencesService', () {
    late SharedPreferencesService service;
    late MockSharedPreferences mockPreferences;

    setUp(() {
      mockPreferences = MockSharedPreferences();
      service = SharedPreferencesService(preferences: mockPreferences);
    });

    group('String operations', () {
      test('should save and retrieve string', () async {
        // Arrange
        const key = 'testKey';
        const value = 'testValue';

        // Act
        await service.setString(key, value);
        final result = await service.getString(key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent string key', () async {
        // Act
        final result = await service.getString('nonExistentKey');

        // Assert
        expect(result, isNull);
      });
    });

    group('Int operations', () {
      test('should save and retrieve int', () async {
        // Arrange
        const key = 'intKey';
        const value = 42;

        // Act
        await service.setInt(key, value);
        final result = await service.getInt(key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent int key', () async {
        // Act
        final result = await service.getInt('nonExistentKey');

        // Assert
        expect(result, isNull);
      });
    });

    group('Double operations', () {
      test('should save and retrieve double', () async {
        // Arrange
        const key = 'doubleKey';
        const value = 3.14;

        // Act
        await service.setDouble(key, value);
        final result = await service.getDouble(key);

        // Assert
        expect(result, equals(value));
      });
    });

    group('Bool operations', () {
      test('should save and retrieve bool', () async {
        // Arrange
        const key = 'boolKey';
        const value = true;

        // Act
        await service.setBool(key, value);
        final result = await service.getBool(key);

        // Assert
        expect(result, equals(value));
      });
    });

    group('StringList operations', () {
      test('should save and retrieve string list', () async {
        // Arrange
        const key = 'listKey';
        const value = ['item1', 'item2', 'item3'];

        // Act
        await service.setStringList(key, value);
        final result = await service.getStringList(key);

        // Assert
        expect(result, equals(value));
      });
    });

    group('General operations', () {
      test('should check if key exists', () async {
        // Arrange
        const key = 'existingKey';
        await service.setString(key, 'value');

        // Act
        final exists = await service.containsKey(key);
        final notExists = await service.containsKey('nonExistentKey');

        // Assert
        expect(exists, isTrue);
        expect(notExists, isFalse);
      });

      test('should remove key', () async {
        // Arrange
        const key = 'keyToRemove';
        await service.setString(key, 'value');

        // Act
        await service.remove(key);
        final exists = await service.containsKey(key);

        // Assert
        expect(exists, isFalse);
      });

      test('should clear all data', () async {
        // Arrange
        await service.setString('key1', 'value1');
        await service.setInt('key2', 123);
        await service.setBool('key3', true);

        // Act
        await service.clear();
        final keys = await service.getKeys();

        // Assert
        expect(keys, isEmpty);
      });

      test('should get all keys', () async {
        // Arrange
        await service.setString('key1', 'value1');
        await service.setInt('key2', 123);
        await service.setBool('key3', true);

        // Act
        final keys = await service.getKeys();

        // Assert
        expect(keys, hasLength(3));
        expect(keys, containsAll(['key1', 'key2', 'key3']));
      });

      test('should get stats', () async {
        // Arrange
        await service.setString('key1', 'value1');
        await service.setInt('key2', 123);

        // Act
        final stats = await service.getStats();

        // Assert
        expect(stats['totalKeys'], equals(2));
        expect(stats['keys'], containsAll(['key1', 'key2']));
      });
    });
  });
}
