import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'cloud_sync_event.dart';
import 'cloud_sync_state.dart';

class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
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
    final availableProviders = CloudSyncServiceFactory.getAvailableProviders();
    final providerStatuses = <ProviderStatus>[];

    for (final provider in availableProviders) {
      final service = CloudSyncServiceFactory.getService(provider);
      final isAvailable = await service.isAvailable();
      final isAuthenticated =
          isAvailable ? await service.isAuthenticated() : false;
      final lastSync =
          isAuthenticated ? await service.getLastSyncTime() : null;

      providerStatuses.add(ProviderStatus(
        provider: provider,
        isAvailable: isAvailable,
        isAuthenticated: isAuthenticated,
        lastSyncTime: lastSync,
      ));
    }

    emit(CloudSyncLoaded(providers: providerStatuses));
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

    emit(currentState.copyWith(isSyncing: true, syncMessage: '正在登入...'));

    final service = CloudSyncServiceFactory.getService(provider);
    final result = await service.authenticate();

    if (result.success) {
      // Reload status to update auth state
      add(const LoadCloudSyncStatus());
    } else {
      emit(currentState.copyWith(
        isSyncing: false,
        errorMessage: result.errorMessage ?? '登入失敗',
      ));
    }
  }

  Future<void> _onSignOut(
    CloudProvider provider,
    Emitter<CloudSyncState> emit,
  ) async {
    final service = CloudSyncServiceFactory.getService(provider);
    await service.signOut();
    add(const LoadCloudSyncStatus());
  }

  Future<void> _onUpload(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;
    if (currentState.selectedProvider == null) {
      emit(currentState.copyWith(errorMessage: '請先選擇雲端服務'));
      return;
    }

    emit(currentState.copyWith(isSyncing: true, syncMessage: '正在上傳資料...'));

    final service =
        CloudSyncServiceFactory.getService(currentState.selectedProvider!);
    final result = await service.uploadData();

    if (result.success) {
      emit(currentState.copyWith(
        isSyncing: false,
        syncMessage: '上傳完成！',
      ));
      // Reload to update last sync time
      add(const LoadCloudSyncStatus());
    } else {
      emit(currentState.copyWith(
        isSyncing: false,
        errorMessage: result.errorMessage ?? '上傳失敗',
      ));
    }
  }

  Future<void> _onDownload(Emitter<CloudSyncState> emit) async {
    final currentState = state;
    if (currentState is! CloudSyncLoaded) return;
    if (currentState.selectedProvider == null) {
      emit(currentState.copyWith(errorMessage: '請先選擇雲端服務'));
      return;
    }

    emit(currentState.copyWith(isSyncing: true, syncMessage: '正在下載資料...'));

    final service =
        CloudSyncServiceFactory.getService(currentState.selectedProvider!);
    final result = await service.downloadData();

    if (result.success) {
      emit(currentState.copyWith(
        isSyncing: false,
        syncMessage: '下載完成！',
      ));
      add(const LoadCloudSyncStatus());
    } else {
      emit(currentState.copyWith(
        isSyncing: false,
        errorMessage: result.errorMessage ?? '下載失敗',
      ));
    }
  }
}
