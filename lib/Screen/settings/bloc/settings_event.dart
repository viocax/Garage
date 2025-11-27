sealed class SettingsEvent {
  const SettingsEvent();
}

// Initial load
final class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// Toggle sound
final class ToggleSound extends SettingsEvent {
  const ToggleSound();
}

// Change speed unit
final class ChangeSpeedUnit extends SettingsEvent {
  final String unit;
  const ChangeSpeedUnit(this.unit);
}

// Change distance unit
final class ChangeDistanceUnit extends SettingsEvent {
  final String unit;
  const ChangeDistanceUnit(this.unit);
}

// Change map type
final class ChangeMapType extends SettingsEvent {
  final String type;
  const ChangeMapType(this.type);
}

// Toggle speed cameras
final class ToggleSpeedCameras extends SettingsEvent {
  const ToggleSpeedCameras();
}

// Toggle average speed
final class ToggleAverageSpeed extends SettingsEvent {
  const ToggleAverageSpeed();
}

// Toggle data collection
final class ToggleDataCollection extends SettingsEvent {
  const ToggleDataCollection();
}

// Export data
final class ExportData extends SettingsEvent {
  const ExportData();
}

// Clear data
final class ClearData extends SettingsEvent {
  const ClearData();
}
