import 'package:equatable/equatable.dart';
import 'package:garage/core/models/speed_unit.dart';

sealed class SpeedDetectionSettingsState extends Equatable {
  const SpeedDetectionSettingsState();

  @override
  List<Object?> get props => [];
}

final class SpeedDetectionSettingsInitial extends SpeedDetectionSettingsState {
  const SpeedDetectionSettingsInitial();
}

final class SpeedDetectionSettingsLoaded extends SpeedDetectionSettingsState {
  final SpeedUnit speedUnit; // 'km/h' or 'mph'

  // Voice alert settings
  final bool isVoiceAlertEnabled;
  final double voiceVolumePercentage; // 0.0 - 1.0

  // Alert settings
  final int alertDistance; // 提前提醒距離（公尺）

  // Alert distance constraints (使用 static const 讓 initializer 可以存取)
  static const int minAlertDistance = 300;
  static const int maxAlertDistance = 1000;
  static const int alertDistanceStep = 100;
  int get alertDistanceDivisions =>
      (maxAlertDistance - minAlertDistance) ~/ alertDistanceStep;

  // Location permission
  final bool hasLocationPermission;

  SpeedDetectionSettingsLoaded({
    required this.speedUnit,
    required this.isVoiceAlertEnabled,
    required this.voiceVolumePercentage,
    required int alertDistance,
    required this.hasLocationPermission,
  }) : alertDistance = alertDistance.clamp(minAlertDistance, maxAlertDistance);

  SpeedDetectionSettingsLoaded copyWith({
    SpeedUnit? speedUnit,
    bool? isVoiceAlertEnabled,
    double? voiceVolumePercentage,
    double? voiceSpeechRate,
    String? voiceEngine,
    int? alertDistance,
    bool? hasLocationPermission,
  }) {
    return SpeedDetectionSettingsLoaded(
      speedUnit: speedUnit ?? this.speedUnit,
      isVoiceAlertEnabled: isVoiceAlertEnabled ?? this.isVoiceAlertEnabled,
      voiceVolumePercentage:
          voiceVolumePercentage ?? this.voiceVolumePercentage,
      alertDistance: alertDistance ?? this.alertDistance, // constructor 會自動驗證
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
    );
  }

  @override
  List<Object?> get props => [
    speedUnit,
    isVoiceAlertEnabled,
    voiceVolumePercentage,
    alertDistance,
    hasLocationPermission,
  ];
}
