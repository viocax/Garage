import 'package:garage/core/models/speed_unit.dart';

sealed class SpeedDetectionSettingsState {
  const SpeedDetectionSettingsState();
}

final class SpeedDetectionSettingsInitial extends SpeedDetectionSettingsState {
  const SpeedDetectionSettingsInitial();
}

final class SpeedDetectionSettingsLoaded extends SpeedDetectionSettingsState {
  final SpeedUnit speedUnit; // 'km/h' or 'mph'

  // Voice alert settings
  final bool isVoiceAlertEnabled;
  final double voiceVolume; // 0.0 - 1.0
  final double voiceSpeechRate; // 0.0 - 1.0

  const SpeedDetectionSettingsLoaded({
    required this.speedUnit,
    required this.isVoiceAlertEnabled,
    required this.voiceVolume,
    required this.voiceSpeechRate,
  });

  SpeedDetectionSettingsLoaded copyWith({
    SpeedUnit? speedUnit,
    bool? isVoiceAlertEnabled,
    double? voiceVolume,
    double? voiceSpeechRate,
  }) {
    return SpeedDetectionSettingsLoaded(
      speedUnit: speedUnit ?? this.speedUnit,
      isVoiceAlertEnabled: isVoiceAlertEnabled ?? this.isVoiceAlertEnabled,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceSpeechRate: voiceSpeechRate ?? this.voiceSpeechRate,
    );
  }
}
