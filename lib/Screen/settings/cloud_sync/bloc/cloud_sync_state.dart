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
  final ProviderStatus status;
  final bool isSyncing;
  final String? toastMessage;
  final bool isPro;

  const CloudSyncLoaded({
    required this.status,
    this.isSyncing = false,
    this.toastMessage,
    this.isPro = false,
  });

  @override
  List<Object?> get props => [
    status,
    isSyncing,
    toastMessage,
    isPro,
  ];

  CloudSyncLoaded copyWith({
    ProviderStatus? status,
    bool? isSyncing,
    String? toastMessage,
    bool clearToast = false,
    bool? isPro,
  }) {
    return CloudSyncLoaded(
      status: status ?? this.status,
      isSyncing: isSyncing ?? this.isSyncing,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isPro: isPro ?? this.isPro,
    );
  }
}
