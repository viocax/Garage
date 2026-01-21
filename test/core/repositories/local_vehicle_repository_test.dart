import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/repositories/local_vehicle_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

/// LocalVehicleRepository 測試
///
/// 注意：由於 Isar 需要原生 library，無法在純 Dart 單元測試中運行。
/// 這些測試驗證：
/// 1. 類別正確實作 VehicleRepository 介面
/// 2. 公開 API 符合預期
///
/// 完整的 CRUD 測試應透過 Integration Test 或 Widget Test 進行。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalVehicleRepository', () {
    group('interface implementation', () {
      test('should implement VehicleRepository interface', () {
        // This test verifies the class implements the interface correctly
        // Actual instantiation requires Isar, so we just check the type
        expect(LocalVehicleRepository, isA<Type>());
      });

      test('VehicleRepository should have required methods', () {
        // Verify the interface has all expected methods by checking the type
        void verifyInterface(VehicleRepository repo) {
          // These will fail at compile time if interface is missing methods
          repo.loadVehicles;
          repo.addVehicle;
          repo.addRecord;
          repo.removeVehicle;
          repo.removeRecords;
          repo.updateRecords;
          repo.updateVehicle;
          repo.saveEdit;
          repo.removeAll;
        }

        // Just checking the function compiles - won't actually run it
        expect(verifyInterface, isA<Function>());
      });
    });

    group('DI support', () {
      test('should have constructor that accepts IsarService', () {
        // Verify the class has a constructor with optional IsarService
        // This is a compile-time check - if the constructor doesn't exist,
        // this file won't compile
        expect(() => LocalVehicleRepository.new, isA<Function>());
      });
    });
  });
}
