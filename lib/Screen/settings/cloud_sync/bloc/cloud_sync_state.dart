import 'package:equatable/equatable.dart';
import 'package:garage/core/core.dart';

/// Provider status for UI display
class ProviderStatus extends Equatable {
  final CloudProvider provider;
  final bool isAvailable;
  final bool isAuthenticated;
  final DateTime? lastSyncTime;

  const ProviderStatus({
    required this.provider,
    required this.isAvailable,
    required this.isAuthenticated,
    this.lastSyncTime,
  });

  @override
  List<Object?> get props => [
    provider,
    isAvailable,
    isAuthenticated,
    lastSyncTime,
  ];
}

sealed class CloudSyncState extends Equatable {
  const CloudSyncState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state
final class CloudSyncInitial extends CloudSyncState {
  const CloudSyncInitial();
}

/// Loaded state with provider information
final class CloudSyncLoaded extends CloudSyncState {
  final List<ProviderStatus> providers;
  final CloudProvider? selectedProvider;
  final bool isSyncing;
  final String? syncMessage;
  final String? errorMessage;
  final bool isPro;

  const CloudSyncLoaded({
    required this.providers,
    this.selectedProvider,
    this.isSyncing = false,
    this.syncMessage,
    this.errorMessage,
    this.isPro = false,
  });

  @override
  List<Object?> get props => [
    providers,
    selectedProvider,
    isSyncing,
    syncMessage,
    errorMessage,
    isPro,
  ];

  CloudSyncLoaded copyWith({
    List<ProviderStatus>? providers,
    CloudProvider? selectedProvider,
    bool? isSyncing,
    String? syncMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearSelected = false,
    bool clearSyncMessage = false,
    bool? isPro,
  }) {
    return CloudSyncLoaded(
      providers: providers ?? this.providers,
      selectedProvider: clearSelected
          ? null
          : (selectedProvider ?? this.selectedProvider),
      isSyncing: isSyncing ?? this.isSyncing,
      syncMessage: clearSyncMessage ? null : (syncMessage ?? this.syncMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPro: isPro ?? this.isPro,
    );
  }
}
