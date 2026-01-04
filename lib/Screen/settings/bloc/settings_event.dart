sealed class SettingsEvent {
  const SettingsEvent();
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

// Send feedback
final class SendFeedback extends SettingsEvent {
  const SendFeedback();
}

final class LoadSettingsStatus extends SettingsEvent {
  const LoadSettingsStatus();
}

final class ResetSettingsAction extends SettingsEvent {
  const ResetSettingsAction();
}
