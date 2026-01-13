import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/screen/records/all_records/bloc/all_records_bloc.dart';
import 'package:garage/screen/records/all_records/bloc/all_records_event.dart';
import 'package:garage/screen/records/all_records/bloc/all_records_state.dart';
import 'package:isar_community/isar.dart';

// Helper to create test records
VehicleRecord createTestFuelRecord({
  required String vehicleId,
  required DateTime date,
  required int km,
  required double liters,
  required double pricePerLiter,
}) {
  return VehicleRecord.create(
    vehicleId: vehicleId,
    type: RecordTypeFuel(
      data: FuelData(
        fuelType: FuelType.octane95,
        fuelAmount: liters,
        pricePerLiter: pricePerLiter,
        remainingFuel: 50,
      ),
      recordDate: date,
      odometer: km,
    ),
    title: 'Fuel',
    date: date,
    cost: liters * pricePerLiter,
    km: km,
  );
}

VehicleRecord createTestMaintenanceRecord({
  required String vehicleId,
  required DateTime date,
  required int km,
  required double cost,
}) {
  return VehicleRecord.create(
    vehicleId: vehicleId,
    type: RecordTypeMaintenance(
      data: [MaintenanceData(item: 'Oil Change', amount: cost)],
      recordDate: date,
      odometer: km,
    ),
    title: 'Maintenance',
    date: date,
    cost: cost,
    km: km,
  );
}

VehicleRecord createTestOtherRecord({
  required String vehicleId,
  required DateTime date,
  required int km,
  required double cost,
}) {
  return VehicleRecord.create(
    vehicleId: vehicleId,
    type: RecordTypeOther(
      data: OtherData(amount: cost, note: 'Test'),
      recordDate: date,
      odometer: km,
    ),
    title: 'Other',
    date: date,
    cost: cost,
    km: km,
  );
}

