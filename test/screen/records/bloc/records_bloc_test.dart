import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/screen/records/bloc/records_bloc.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repositories
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

// Helper to create records
VehicleRecord createFuelRecord({
  required String vehicleId,
  required DateTime date,
  required int km,
  required FuelData data,
}) {
  return VehicleRecord.create(
    vehicleId: vehicleId,
    type: RecordTypeFuel(data: data, recordDate: date, odometer: km),
    title: 'Fuel',
    date: date,
    cost: data.calculatedCost,
    km: km,
  );
}

void main() {
  group('RecordsBloc', () {
    late MockVehicleRepository mockVehicleRepository;
    late MockUserSettingsRepository mockUserSettingsRepository;

    final testVehicle1 = Vehicle.empty()
      ..vehicleId = 'v1'
      ..carName = 'Car 1'
      ..currentKm = 1000;

    final testVehicle2 = Vehicle.empty()
      ..vehicleId = 'v2'
      ..carName = 'Car 2'
      ..currentKm = 2000;

    final defaultSettings = const UserSettings(speedUnit: SpeedUnit.kmh);

    setUp(() {
      mockVehicleRepository = MockVehicleRepository();
      mockUserSettingsRepository = MockUserSettingsRepository();

      registerFallbackValue(
        VehicleRecord.create(
          vehicleId: 'dummy',
          type: RecordTypeOther(
            data: OtherData(),
            recordDate: DateTime.now(),
            odometer: 0,
          ),
          title: 'dummy',
          date: DateTime.now(),
          cost: 0,
          km: 0,
        ),
      );

      registerFallbackValue(Vehicle.empty());
    });

    blocTest<RecordsBloc, RecordsState>(
      '初始化時應該發送 LoadVehicleRecord 事件並正確載入資料',
      build: () {
        when(
          () => mockVehicleRepository.loadVehicles(),
        ).thenAnswer((_) async => [testVehicle1]);
        when(
          () => mockUserSettingsRepository.loadSettings(),
        ).thenAnswer((_) async => defaultSettings);
        return RecordsBloc(
          vehicleRepository: mockVehicleRepository,
          userSettingsRepository: mockUserSettingsRepository,
        );
      },
      verify: (bloc) {
        verify(() => mockVehicleRepository.loadVehicles()).called(1);
        verify(() => mockUserSettingsRepository.loadSettings()).called(1);
      },
      // Constructor triggers LoadVehicleRecord -> emits loading=true -> emits loaded data
      // Initial state is loading=true.
      // 1. emit loading=true (clearSideEffect)
      // 2. emit loaded data
      expect: () => [
        isA<RecordsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RecordsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.vehicles, 'vehicles', [testVehicle1])
            .having((s) => s.currentVehicleId, 'currentVehicleId', 'v1')
            .having((s) => s.odometerString, 'odometerString', '1000')
            .having((s) => s.unitString, 'unitString', 'km/h'),
      ],
    );

    blocTest<RecordsBloc, RecordsState>(
      '載入資料失敗時應該發送錯誤訊息',
      build: () {
        when(
          () => mockVehicleRepository.loadVehicles(),
        ).thenThrow(Exception('Database Error'));
        return RecordsBloc(
          vehicleRepository: mockVehicleRepository,
          userSettingsRepository: mockUserSettingsRepository,
        );
      },
      expect: () => [
        isA<RecordsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RecordsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Database Error'),
            ),
        isA<RecordsState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          null,
        ), // Clear error
      ],
    );

    blocTest<RecordsBloc, RecordsState>(
      'SwitchVehicle 應該更新當前車輛和里程顯示',
      build: () {
        when(
          () => mockVehicleRepository.loadVehicles(),
        ).thenAnswer((_) async => [testVehicle1, testVehicle2]);
        when(
          () => mockUserSettingsRepository.loadSettings(),
        ).thenAnswer((_) async => defaultSettings);
        return RecordsBloc(
          vehicleRepository: mockVehicleRepository,
          userSettingsRepository: mockUserSettingsRepository,
        );
      },
      act: (bloc) async {
        await Future.delayed(Duration.zero);
        bloc.add(const SwitchVehicle('v2'));
      },
      skip: 2, // Skip initial loading sequence (loading -> loaded)
      expect: () => [
        isA<RecordsState>()
            .having((s) => s.currentVehicleId, 'currentVehicleId', 'v2')
            .having((s) => s.odometerString, 'odometerString', '2000'),
      ],
    );

    blocTest<RecordsBloc, RecordsState>(
      '切換無效的車輛 ID 應該不發生變化',
      build: () {
        when(
          () => mockVehicleRepository.loadVehicles(),
        ).thenAnswer((_) async => [testVehicle1]);
        when(
          () => mockUserSettingsRepository.loadSettings(),
        ).thenAnswer((_) async => defaultSettings);
        return RecordsBloc(
          vehicleRepository: mockVehicleRepository,
          userSettingsRepository: mockUserSettingsRepository,
        );
      },
      act: (bloc) async {
        await Future.delayed(Duration.zero);
        bloc.add(const SwitchVehicle('invalid-id'));
      },
      skip: 2,
      expect: () => [], // No state change expected
    );

    blocTest<RecordsBloc, RecordsState>(
      'AddRecord 應該呼叫 Repository 並重新載入',
      build: () {
        when(
          () => mockVehicleRepository.loadVehicles(),
        ).thenAnswer((_) async => [testVehicle1]);
        when(
          () => mockUserSettingsRepository.loadSettings(),
        ).thenAnswer((_) async => defaultSettings);
        when(
          () => mockVehicleRepository.addRecord(any(), any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockVehicleRepository.updateVehicle(any()),
        ).thenAnswer((_) async => true);

        return RecordsBloc(
          vehicleRepository: mockVehicleRepository,
          userSettingsRepository: mockUserSettingsRepository,
        );
      },
      act: (bloc) async {
        await Future.delayed(Duration.zero);
        final data = OtherData(amount: 100, note: 'Test');
        final record = VehicleRecord.create(
          vehicleId: 'v1',
          date: DateTime.now(),
          km: 1000,
          cost: 100,
          title: 'Other',
          type: RecordTypeOther(
            data: data,
            recordDate: DateTime.now(),
            odometer: 1000,
          ),
        );
        bloc.add(AddRecord(record));
      },
      skip: 2, // Skip initial load
      verify: (bloc) {
        verify(() => mockVehicleRepository.addRecord('v1', any())).called(1);
      },
      expect: () => [
        // AddRecord calls update and then triggers LoadVehicleRecord again
        // LoadVehicleRecord emits loading -> loaded
        isA<RecordsState>().having((s) => s.isLoading, 'reloading', true),
        isA<RecordsState>().having((s) => s.isLoading, 'reloaded', false),
      ],
    );

    blocTest<RecordsBloc, RecordsState>(
      'Side Effects 導航測試',
      build: () {
        when(
          () => mockVehicleRepository.loadVehicles(),
        ).thenAnswer((_) async => [testVehicle1]);
        when(
          () => mockUserSettingsRepository.loadSettings(),
        ).thenAnswer((_) async => defaultSettings);
        return RecordsBloc(
          vehicleRepository: mockVehicleRepository,
          userSettingsRepository: mockUserSettingsRepository,
        );
      },
      act: (bloc) async {
        await Future.delayed(Duration.zero);
        bloc.add(const ClickAddVehicleButton());
        bloc.add(const ClickAddRecordButton());
        bloc.add(const ClickEditVehicleButton());
      },
      skip: 2,
      expect: () => [
        isA<RecordsState>().having(
          (s) => s.sideEffect,
          'sideEffect',
          RecordsSideEffect.navigateToAddVehicle,
        ),
        isA<RecordsState>().having(
          (s) => s.sideEffect,
          'clear sideEffect',
          null,
        ),
        isA<RecordsState>().having(
          (s) => s.sideEffect,
          'sideEffect',
          RecordsSideEffect.navigateToAddRecord,
        ),
        isA<RecordsState>().having(
          (s) => s.sideEffect,
          'clear sideEffect',
          null,
        ),
        isA<RecordsState>().having(
          (s) => s.sideEffect,
          'sideEffect',
          RecordsSideEffect.navigateToEditVehicle,
        ),
        isA<RecordsState>().having(
          (s) => s.sideEffect,
          'clear sideEffect',
          null,
        ),
      ],
    );

    group('油耗計算邏輯 (Unit Logic)', () {
      group('FuelEfficiencyDisplay.calculate', () {
        test('情況 1：無加油記錄應該返回 empty', () {
          final result = FuelEfficiencyDisplay.calculate([]);
          expect(result.hasData, false);
          expect(result.format(), '');
        });

        test('情況 2：只有一筆加油記錄應該返回 empty（新邏輯）', () {
          final fuelRecord = createFuelRecord(
            vehicleId: 'test-2',
            date: DateTime(2024, 1, 15),
            km: 10050,
            data: FuelData(
              fuelType: FuelType.octane95,
              fuelAmount: 30.0,
              pricePerLiter: 30.0,
              remainingFuel: 90,
            ),
          );

          final result = FuelEfficiencyDisplay.calculate([fuelRecord]);

          expect(result.hasData, false);
          expect(result.format(), '');
        });

        test('情況 3：兩筆加油記錄應該正確計算油耗', () {
          final firstRecord = createFuelRecord(
            vehicleId: 'test-3',
            date: DateTime(2024, 1, 1),
            km: 10000,
            data: FuelData(
              fuelType: FuelType.octane95,
              fuelAmount: 40.0,
              pricePerLiter: 30.0,
              remainingFuel: 90,
            ),
          );

          final secondRecord = createFuelRecord(
            vehicleId: 'test-3',
            date: DateTime(2024, 1, 15),
            km: 10500,
            data: FuelData(
              fuelType: FuelType.octane95,
              fuelAmount: 40.0,
              pricePerLiter: 30.0,
              remainingFuel: 90,
            ),
          );

          final result = FuelEfficiencyDisplay.calculate([
            firstRecord,
            secondRecord,
          ]);

          // 500 km / 40L = 12.5 km/L
          expect(result.hasData, true);
          expect(result.kmPerLiter, 12.5);
          expect(result.format(), '12.5 km/L');
        });

        test('情況 4：多筆記錄應該使用最近兩筆計算', () {
          final firstRecord = createFuelRecord(
            vehicleId: 'test-4',
            date: DateTime(2024, 1, 1),
            km: 10000,
            data: FuelData(
              fuelType: FuelType.octane95,
              fuelAmount: 40.0,
              pricePerLiter: 30.0,
              remainingFuel: 90,
            ),
          );

          final secondRecord = createFuelRecord(
            vehicleId: 'test-4',
            date: DateTime(2024, 1, 15),
            km: 10500,
            data: FuelData(
              fuelType: FuelType.octane95,
              fuelAmount: 40.0,
              pricePerLiter: 30.0,
              remainingFuel: 90,
            ),
          );

          final thirdRecord = createFuelRecord(
            vehicleId: 'test-4',
            date: DateTime(2024, 2, 1),
            km: 11000,
            data: FuelData(
              fuelType: FuelType.octane95,
              fuelAmount: 50.0,
              pricePerLiter: 30.0,
              remainingFuel: 90,
            ),
          );

          final result = FuelEfficiencyDisplay.calculate([
            firstRecord,
            secondRecord,
            thirdRecord,
          ]);

          expect(result.hasData, true);
          expect(result.kmPerLiter, 10.0);
          expect(result.format(), '10.0 km/L');
        });
      });
    });
  });
}
