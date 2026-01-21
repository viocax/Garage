import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/repositories/cloud_sync_repository.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';
import 'package:garage/screen/settings/cloud_sync/bloc/cloud_sync_bloc.dart';
import 'package:garage/screen/settings/cloud_sync/bloc/cloud_sync_event.dart';
import 'package:garage/screen/settings/cloud_sync/bloc/cloud_sync_state.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockCloudSyncRepository extends Mock implements CloudSyncRepository {}

class MockVehicleRepository extends Mock implements VehicleRepository {}

void main() {
  group('CloudSyncBloc', () {
    late MockCloudSyncRepository cloudSyncRepository;
    late MockVehicleRepository vehicleRepository;

    const testProvider = CloudProvider.googleDrive;
    final testStatus = ProviderStatus(
      provider: testProvider,
      isAvailable: true,
      isAuthenticated: false,
      lastSyncTime: null,
    );

    setUp(() {
      cloudSyncRepository = MockCloudSyncRepository();
      vehicleRepository = MockVehicleRepository();

      // Default mock responses
      when(
        () => cloudSyncRepository.getAvailableProvider(),
      ).thenReturn(testProvider);
      when(
        () => cloudSyncRepository.isAvailable(testProvider),
      ).thenAnswer((_) async => true);
      when(
        () => cloudSyncRepository.isAuthenticated(testProvider),
      ).thenAnswer((_) async => false);
      when(
        () => cloudSyncRepository.getLastSyncTime(testProvider),
      ).thenAnswer((_) async => null);
    });

    CloudSyncBloc buildBloc() {
      return CloudSyncBloc(
        cloudSyncRepository: cloudSyncRepository,
        vehicleRepository: vehicleRepository,
      );
    }

    test('initial state is CloudSyncInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<CloudSyncInitial>());
      bloc.close();
    });

    blocTest<CloudSyncBloc, CloudSyncState>(
      'LoadCloudSyncStatus should emit loaded state with correct status',
      build: buildBloc,
      expect: () => [
        isA<CloudSyncLoaded>().having((s) => s.status, 'status', testStatus),
      ],
      verify: (_) {
        verify(() => cloudSyncRepository.getAvailableProvider()).called(1);
        verify(() => cloudSyncRepository.isAvailable(testProvider)).called(1);
        verify(
          () => cloudSyncRepository.isAuthenticated(testProvider),
        ).called(1);
      },
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'AuthenticateProvider success should reload status',
      build: buildBloc,
      act: (bloc) async {
        await bloc.stream.first; // wait for init load
        // Re-mock authenticated status for reload
        when(
          () => cloudSyncRepository.isAuthenticated(testProvider),
        ).thenAnswer((_) async => true);
        when(
          () => cloudSyncRepository.authenticate(testProvider),
        ).thenAnswer((_) async => CloudSyncResult.success());

        bloc.add(const AuthenticateProvider(testProvider));
      },
      expect: () => [
        isA<CloudSyncLoaded>(), // Init load
        // Syncing state
        isA<CloudSyncLoaded>().having((s) => s.isSyncing, 'isSyncing', true),
        // Reloaded status (authenticated)
        isA<CloudSyncLoaded>()
            .having((s) => s.status.isAuthenticated, 'isAuthenticated', true)
            .having((s) => s.isSyncing, 'isSyncing', false),
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'AuthenticateProvider failure should emit error',
      build: buildBloc,
      skip: 1, // Skip init load
      act: (bloc) async {
        await bloc.stream.first;
        when(
          () => cloudSyncRepository.authenticate(testProvider),
        ).thenAnswer((_) async => CloudSyncResult.failure('Auth Failed'));

        bloc.add(const AuthenticateProvider(testProvider));
      },
      expect: () => [
        isA<CloudSyncLoaded>().having((s) => s.isSyncing, 'isSyncing', true),
        isA<CloudSyncLoaded>()
            .having((s) => s.isSyncing, 'isSyncing', false)
            .having((s) => s.toastMessage, 'error msg', 'Auth Failed'),
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'SignOutProvider should call repository and reload status',
      build: () {
        // Start authenticated
        when(
          () => cloudSyncRepository.isAuthenticated(testProvider),
        ).thenAnswer((_) async => true);
        return buildBloc();
      },
      skip: 1, // Skip init load
      act: (bloc) async {
        await bloc.stream.first;
        when(
          () => cloudSyncRepository.signOut(testProvider),
        ).thenAnswer((_) async {});
        // Mock signed out status for reload
        when(
          () => cloudSyncRepository.isAuthenticated(testProvider),
        ).thenAnswer((_) async => false);

        bloc.add(const SignOutProvider(testProvider));
      },
      expect: () => [
        isA<CloudSyncLoaded>().having(
          (s) => s.status.isAuthenticated,
          'signed out',
          false,
        ),
      ],
      verify: (_) {
        verify(() => cloudSyncRepository.signOut(testProvider)).called(1);
      },
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'UploadToCloud success should emit completion and reload',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        when(
          () => cloudSyncRepository.uploadData(testProvider),
        ).thenAnswer((_) async => CloudSyncResult.success());

        bloc.add(const UploadToCloud());
      },
      expect: () => [
        isA<CloudSyncLoaded>().having((s) => s.isSyncing, 'start upload', true),
        isA<CloudSyncLoaded>()
            .having((s) => s.isSyncing, 'end upload', false)
            .having(
              (s) => s.toastMessage,
              'msg',
              contains('Complete'),
            ), // Depends on localization
        isA<CloudSyncLoaded>(), // Reload
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'DownloadFromCloud success should emit completion and reload',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        when(
          () => cloudSyncRepository.downloadData(testProvider),
        ).thenAnswer((_) async => CloudSyncResult.success());

        bloc.add(const DownloadFromCloud());
      },
      expect: () => [
        isA<CloudSyncLoaded>().having(
          (s) => s.isSyncing,
          'start download',
          true,
        ),
        isA<CloudSyncLoaded>()
            .having((s) => s.isSyncing, 'end download', false)
            .having((s) => s.toastMessage, 'msg', contains('Complete')),
        isA<CloudSyncLoaded>(), // Reload
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'ClearLocalData success',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        when(() => vehicleRepository.removeAll()).thenAnswer((_) async => true);
        bloc.add(const ClearLocalData());
      },
      expect: () => [
        isA<CloudSyncLoaded>().having((s) => s.isSyncing, 'start clear', true),
        isA<CloudSyncLoaded>()
            .having((s) => s.isSyncing, 'end clear', false)
            .having((s) => s.toastMessage, 'msg', contains('Complete')),
      ],
      verify: (_) {
        verify(() => vehicleRepository.removeAll()).called(1);
      },
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'DeleteCloudBackup success',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        when(
          () => cloudSyncRepository.deleteBackup(testProvider),
        ).thenAnswer((_) async => CloudSyncResult.success());
        bloc.add(const DeleteCloudBackup());
      },
      expect: () => [
        isA<CloudSyncLoaded>().having((s) => s.isSyncing, 'start delete', true),
        isA<CloudSyncLoaded>()
            .having((s) => s.isSyncing, 'end delete', false)
            .having((s) => s.toastMessage, 'msg', contains('Complete')),
        isA<CloudSyncLoaded>(), // Reload
      ],
    );
  });
}
