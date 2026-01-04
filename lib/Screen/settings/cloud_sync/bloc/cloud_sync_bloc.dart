import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/repositories/cloud_sync_repository.dart';
import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';

import 'cloud_sync_event.dart';
import 'cloud_sync_state.dart';

class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
  final CloudSyncRepository _repository;

  CloudSyncBloc({CloudSyncRepository? repository})
    : _repository = repository ?? getIt.repo.cloudSync,
      super(const CloudSyncInitial()) {
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
      case SelectProvider(:final provider):
        _onSelectProvider(provider, emit);
      case AuthenticateProvider(:final provider):
        await _onAuthenticate(provider, emit);
      case SignOutProvider(:final provider):
        await _onSignOut(provider, emit);
      case UploadToCloud():
        await _onUpload(emit);
      case DownloadFromCloud():
        await _onDownload(emit);
    }
  }

  Future<void> _onLoadStatus(Emitter<CloudSyncState> emit) async {
    final availableProviders = _repository.getAvailableProviders();
    final providerStatuses = <ProviderStatus>[];

    for (final provider in availableProviders) {
      final isAvailable = await _repository.isAvailable(provider);
      final isAuthenticated = isAvailable
          ? await _repository.isAuthenticated(provider)
          : false;
      final lastSync = isAuthenticated
          ? await _repository.getLastSyncTime(provider)
          : null;

      providerStatuses.add(
        ProviderStatus(
          provider: provider,
          isAvailable: isAvailable,
          isAuthenticated: isAuthenticated,
          lastSyncTime: lastSync,
        ),
      );
    }

    final selectedProvider =
        (providerStatuses.length == 1 && providerStatuses.first.isAuthenticated)
        ? providerStatuses.first.provider
        : null;

    emit(
      CloudSyncLoaded(
        providers: providerStatuses,
        selectedProvider: selectedProvider,
      ),
    );
  }

  void _onSelectProvider(CloudProvider provider, Emitter<CloudSyncState> emit) {
    final currentState = state;
    if (currentState is CloudSyncLoaded) {
      emit(currentState.copyWith(selectedProvider: provider));
    }
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
        syncMessage: 'cloudSync.loggingIn'.tr(),
      ),
    );

    final result = await _repository.authenticate(provider);

    if (result.success) {
      // Reload status to update auth state
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          errorMessage: result.errorMessage ?? 'cloudSync.loginFailed'.tr(),
        ),
      );
    }
  }

  Future<void> _onSignOut(
    CloudProvider provider,
    Emitter<CloudSyncState> emit,
  ) async {
    await _repository.signOut(provider);
    add(const LoadCloudSyncStatus());
  }

  Future<void> _onUpload(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;
    if (currentState.selectedProvider == null) {
      emit(
        currentState.copyWith(
          errorMessage: 'cloudSync.selectServiceFirst'.tr(),
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        isSyncing: true,
        syncMessage: 'cloudSync.uploading'.tr(),
      ),
    );

    final result = await _repository.uploadData(currentState.selectedProvider!);

    if (result.success) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          syncMessage: 'cloudSync.uploadComplete'.tr(),
        ),
      );
      // Reload to update last sync time
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          errorMessage: result.errorMessage ?? 'cloudSync.uploadFailed'.tr(),
        ),
      );
    }
  }

  Future<void> _onDownload(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;
    if (currentState.selectedProvider == null) {
      emit(
        currentState.copyWith(
          errorMessage: 'cloudSync.selectServiceFirst'.tr(),
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        isSyncing: true,
        syncMessage: 'cloudSync.downloading'.tr(),
      ),
    );

    final result = await _repository.downloadData(
      currentState.selectedProvider!,
    );

    if (result.success) {
      emit(
        currentState.copyWith(
          isSyncing: false,
          syncMessage: 'cloudSync.downloadComplete'.tr(),
        ),
      );
      add(const LoadCloudSyncStatus());
    } else {
      emit(
        currentState.copyWith(
          isSyncing: false,
          errorMessage: result.errorMessage ?? 'cloudSync.downloadFailed'.tr(),
        ),
      );
    }
  }
}
