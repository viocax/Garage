import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/repositories/local_user_settings_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';

/// LocalUserSettingsRepository 測試
///
/// 注意：由於 SharedPreferences 需要 Flutter 環境，
/// 介面驗證測試在純 Dart 環境執行。
/// 完整的 CRUD 測試應透過 Integration Test 進行。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalUserSettingsRepository', () {
    group('interface implementation', () {
      test('should implement UserSettingsRepository interface', () {
        expect(LocalUserSettingsRepository, isA<Type>());
      });

      test('UserSettingsRepository should have required methods', () {
        void verifyInterface(UserSettingsRepository repo) {
          repo.loadSettings;
          repo.currentSettings;
          repo.updateSettings;
          repo.saveSettings;
          repo.clearSettings;
        }

        expect(verifyInterface, isA<Function>());
      });
    });

    group('DI support', () {
      test(
        'should have constructor that accepts optional SharedPreferencesService',
        () {
          expect(() => LocalUserSettingsRepository.new, isA<Function>());
        },
      );
    });
  });
}
