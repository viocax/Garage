import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/repositories/cloud_sync_repository.dart';
import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';

import 'cloud_sync_event.dart';
import 'cloud_sync_state.dart';
import 'package:garage/core/repositories/vehicle_repository.dart';

class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
  final CloudSyncRepository _cloudSyncRepository = getIt.repo.cloudSync;
  final VehicleRepository _vehicleRepository = getIt.repo.vehicle;

  CloudSyncBloc() : super(const CloudSyncInitial()) {
    on<CloudSyncEvent>(_onEvent);
    add(const LoadCloudSyncStatus());
  }

  Future<void> _onEvent(
    CloudSyncEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    switch (event) {
      case LoadCloudSyncStatus():
        await _onLoadStatus(emit);
      case AuthenticateProvider(:final provider):
        await _onAuthenticate(provider, emit);
      case SignOutProvider(:final provider):
        await _onSignOut(provider, emit);
      case UploadToCloud():
        await _onUpload(emit);
      case DownloadFromCloud():
        await _onDownload(emit);
      case ClearLocalData():
        await _onClearLocalData(emit);
      case DeleteCloudBackup():
        await _onDeleteBackup(emit);
    }
  }

  Future<void> _onLoadStatus(Emitter<CloudSyncState> emit) async {
    final provider = _cloudSyncRepository.getAvailableProvider();
    

    final isAvailable = await _cloudSyncRepository.isAvailable(provider);
    final isAuthenticated = isAvailable
        ? await _cloudSyncRepository.isAuthenticated(provider)
        : false;
    final lastSync = isAuthenticated
        ? await _cloudSyncRepository.getLastSyncTime(provider)
        : null;

    final providerStatuses = ProviderStatus(
        provider: provider,
        isAvailable: isAvailable,
        isAuthenticated: isAuthenticated,
        lastSyncTime: lastSync,
      );


    emit(
      CloudSyncLoaded(
        status: providerStatuses,
        isPro: false,
      ),
    );
  }


  Future<void> _onAuthenticate(
    CloudProvider provider,
    Emitter<CloudSyncState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;

    emit(
      currentState.copyWith(
        isSyncing: true,
        toastMessage: 'cloudSync.loggingIn'.tr(),
      ),
    );

    final result = await _cloudSyncRepository.authenticate(provider);

    if (result.success) {
      // Reload status to update auth state
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: result.errorMessage ?? 'cloudSync.loginFailed'.tr(),
        ),
      );
    }
  }

  Future<void> _onSignOut(
    CloudProvider provider,
    Emitter<CloudSyncState> emit,
  ) async {
    await _cloudSyncRepository.signOut(provider);
    add(const LoadCloudSyncStatus());
  }

  Future<void> _onUpload(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;

    emit(
      currentState.copyWith(
        isSyncing: true,
        toastMessage: 'cloudSync.uploading'.tr(),
      ),
    );

    final result = await _cloudSyncRepository.uploadData(currentState.status.provider);

    if (result.success) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: 'cloudSync.uploadComplete'.tr(),
        ),
      );
      // Reload to update last sync time
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: result.errorMessage ?? 'cloudSync.uploadFailed'.tr(),
        ),
      );
    }
  }

  Future<void> _onDownload(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;

    emit(
      currentState.copyWith(
        isSyncing: true,
        toastMessage: 'cloudSync.downloading'.tr(),
      ),
    );

    final result = await _cloudSyncRepository.downloadData(
      currentState.status.provider,
    );

    if (result.success) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: 'cloudSync.downloadComplete'.tr(),
        ),
      );
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: result.errorMessage ?? 'cloudSync.downloadFailed'.tr(),
        ),
      );
    }
  }

  Future<void> _onClearLocalData(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;

    emit(
      currentState.copyWith(
        isSyncing: true,
        toastMessage: 'cloudSync.clearing'.tr(),
      ),
    );

    final success = await _vehicleRepository.removeAll();
    if (success) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: 'cloudSync.clearComplete'.tr(),
        ),
      );
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: 'cloudSync.clearFailed'.tr(),
        ),
      );
    }
  }

  Future<void> _onDeleteBackup(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;

    emit(
      currentState.copyWith(
        isSyncing: true,
        toastMessage: 'cloudSync.deleting'.tr(),
      ),
    );

    final result = await _cloudSyncRepository.deleteBackup(
      currentState.status.provider,
    );

    if (result.success) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: 'cloudSync.deleteComplete'.tr(),
        ),
      );
      // Reload to update last sync time (will be null after deletion)
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          toastMessage: result.errorMessage ?? 'cloudSync.deleteFailed'.tr(),
        ),
      );
    }
  }
}
