sealed class SettingsEvent {
  const SettingsEvent();
}

// Initial load
final class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// Change speed unit
final class ChangeSpeedUnit extends SettingsEvent {
  final String unit;
  const ChangeSpeedUnit(this.unit);
}

// Export data
final class ExportData extends SettingsEvent {
  const ExportData();
}

// Clear data
final class ClearData extends SettingsEvent {
  const ClearData();
}

// Voice alert settings
final class ToggleVoiceAlert extends SettingsEvent {
  const ToggleVoiceAlert();
}

final class ChangeVoiceVolume extends SettingsEvent {
  final double volume;
  const ChangeVoiceVolume(this.volume);
}

final class ChangeVoiceSpeechRate extends SettingsEvent {
  final double rate;
  const ChangeVoiceSpeechRate(this.rate);
}