void main() {
  group('AllRecordsBloc', () {
    late Vehicle testVehicle;
    late Isar isar;

    setUp(() async {
      // Initialize Isar for testing
      isar = await Isar.open(
        [VehicleSchema, VehicleRecordSchema],
        directory: '',
        name: 'test_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Create test vehicle
      testVehicle = Vehicle.empty()
        ..vehicleId = 'test-v1'
        ..carName = 'Test Car'
        ..currentKm = 10000;

      await isar.writeTxn(() async {
        await isar.vehicles.put(testVehicle);
      });
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    group('初始化與資料載入', () {
      blocTest<AllRecordsBloc, AllRecordsState>(
        '建構時應該自動載入所有記錄',
        build: () => AllRecordsBloc(vehicle: testVehicle),
        expect: () => [
          isA<AllRecordsState>()
              .having((s) => s.status, 'status', AllRecordsStatus.loading),
          isA<AllRecordsState>()
              .having((s) => s.status, 'status', AllRecordsStatus.success)
              .having((s) => s.allRecords, 'allRecords', [])
              .having((s) => s.filteredRecords, 'filteredRecords', [])
              .having((s) => s.recordCount, 'recordCount', 0)
              .having((s) => s.totalExpense, 'totalExpense', 0.0),
        ],
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該載入並按日期降序排列記錄',
        setUp: () async {
          final record1 = createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 1),
            km: 10000,
            liters: 40.0,
            pricePerLiter: 30.0,
          );
          final record2 = createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 2, 1),
            km: 10500,
            liters: 35.0,
            pricePerLiter: 30.0,
          );
          final record3 = createTestMaintenanceRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 15),
            km: 10200,
            cost: 500.0,
          );

          await isar.writeTxn(() async {
            testVehicle.records.addAll([record1, record2, record3]);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1, // Skip loading state
        verify: (bloc) {
          final state = bloc.state;
          // Verify records are sorted by date descending
          expect(state.allRecords.length, 3);
          expect(state.allRecords[0].date, DateTime(2024, 2, 1)); // Most recent
          expect(state.allRecords[1].date, DateTime(2024, 1, 15));
          expect(state.allRecords[2].date, DateTime(2024, 1, 1)); // Oldest
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該正確計算統計資料',
        setUp: () async {
          final fuelRecord = createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 15),
            km: 10000,
            liters: 40.0,
            pricePerLiter: 30.0,
          );
          final maintenanceRecord = createTestMaintenanceRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 20),
            km: 10200,
            cost: 500.0,
          );

          await isar.writeTxn(() async {
            testVehicle.records.addAll([fuelRecord, maintenanceRecord]);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1,
        verify: (bloc) {
          final state = bloc.state;
          // Total expense = 1200 (fuel) + 500 (maintenance)
          expect(state.totalExpense, 1700.0);
          expect(state.recordCount, 2);

          // Category data
          expect(state.categoryExpenseData.length, 2);
          final fuelCategory =
              state.categoryExpenseData.firstWhere((c) => c.typeName == 'fuel');
          expect(fuelCategory.totalCost, 1200.0);
          expect(fuelCategory.percentage, closeTo(70.59, 0.01));
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該正確提取可用的月份',
        setUp: () async {
          final record1 = createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 15),
            km: 10000,
            liters: 40.0,
            pricePerLiter: 30.0,
          );
          final record2 = createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 2, 10),
            km: 10500,
            liters: 35.0,
            pricePerLiter: 30.0,
          );
          final record3 = createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 2, 20),
            km: 10600,
            liters: 30.0,
            pricePerLiter: 30.0,
          );

          await isar.writeTxn(() async {
            testVehicle.records.addAll([record1, record2, record3]);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.availableMonths.length, 2);
          // Should be sorted descending
          expect(state.availableMonths[0].year, 2024);
          expect(state.availableMonths[0].month, 2);
          expect(state.availableMonths[1].year, 2024);
          expect(state.availableMonths[1].month, 1);
        },
      );
    });

    group('類型過濾', () {
      late AllRecordsBloc bloc;

      setUp(() async {
        final fuelRecord = createTestFuelRecord(
          vehicleId: 'test-v1',
          date: DateTime(2024, 1, 1),
          km: 10000,
          liters: 40.0,
          pricePerLiter: 30.0,
        );
        final maintenanceRecord = createTestMaintenanceRecord(
          vehicleId: 'test-v1',
          date: DateTime(2024, 1, 15),
          km: 10200,
          cost: 500.0,
        );
        final otherRecord = createTestOtherRecord(
          vehicleId: 'test-v1',
          date: DateTime(2024, 1, 20),
          km: 10300,
          cost: 200.0,
        );

        await isar.writeTxn(() async {
          testVehicle.records.addAll([fuelRecord, maintenanceRecord, otherRecord]);
          await isar.vehicles.put(testVehicle);
        });

        bloc = AllRecordsBloc(vehicle: testVehicle);
        // Wait for initial load
        await Future.delayed(Duration.zero);
      });

      tearDown(() {
        bloc.close();
      });

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該能夠只顯示加油記錄',
        build: () => bloc,
        act: (bloc) => bloc.add(const ToggleTypeFilter('fuel')),
        skip: 2, // Skip initial loading states
        verify: (bloc) {
          final state = bloc.state;
          expect(state.filteredRecords.length, 1);
          expect(state.filteredRecords[0].typeName, 'fuel');
          expect(state.selectedTypes, {'fuel'});
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該能夠顯示多種類型記錄',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const ToggleTypeFilter('fuel'));
          bloc.add(const ToggleTypeFilter('maintenance'));
        },
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.filteredRecords.length, 2);
          expect(state.selectedTypes, {'fuel', 'maintenance'});
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '切換已選擇的類型應該取消選擇',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const ToggleTypeFilter('fuel'));
          bloc.add(const ToggleTypeFilter('maintenance'));
          bloc.add(const ToggleTypeFilter('fuel')); // Toggle off fuel
        },
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.filteredRecords.length, 1);
          expect(state.filteredRecords[0].typeName, 'maintenance');
          expect(state.selectedTypes, {'maintenance'});
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '不應該允許取消所有類型（至少保留一個）',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const ToggleTypeFilter('fuel'));
          bloc.add(const ToggleTypeFilter('fuel')); // Try to toggle off
        },
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          // Should still have fuel selected
          expect(state.selectedTypes, {'fuel'});
        },
      );
    });

    group('月份篩選', () {
      late AllRecordsBloc bloc;

      setUp(() async {
        final jan1 = createTestFuelRecord(
          vehicleId: 'test-v1',
          date: DateTime(2024, 1, 10),
          km: 10000,
          liters: 40.0,
          pricePerLiter: 30.0,
        );
        final jan2 = createTestFuelRecord(
          vehicleId: 'test-v1',
          date: DateTime(2024, 1, 20),
          km: 10500,
          liters: 35.0,
          pricePerLiter: 30.0,
        );
        final feb1 = createTestFuelRecord(
          vehicleId: 'test-v1',
          date: DateTime(2024, 2, 15),
          km: 11000,
          liters: 40.0,
          pricePerLiter: 30.0,
        );

        await isar.writeTxn(() async {
          testVehicle.records.addAll([jan1, jan2, feb1]);
          await isar.vehicles.put(testVehicle);
        });

        bloc = AllRecordsBloc(vehicle: testVehicle);
        await Future.delayed(Duration.zero);
      });

      tearDown(() {
        bloc.close();
      });

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該能夠選擇特定月份',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const SelectMonth(MonthFilter(year: 2024, month: 1)),
        ),
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.filteredRecords.length, 2);
          expect(state.selectedMonth, const MonthFilter(year: 2024, month: 1));
          // Verify all records are from January
          for (final record in state.filteredRecords) {
            expect(record.date.year, 2024);
            expect(record.date.month, 1);
          }
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該能夠清除月份選擇',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const SelectMonth(MonthFilter(year: 2024, month: 1)));
          bloc.add(const SelectMonth(null));
        },
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.filteredRecords.length, 3);
          expect(state.selectedMonth, null);
        },
      );
    });

    group('統計計算', () {
      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該正確計算月度花費',
        setUp: () async {
          final records = [
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 10),
              km: 10000,
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 20),
              km: 10500,
              liters: 35.0,
              pricePerLiter: 30.0,
            ),
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 2, 15),
              km: 11000,
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
          ];

          await isar.writeTxn(() async {
            testVehicle.records.addAll(records);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.monthlyExpenseData.length, 2);
          // Jan total: 2250, Feb total: 1200
          final janData = state.monthlyExpenseData
              .firstWhere((d) => d.monthLabel.contains('Jan'));
          expect(janData.totalCost, 2250.0);
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該正確計算分類花費',
        setUp: () async {
          final records = [
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 10),
              km: 10000,
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
            createTestMaintenanceRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 15),
              km: 10200,
              cost: 500.0,
            ),
            createTestOtherRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 20),
              km: 10300,
              cost: 200.0,
            ),
          ];

          await isar.writeTxn(() async {
            testVehicle.records.addAll(records);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.categoryExpenseData.length, 3);

          final fuelData = state.categoryExpenseData
              .firstWhere((c) => c.typeName == 'fuel');
          expect(fuelData.totalCost, 1200.0);
          expect(fuelData.percentage, closeTo(63.16, 0.01));

          final maintenanceData = state.categoryExpenseData
              .firstWhere((c) => c.typeName == 'maintenance');
          expect(maintenanceData.totalCost, 500.0);
          expect(maintenanceData.percentage, closeTo(26.32, 0.01));

          final otherData = state.categoryExpenseData
              .firstWhere((c) => c.typeName == 'other');
          expect(otherData.totalCost, 200.0);
          expect(otherData.percentage, closeTo(10.53, 0.01));
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該正確計算油耗趨勢（需要至少兩筆記錄）',
        setUp: () async {
          final records = [
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 1),
              km: 10000,
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 15),
              km: 10500, // 500km difference
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 2, 1),
              km: 11000, // 500km difference
              liters: 50.0,
              pricePerLiter: 30.0,
            ),
          ];

          await isar.writeTxn(() async {
            testVehicle.records.addAll(records);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.fuelEfficiencyData.length, 2);

          // First efficiency: 500km / 40L = 12.5
          expect(state.fuelEfficiencyData[0].kmPerLiter, 12.5);

          // Second efficiency: 500km / 50L = 10.0
          expect(state.fuelEfficiencyData[1].kmPerLiter, 10.0);
        },
      );

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該正確計算年度花費',
        setUp: () async {
          final records = [
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2023, 12, 15),
              km: 9000,
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 1, 10),
              km: 10000,
              liters: 40.0,
              pricePerLiter: 30.0,
            ),
            createTestFuelRecord(
              vehicleId: 'test-v1',
              date: DateTime(2024, 2, 15),
              km: 11000,
              liters: 50.0,
              pricePerLiter: 30.0,
            ),
          ];

          await isar.writeTxn(() async {
            testVehicle.records.addAll(records);
            await isar.vehicles.put(testVehicle);
          });
        },
        build: () => AllRecordsBloc(vehicle: testVehicle),
        skip: 1,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.annualExpenseData.length, 2);

          final data2023 =
              state.annualExpenseData.firstWhere((d) => d.year == 2023);
          expect(data2023.totalCost, 1200.0);

          final data2024 =
              state.annualExpenseData.firstWhere((d) => d.year == 2024);
          expect(data2024.totalCost, 2700.0);
        },
      );
    });

    group('清除過濾器', () {
      late AllRecordsBloc bloc;

      setUp(() async {
        final records = [
          createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 10),
            km: 10000,
            liters: 40.0,
            pricePerLiter: 30.0,
          ),
          createTestMaintenanceRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 15),
            km: 10200,
            cost: 500.0,
          ),
          createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 2, 10),
            km: 10500,
            liters: 35.0,
            pricePerLiter: 30.0,
          ),
        ];

        await isar.writeTxn(() async {
          testVehicle.records.addAll(records);
          await isar.vehicles.put(testVehicle);
        });

        bloc = AllRecordsBloc(vehicle: testVehicle);
        await Future.delayed(Duration.zero);
      });

      tearDown(() {
        bloc.close();
      });

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該清除所有過濾器並重置資料',
        build: () => bloc,
        act: (bloc) {
          // Apply filters
          bloc.add(const SelectMonth(MonthFilter(year: 2024, month: 1)));
          bloc.add(const ToggleTypeFilter('fuel'));
          // Clear all filters
          bloc.add(const ClearFilters());
        },
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          expect(state.selectedMonth, null);
          expect(state.selectedTypes, isEmpty);
          expect(state.filteredRecords.length, 3);
          expect(state.filteredRecords, state.allRecords);
        },
      );
    });

    group('Pro 狀態更新', () {
      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該能夠更新 Pro 狀態',
        build: () => AllRecordsBloc(vehicle: testVehicle),
        act: (bloc) => bloc.add(const UpdateProStatus(true)),
        skip: 2,
        verify: (bloc) {
          expect(bloc.state.isPro, true);
        },
      );
    });

    group('組合過濾', () {
      late AllRecordsBloc bloc;

      setUp(() async {
        final records = [
          createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 10),
            km: 10000,
            liters: 40.0,
            pricePerLiter: 30.0,
          ),
          createTestMaintenanceRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 1, 15),
            km: 10200,
            cost: 500.0,
          ),
          createTestFuelRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 2, 10),
            km: 10500,
            liters: 35.0,
            pricePerLiter: 30.0,
          ),
          createTestOtherRecord(
            vehicleId: 'test-v1',
            date: DateTime(2024, 2, 15),
            km: 10600,
            cost: 200.0,
          ),
        ];

        await isar.writeTxn(() async {
          testVehicle.records.addAll(records);
          await isar.vehicles.put(testVehicle);
        });

        bloc = AllRecordsBloc(vehicle: testVehicle);
        await Future.delayed(Duration.zero);
      });

      tearDown(() {
        bloc.close();
      });

      blocTest<AllRecordsBloc, AllRecordsState>(
        '應該能夠同時應用月份和類型過濾',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const SelectMonth(MonthFilter(year: 2024, month: 2)));
          bloc.add(const ToggleTypeFilter('fuel'));
        },
        skip: 2,
        verify: (bloc) {
          final state = bloc.state;
          // Should only show Feb fuel records
          expect(state.filteredRecords.length, 1);
          expect(state.filteredRecords[0].date.month, 2);
          expect(state.filteredRecords[0].typeName, 'fuel');
        },
      );
    });
  });
}
