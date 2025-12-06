sealed class SettingsEvent {
  const SettingsEvent();
}

// Export data
final class ExportData extends SettingsEvent {
  const ExportData();
}

// Clear data
final class ClearData extends SettingsEvent {
  const ClearData();
}
