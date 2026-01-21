import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_bloc.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_event.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes
class MockVehicleRepository extends Mock implements VehicleRepository {}

// Fake Vehicle for fallback
class FakeVehicle extends Fake implements Vehicle {}

void main() {
  // 註冊 fallback values
  setUpAll(() {
    registerFallbackValue(FakeVehicle());
  });

  group('VehicleManagementBloc', () {
    late MockVehicleRepository mockVehicleRepository;

    setUp(() {
      mockVehicleRepository = MockVehicleRepository();
    });

    VehicleManagementBloc buildBloc() {
      return VehicleManagementBloc(
        vehicleRepository: mockVehicleRepository,
      );
    }

    // Helper function to create test vehicles
    Vehicle createTestVehicle({
      required String vehicleId,
      required String carName,
      int order = 0,
      int currentKm = 10000,
    }) {
      return Vehicle.create(
        vehicleId: vehicleId,
        carName: carName,
        currentKm: currentKm,
        maintenanceIntervalKm: 5000,
        order: order,
      );
    }

    group('初始化', () {
      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '應該在建構時自動載入車輛列表',
        setUp: () {
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => []);
        },
        build: buildBloc,
        expect: () => [
          isA<VehicleManagementState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.errorMessage, 'errorMessage', null),
          isA<VehicleManagementState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.vehicles, 'vehicles', []),
        ],
        verify: (_) {
          verify(() => mockVehicleRepository.loadVehicles()).called(1);
        },
      );

      test('初始狀態應該正確', () {
        when(() => mockVehicleRepository.loadVehicles())
            .thenAnswer((_) async => []);
        final bloc = buildBloc();
        expect(bloc.state.vehicles, []);
        expect(bloc.state.isLoading, false);
        expect(bloc.state.errorMessage, null);
        bloc.close();
      });
    });

    group('LoadVehicles - 載入車輛列表', () {
      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '應該成功載入車輛列表',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1', order: 0),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2', order: 1),
            createTestVehicle(vehicleId: 'v3', carName: 'Car 3', order: 2),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
        },
        build: buildBloc,
        skip: 2, // Skip initial load
        act: (bloc) => bloc.add(const LoadVehicles()),
        expect: () => [
          isA<VehicleManagementState>()
              .having((s) => s.isLoading, 'isLoading', true),
          isA<VehicleManagementState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.vehicles.length, 'vehicles.length', 3),
        ],
      );

      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '載入失敗時應該顯示錯誤訊息',
        setUp: () {
          when(() => mockVehicleRepository.loadVehicles())
              .thenThrow(Exception('載入失敗'));
        },
        build: buildBloc,
        expect: () => [
          isA<VehicleManagementState>()
              .having((s) => s.isLoading, 'isLoading', true),
          isA<VehicleManagementState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('載入失敗'),
              ),
        ],
      );
    });

    group('ReorderVehicles - 重新排序車輛', () {
      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '應該正確更新車輛順序（向下移動）',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1', order: 0),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2', order: 1),
            createTestVehicle(vehicleId: 'v3', carName: 'Car 3', order: 2),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
          when(() => mockVehicleRepository.updateVehicle(any()))
              .thenAnswer((_) async => true);
        },
        build: buildBloc,
        skip: 2, // Skip initial load
        act: (bloc) => bloc.add(const ReorderVehicles(oldIndex: 0, newIndex: 2)),
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final state = bloc.state;
          // 原本順序: v1, v2, v3
          // oldIndex=0, newIndex=2 -> newIndex becomes 1
          // 移除 v1: [v2, v3]
          // 插入到 index 1: [v2, v1, v3]
          expect(state.vehicles.length, 3);
          expect(state.vehicles[0].vehicleId, 'v2');
          expect(state.vehicles[1].vehicleId, 'v1');
          expect(state.vehicles[2].vehicleId, 'v3');

          // 驗證 order 欄位
          expect(state.vehicles[0].order, 0);
          expect(state.vehicles[1].order, 1);
          expect(state.vehicles[2].order, 2);

          // 驗證所有車輛都被更新
          verify(() => mockVehicleRepository.updateVehicle(any())).called(3);
        },
      );

      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '應該正確更新車輛順序（向上移動）',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1', order: 0),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2', order: 1),
            createTestVehicle(vehicleId: 'v3', carName: 'Car 3', order: 2),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
          when(() => mockVehicleRepository.updateVehicle(any()))
              .thenAnswer((_) async => true);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(const ReorderVehicles(oldIndex: 2, newIndex: 0)),
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final state = bloc.state;
          // 原本順序: v1, v2, v3
          // 移動後: v3, v1, v2
          expect(state.vehicles.length, 3);
          expect(state.vehicles[0].vehicleId, 'v3');
          expect(state.vehicles[1].vehicleId, 'v1');
          expect(state.vehicles[2].vehicleId, 'v2');

          verify(() => mockVehicleRepository.updateVehicle(any())).called(3);
        },
      );

      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '更新排序失敗時應該顯示錯誤訊息並清除',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1', order: 0),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2', order: 1),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
          when(() => mockVehicleRepository.updateVehicle(any()))
              .thenThrow(Exception('更新失敗'));
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(const ReorderVehicles(oldIndex: 0, newIndex: 1)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          // 注意：由於 Vehicle 對象未實現 Equatable，重新排序的狀態變化可能不會被 emit
          // 這裡我們跳過中間狀態，直接驗證錯誤處理
          // 顯示錯誤
          isA<VehicleManagementState>()
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('更新排序失敗'),
              ),
          // 清除錯誤
          isA<VehicleManagementState>()
              .having((s) => s.errorMessage, 'errorMessage', null),
        ],
        verify: (bloc) {
          // 驗證最終狀態車輛數量正確
          final state = bloc.state;
          expect(state.vehicles.length, 2);
          // 驗證 repository 被調用嘗試更新
          verify(() => mockVehicleRepository.updateVehicle(any())).called(greaterThan(0));
        },
      );
    });

    group('DeleteVehicle - 刪除車輛', () {
      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '應該成功刪除車輛',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1'),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2'),
            createTestVehicle(vehicleId: 'v3', carName: 'Car 3'),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
          when(() => mockVehicleRepository.removeVehicle('v2'))
              .thenAnswer((_) async => true);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(const DeleteVehicle('v2')),
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final state = bloc.state;
          expect(state.vehicles.length, 2);
          expect(state.vehicles.any((v) => v.vehicleId == 'v2'), false);
          expect(state.vehicles[0].vehicleId, 'v1');
          expect(state.vehicles[1].vehicleId, 'v3');

          verify(() => mockVehicleRepository.removeVehicle('v2')).called(1);
        },
      );

      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '刪除車輛失敗時應該顯示錯誤訊息並清除',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1'),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2'),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
          when(() => mockVehicleRepository.removeVehicle('v2'))
              .thenThrow(Exception('刪除失敗'));
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(const DeleteVehicle('v2')),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          // 顯示錯誤
          isA<VehicleManagementState>()
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('刪除失敗'),
              ),
          // 清除錯誤
          isA<VehicleManagementState>()
              .having((s) => s.errorMessage, 'errorMessage', null),
        ],
        verify: (bloc) {
          // 車輛列表不應該改變
          expect(bloc.state.vehicles.length, 2);
        },
      );

      blocTest<VehicleManagementBloc, VehicleManagementState>(
        '刪除不存在的車輛應該不影響列表',
        setUp: () {
          final vehicles = [
            createTestVehicle(vehicleId: 'v1', carName: 'Car 1'),
            createTestVehicle(vehicleId: 'v2', carName: 'Car 2'),
          ];
          when(() => mockVehicleRepository.loadVehicles())
              .thenAnswer((_) async => vehicles);
          when(() => mockVehicleRepository.removeVehicle('v999'))
              .thenAnswer((_) async => true);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(const DeleteVehicle('v999')),
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final state = bloc.state;
          // 列表應該保持不變
          expect(state.vehicles.length, 2);
          verify(() => mockVehicleRepository.removeVehicle('v999')).called(1);
        },
      );
    });
  });
}
