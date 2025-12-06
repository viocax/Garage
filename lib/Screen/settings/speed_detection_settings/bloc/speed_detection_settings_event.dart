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
  final double volume;
  const ChangeVoiceVolume(this.volume);
}

final class ChangeVoiceSpeechRate extends SpeedDetectionSettingsEvent {
  final double rate;
  const ChangeVoiceSpeechRate(this.rate);
}
