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

final class ClickSpeedSetting extends SettingsEvent {
  const ClickSpeedSetting();
}

final class StopTracking extends SettingsEvent {
  const StopTracking();
}

// Watch ad for ticket
final class WatchAdForTicket extends SettingsEvent {
  const WatchAdForTicket();
}

// Watch ad for banner removal
final class WatchAdForBannerRemoval extends SettingsEvent {
  const WatchAdForBannerRemoval();
}
