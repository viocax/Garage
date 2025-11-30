import 'package:garage/core/models/speed_unit.dart';

sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoaded extends SettingsState {
  final SpeedUnit speedUnit; // 'km/h' or 'mph'

  // Voice alert settings
  final bool isVoiceAlertEnabled;
  final double voiceVolume; // 0.0 - 1.0
  final double voiceSpeechRate; // 0.0 - 1.0

  const SettingsLoaded({
    required this.speedUnit,
    required this.isVoiceAlertEnabled,
    required this.voiceVolume,
    required this.voiceSpeechRate,
  });

  SettingsLoaded copyWith({
    SpeedUnit? speedUnit,
    bool? isVoiceAlertEnabled,
    double? voiceVolume,
    double? voiceSpeechRate,
  }) {
    return SettingsLoaded(
      speedUnit: speedUnit ?? this.speedUnit,
      isVoiceAlertEnabled: isVoiceAlertEnabled ?? this.isVoiceAlertEnabled,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceSpeechRate: voiceSpeechRate ?? this.voiceSpeechRate,
    );
  }
}
