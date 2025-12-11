import 'package:garage/core/models/speed_unit.dart';

sealed class SpeedDetectionSettingsEvent {
  const SpeedDetectionSettingsEvent();
}

// Initial load
final class LoadSpeedDetectionSettings extends SpeedDetectionSettingsEvent {
  const LoadSpeedDetectionSettings();
}

// Change speed unit
final class ChangeSpeedUnit extends SpeedDetectionSettingsEvent {
  final SpeedUnit unit;
  const ChangeSpeedUnit(this.unit);
}

// Voice alert settings
final class ToggleVoiceAlert extends SpeedDetectionSettingsEvent {
  const ToggleVoiceAlert();
}

final class ChangeVoiceVolume extends SpeedDetectionSettingsEvent {
  final double percentage;
  const ChangeVoiceVolume(this.percentage);
}

final class PlayTestVoice extends SpeedDetectionSettingsEvent {
  const PlayTestVoice();
}

// Alert settings
final class ChangeAlertDistance extends SpeedDetectionSettingsEvent {
  final int distance;
  const ChangeAlertDistance(this.distance);
}

// Location permission
final class CheckLocationPermission extends SpeedDetectionSettingsEvent {
  const CheckLocationPermission();
}

final class RequestLocationPermission extends SpeedDetectionSettingsEvent {
  const RequestLocationPermission();
}
