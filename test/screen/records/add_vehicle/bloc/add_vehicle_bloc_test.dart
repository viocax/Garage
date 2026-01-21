import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/screen/records/add_vehicle/bloc/add_vehicle_bloc.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

class MockAdRepository extends Mock implements AdRepository {}

void main() {
  group('AddVehicleBloc', () {
    late MockVehicleRepository vehicleRepository;
    late MockUserSettingsRepository userSettingsRepository;
    late MockAdRepository adRepository;

    final defaultSettings = const UserSettings(speedUnit: SpeedUnit.mph);

    setUp(() {
      vehicleRepository = MockVehicleRepository();
      userSettingsRepository = MockUserSettingsRepository();
      adRepository = MockAdRepository();

      when(
        () => userSettingsRepository.loadSettings(),
      ).thenAnswer((_) async => defaultSettings);

      registerFallbackValue(Vehicle.empty());
    });

    AddVehicleBloc buildBloc({Vehicle? vehicleToEdit}) {
      return AddVehicleBloc(
        vehicleRepository: vehicleRepository,
        userSettingsRepository: userSettingsRepository,
        adRepository: adRepository,
        vehicleToEdit: vehicleToEdit,
      );
    }

    group('Initialization', () {
      blocTest<AddVehicleBloc, AddVehicleState>(
        'should load user settings',
        build: buildBloc,
        verify: (_) {
          verify(() => userSettingsRepository.loadSettings()).called(1);
        },
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.speedUnit,
            'unit',
            SpeedUnit.mph,
          ),
        ],
      );

      test('should initialize with editing vehicle data', () {
        final vehicle = Vehicle.empty()
          ..carName = 'Edit Car'
          ..licensePlate = 'ABC-123'
          ..currentKm = 5000
          ..maintenanceIntervalKm = 10000;

        final bloc = buildBloc(vehicleToEdit: vehicle);

        expect(bloc.state.vehicleName, 'Edit Car');
        expect(bloc.state.licensePlate, 'ABC-123');
        expect(bloc.state.currentKm, 5000);
        expect(bloc.state.maintenanceIntervalKm, 10000);
        expect(bloc.state.isEditing, true);
      });
    });

    group('Field Updates', () {
      blocTest<AddVehicleBloc, AddVehicleState>(
        'updates vehicle name',
        build: buildBloc,
        act: (bloc) => bloc.add(const VehicleNameChanged('New Car')),
        skip: 1, // LoadSettings
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.vehicleName,
            'name',
            'New Car',
          ),
        ],
      );

      blocTest<AddVehicleBloc, AddVehicleState>(
        'updates license plate',
        build: buildBloc,
        act: (bloc) => bloc.add(const LicensePlateChanged('XYZ-999')),
        skip: 1,
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.licensePlate,
            'plate',
            'XYZ-999',
          ),
        ],
      );

      blocTest<AddVehicleBloc, AddVehicleState>(
        'updates km',
        build: buildBloc,
        act: (bloc) => bloc.add(const VehicleKmChanged(100)),
        skip: 1,
        expect: () => [
          isA<AddVehicleState>().having((s) => s.currentKm, 'km', 100),
        ],
      );

      blocTest<AddVehicleBloc, AddVehicleState>(
        'updates maintenance interval',
        build: buildBloc,
        act: (bloc) => bloc.add(const MaintenanceIntervalChanged(5000)),
        skip: 1,
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.maintenanceIntervalKm,
            'interval',
            5000,
          ),
        ],
      );
    });

    group('Submission', () {
      blocTest<AddVehicleBloc, AddVehicleState>(
        'should fail if validation fails (empty fields)',
        build: buildBloc,
        act: (bloc) => bloc.add(const SubmitVehicle()),
        skip: 1,
        expect: () => [
          isA<AddVehicleState>()
              .having((s) => s.status, 'status', AddVehicleStatus.failure)
              .having((s) => s.errorMessage, 'error', isNotNull),
        ],
      );

      blocTest<AddVehicleBloc, AddVehicleState>(
        'should add vehicle successfully',
        build: buildBloc,
        setUp: () {
          when(
            () => vehicleRepository.addVehicle(any()),
          ).thenAnswer((_) async => true);
        },
        act: (bloc) {
          bloc.add(const VehicleNameChanged('Car'));
          bloc.add(const LicensePlateChanged('P'));
          bloc.add(const SubmitVehicle());
        },
        skip: 3, // LoadSettings, Name, Plate
        verify: (_) {
          verify(() => vehicleRepository.addVehicle(any())).called(1);
        },
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.status,
            'submitting',
            AddVehicleStatus.submitting,
          ),
          isA<AddVehicleState>()
              .having((s) => s.status, 'success', AddVehicleStatus.success)
              .having((s) => s.createdVehicle, 'created', isNotNull),
        ],
      );

      blocTest<AddVehicleBloc, AddVehicleState>(
        'should update vehicle successfully if editing',
        build: () {
          final vehicle = Vehicle.empty()
            ..vehicleId = 'v1'
            ..carName = 'Old Name'
            ..licensePlate = 'OLD-123';
          return buildBloc(vehicleToEdit: vehicle);
        },
        setUp: () {
          when(
            () => vehicleRepository.updateVehicle(any()),
          ).thenAnswer((_) async => true);
        },
        act: (bloc) {
          // Fields are pre-filled but let's change one
          bloc.add(const VehicleNameChanged('Updated Car'));
          bloc.add(const SubmitVehicle());
        },
        skip: 2, // LoadSettings, Name
        verify: (_) {
          verify(() => vehicleRepository.updateVehicle(any())).called(1);
        },
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.status,
            'submitting',
            AddVehicleStatus.submitting,
          ),
          isA<AddVehicleState>().having(
            (s) => s.status,
            'success',
            AddVehicleStatus.success,
          ),
        ],
      );

      blocTest<AddVehicleBloc, AddVehicleState>(
        'should fail if repository method fails',
        build: buildBloc,
        setUp: () {
          when(
            () => vehicleRepository.addVehicle(any()),
          ).thenAnswer((_) async => false);
        },
        act: (bloc) {
          bloc.add(const VehicleNameChanged('Car'));
          bloc.add(const LicensePlateChanged('P'));
          bloc.add(const SubmitVehicle());
        },
        skip: 3,
        expect: () => [
          isA<AddVehicleState>().having(
            (s) => s.status,
            'submitting',
            AddVehicleStatus.submitting,
          ),
          isA<AddVehicleState>()
              .having((s) => s.status, 'failure', AddVehicleStatus.failure)
              .having((s) => s.errorMessage, 'error', isNotNull),
        ],
      );
    });

    group('Ad Logic', () {
      test('showAd calls showInterstitialAd when creating', () {
        final bloc = buildBloc();
        var callbackCalled = false;

        when(
          () => adRepository.showInterstitialAd(
            onComplete: any(named: 'onComplete'),
          ),
        ).thenAnswer((invocation) {
          final callback = invocation.namedArguments[#onComplete] as Function();
          callback();
          return Future<void>.value();
        });

        bloc.showAd(onComplete: () => callbackCalled = true);

        verify(
          () => adRepository.showInterstitialAd(
            onComplete: any(named: 'onComplete'),
          ),
        ).called(1);
        expect(callbackCalled, true);
      });

      test('showAd calls callback immediately when editing (no ad)', () {
        final vehicle = Vehicle.empty();
        final bloc = buildBloc(vehicleToEdit: vehicle);
        var callbackCalled = false;

        bloc.showAd(onComplete: () => callbackCalled = true);

        // Should NOT call ad repository
        verifyNever(
          () => adRepository.showInterstitialAd(
            onComplete: any(named: 'onComplete'),
          ),
        );
        expect(callbackCalled, true);
      });
    });
  });
}
