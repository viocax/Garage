
sealed class SettingsState {
  const SettingsState();
}

final class SettingsNormal extends SettingsState {
  const SettingsNormal();
}

final class GoToSpeedSetting extends SettingsState {
  const GoToSpeedSetting();
}

final class RemindUserStopTrackingAlert extends SettingsState {
  const RemindUserStopTrackingAlert();
}

final class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}