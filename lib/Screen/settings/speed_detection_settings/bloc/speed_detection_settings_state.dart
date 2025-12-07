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
  final String? voiceEngine; // TTS engine ID

  // Alert settings
  final int alertDistance; // 提前提醒距離（公尺）

  // Alert distance constraints (使用 static const 讓 initializer 可以存取)
  static const int minAlertDistance = 300;
  static const int maxAlertDistance = 1000;
  static const int alertDistanceStep = 100;
  int get alertDistanceDivisions => (maxAlertDistance - minAlertDistance) ~/ alertDistanceStep;

  // Location permission
  final bool hasLocationPermission;

  SpeedDetectionSettingsLoaded({
    required this.speedUnit,
    required this.isVoiceAlertEnabled,
    required this.voiceVolume,
    required this.voiceSpeechRate,
    this.voiceEngine,
    required int alertDistance,
    required this.hasLocationPermission,
  }) : alertDistance = alertDistance.clamp(minAlertDistance, maxAlertDistance);

  SpeedDetectionSettingsLoaded copyWith({
    SpeedUnit? speedUnit,
    bool? isVoiceAlertEnabled,
    double? voiceVolume,
    double? voiceSpeechRate,
    String? voiceEngine,
    int? alertDistance,
    bool? hasLocationPermission,
  }) {
    return SpeedDetectionSettingsLoaded(
      speedUnit: speedUnit ?? this.speedUnit,
      isVoiceAlertEnabled: isVoiceAlertEnabled ?? this.isVoiceAlertEnabled,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceSpeechRate: voiceSpeechRate ?? this.voiceSpeechRate,
      voiceEngine: voiceEngine ?? this.voiceEngine,
      alertDistance: alertDistance ?? this.alertDistance, // constructor 會自動驗證
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}
