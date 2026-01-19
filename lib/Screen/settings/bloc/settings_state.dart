import 'package:equatable/equatable.dart';

enum SettingsAction { none, goToSpeedSetting, showStopTrackingAlert }

class SettingsState extends Equatable {
  final bool isPro;
  final SettingsAction action;
  final String? errorMessage;
  final String appVersion;

  const SettingsState({
    this.isPro = false,
    this.action = SettingsAction.none,
    this.errorMessage,
    this.appVersion = '',
  });

  @override
  List<Object?> get props => [isPro, action, errorMessage, appVersion];

  SettingsState copyWith({
    bool? isPro,
    SettingsAction? action,
    String? errorMessage,
    bool clearError = false,
    String? appVersion,
  }) {
    return SettingsState(
      isPro: isPro ?? this.isPro,
      action: action ?? this.action,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
