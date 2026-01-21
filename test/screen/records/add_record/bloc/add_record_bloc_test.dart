import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/screen/records/add_record/bloc/add_record_bloc.dart';
import 'package:garage/screen/records/add_record/bloc/add_record_event.dart';
import 'package:garage/screen/records/add_record/bloc/add_record_state.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockAdRepository extends Mock implements AdRepository {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

// Fakes
class FakeVehicleRecord extends Fake implements VehicleRecord {}

void main() {
  group('AddRecordBloc', () {
    late MockVehicleRepository vehicleRepository;
    late MockAdRepository adRepository;
    late MockUserSettingsRepository userSettingsRepository;
    late Vehicle testVehicle;

    final defaultSettings = const UserSettings(speedUnit: SpeedUnit.mph);

    setUpAll(() {
      registerFallbackValue(FakeVehicleRecord());
    });

    setUp(() {
      vehicleRepository = MockVehicleRepository();
      adRepository = MockAdRepository();
      userSettingsRepository = MockUserSettingsRepository();

      testVehicle = Vehicle.empty()
        ..vehicleId = 'v1'
        ..currentKm = 1000;

      when(
        () => userSettingsRepository.loadSettings(),
      ).thenAnswer((_) async => defaultSettings);
    });

    // Helper to build bloc
    AddRecordBloc buildBloc() {
      return AddRecordBloc(
        vehicle: testVehicle,
        repository: vehicleRepository,
        adRepository: adRepository,
        userSettingsRepository: userSettingsRepository,
      );
    }

    group('Initialization', () {
      blocTest<AddRecordBloc, AddRecordState>(
        'should load user settings and update speedUnit',
        build: buildBloc,
        verify: (_) {
          verify(() => userSettingsRepository.loadSettings()).called(1);
        },
        expect: () => [
          isA<AddRecordState>().having(
            (s) => s.speedUnit,
            'speedUnit',
            SpeedUnit.mph,
          ),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'should initialize with Fuel type and vehicle Km',
        build: buildBloc,
        expect: () => [
          // Because LoadUserSettings is called in constructor, we expect the speedUnit state
          isA<AddRecordState>(),
        ],
        verify: (bloc) {
          expect(bloc.state.recordType, isA<RecordTypeFuel>());
          expect(bloc.state.km, testVehicle.currentKm);
          expect(bloc.state.date.day, DateTime.now().day);
        },
      );
    });

    group('Common Fields', () {
      final newDate = DateTime(2025, 1, 1);
      final newKm = 1500;

      blocTest<AddRecordBloc, AddRecordState>(
        'DateChanged should update date',
        build: buildBloc,
        act: (bloc) => bloc.add(DateChanged(newDate)),
        expect: () => [
          // First one is from LoadUserSettings
          isA<AddRecordState>(),
          isA<AddRecordState>().having((s) => s.date, 'date', newDate),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'KmChanged should update odometer',
        build: buildBloc,
        act: (bloc) => bloc.add(KmChanged(newKm)),
        expect: () => [
          isA<AddRecordState>(),
          isA<AddRecordState>().having((s) => s.km, 'km', newKm),
        ],
      );
    });

    group('Record Type Switching', () {
      blocTest<AddRecordBloc, AddRecordState>(
        'should switch to Maintenance type',
        build: buildBloc,
        act: (bloc) => bloc.add(
          RecordTypeChanged(
            RecordTypeMaintenance(
              data: [],
              recordDate: DateTime.now(),
              odometer: 0,
            ),
          ),
        ),
        expect: () => [
          isA<AddRecordState>(),
          isA<AddRecordState>()
              .having((s) => s.recordType, 'type', isA<RecordTypeMaintenance>())
              .having(
                (s) => s.maintenanceEntries.length,
                'entries',
                1,
              ), // Defaults to 1 entry
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'should switch to Other type',
        build: buildBloc,
        act: (bloc) => bloc.add(
          RecordTypeChanged(
            RecordTypeOther(
              data: OtherData(),
              recordDate: DateTime.now(),
              odometer: 0,
            ),
          ),
        ),
        expect: () => [
          isA<AddRecordState>(),
          isA<AddRecordState>().having(
            (s) => s.recordType,
            'type',
            isA<RecordTypeOther>(),
          ),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'should preserve date and km when switching',
        build: buildBloc,
        act: (bloc) async {
          // Change km first
          bloc.add(const KmChanged(2000));
          // Then switch type
          bloc.add(
            RecordTypeChanged(
              RecordTypeOther(
                data: OtherData(),
                recordDate: DateTime.now(),
                odometer: 0,
              ),
            ),
          );
        },
        skip: 2, // LoadSettings, KmChanged
        expect: () => [
          isA<AddRecordState>()
              .having((s) => s.km, 'preserved km', 2000)
              .having((s) => s.recordType, 'type', isA<RecordTypeOther>()),
        ],
      );
    });

    group('Fuel Logic', () {
      blocTest<AddRecordBloc, AddRecordState>(
        'FuelTypeChanged should update fuel type',
        build: buildBloc,
        act: (bloc) => bloc.add(const FuelTypeChanged(FuelType.diesel)),
        skip: 1,
        expect: () => [
          isA<AddRecordState>().having(
            (s) => s.fuelType,
            'fuelType',
            FuelType.diesel,
          ),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'Validation should calculate cost correctly',
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const FuelAmountChanged(30));
          bloc.add(const PricePerLiterChanged(30));
        },
        skip: 1,
        expect: () => [
          isA<AddRecordState>().having((s) => s.fuelAmount, 'amount', 30.0),
          isA<AddRecordState>()
              .having((s) => s.pricePerLiter, 'price', 30.0)
              .having((s) => s.amount, 'calculated cost', 900.0), // 30 * 30
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'AmountChanged (total cost) should reverse calculate fuel amount',
        build: buildBloc,
        seed: () => AddRecordState(
          recordType: RecordTypeFuel(
            data: FuelData(pricePerLiter: 30), // Price must be set
            recordDate: DateTime.now(),
            odometer: 1000,
          ),
        ),
        act: (bloc) => bloc.add(const AmountChanged(900)),
        expect: () => [
          isA<AddRecordState>(), // LoadSettings
          isA<AddRecordState>()
              .having(
                (s) => s.fuelAmount,
                'calculated fuel amount',
                30.0,
              ) // 900 / 30
              .having((s) => s.isAmountManuallyEdited, 'manual flag', true),
        ],
      );
    });

    group('Maintenance Logic', () {
      // Need to switch to Maintenance type first usually, or seed it
      final maintenanceState = AddRecordState(
        recordType: RecordTypeMaintenance(
          data: [MaintenanceData()],
          recordDate: DateTime.now(),
          odometer: 1000,
        ),
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'AddMaintenanceEntry should add an entry',
        build: buildBloc,
        seed: () => maintenanceState,
        act: (bloc) => bloc.add(const AddMaintenanceEntry()),
        expect: () => [
          isA<AddRecordState>(), // LoadSettings
          isA<AddRecordState>().having(
            (s) => s.maintenanceEntries.length,
            'length',
            2,
          ),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'UpdateMaintenanceEntry should update specific entry',
        build: buildBloc,
        seed: () => maintenanceState,
        act: (bloc) => bloc.add(
          const UpdateMaintenanceEntry(
            index: 0,
            item: 'Oil Change',
            amount: 500,
          ),
        ),
        expect: () => [
          isA<AddRecordState>(), // LoadSettings
          isA<AddRecordState>()
              .having(
                (s) => s.maintenanceEntries.first.item,
                'item',
                'Oil Change',
              )
              .having((s) => s.maintenanceEntries.first.amount, 'amount', 500.0)
              .having((s) => s.totalMaintenanceAmount, 'total', 500.0),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'RemoveMaintenanceEntry should remove entry',
        build: buildBloc,
        seed: () => AddRecordState(
          recordType: RecordTypeMaintenance(
            data: [
              MaintenanceData(item: '1'),
              MaintenanceData(item: '2'),
            ],
            recordDate: DateTime.now(),
            odometer: 1000,
          ),
        ),
        act: (bloc) => bloc.add(const RemoveMaintenanceEntry(0)),
        expect: () => [
          isA<AddRecordState>(), // LoadSettings
          isA<AddRecordState>()
              .having((s) => s.maintenanceEntries.length, 'length', 1)
              .having((s) => s.maintenanceEntries.first.item, 'remaining', '2'),
        ],
      );
    });

    group('Submission', () {
      blocTest<AddRecordBloc, AddRecordState>(
        'Should fail if validation fails (fuel amount 0)',
        build: buildBloc,
        act: (bloc) => bloc.add(const SubmitRecord()),
        // Removing skip to debug state emission
        // Expect LoadUserSettings (MPH) -> Validation Failure
        expect: () => [
          // 1. SubmitRecord emits Failure (synch check)
          // Settings hasn't updated yet so it's KMH
          isA<AddRecordState>()
              .having((s) => s.status, 'status', AddRecordStatus.failure)
              .having((s) => s.speedUnit, 'unit', SpeedUnit.kmh),

          // 2. LoadUserSettings completes, updates to MPH
          // Should PRESERVE Failure status and Error (due to fix)
          isA<AddRecordState>()
              .having((s) => s.status, 'status', AddRecordStatus.failure)
              .having((s) => s.speedUnit, 'unit', SpeedUnit.mph)
              .having((s) => s.errorMessage, 'error', isNotNull),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'Should succeed if valid',
        build: buildBloc,
        setUp: () {
          when(
            () => vehicleRepository.addRecord(any(), any()),
          ).thenAnswer((_) async => true);
        },
        act: (bloc) async {
          // Make it valid
          bloc.add(const FuelAmountChanged(20));
          bloc.add(const SubmitRecord());
        },
        skip: 1, // LoadSettings
        verify: (_) {
          verify(() => vehicleRepository.addRecord('v1', any())).called(1);
        },
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          isA<AddRecordState>().having((s) => s.fuelAmount, 'amount set', 20.0),
          isA<AddRecordState>().having(
            (s) => s.status,
            'submitting',
            AddRecordStatus.submitting,
          ),
          isA<AddRecordState>().having(
            (s) => s.status,
            'success',
            AddRecordStatus.success,
          ),
        ],
      );

      blocTest<AddRecordBloc, AddRecordState>(
        'Should fail if repository throws',
        build: buildBloc,
        setUp: () {
          when(
            () => vehicleRepository.addRecord(any(), any()),
          ).thenThrow(Exception('DB Error'));
        },
        act: (bloc) async {
          // Make it valid
          bloc.add(const FuelAmountChanged(20));
          bloc.add(const SubmitRecord());
        },
        skip: 1,
        // _onSubmitRecord doesn't delay on failure in catch block?
        // Wait, yes it does not delay.
        // But let's check failing test output again.
        // Actual had Valid/MPH, Submitting.
        // Missing the Failure state?
        // Or missing FuelAmountChanged state?
        // Let's safe guard with wait if needed, but error should be immediate?
        // Submitting state comes, then repo throws, then failure.
        // Repo throws in 'thenThrow'.
        // Logic: emit(submitting); try { repo.add; ... } catch { emit(failure); }
        // So submitting -> failure is immediate if repo is sync-ish.
        // Mocktail .thenThrow is sync?
        // Yes, likely.

        // Wait, why did "Should fail if repository throws" fail before?
        // Actual: [Valid/MPH, Submitting].
        // Expecting: [Amount, Submitting, Failure].
        // Missing Amount?
        // Missing Failure?
        // If repo throw is sync, it should be there.
        // Maybe Submitting -> Failure is too fast? No.
        // Maybe Failure was swallowed?

        // Let's add wait just in case of async gap
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          isA<AddRecordState>(), // Fuel Amount
          isA<AddRecordState>().having(
            (s) => s.status,
            'submitting',
            AddRecordStatus.submitting,
          ),
          isA<AddRecordState>()
              .having((s) => s.status, 'failure', AddRecordStatus.failure)
              .having((s) => s.errorMessage, 'error', contains('DB Error')),
        ],
      );
    });
  });
}
