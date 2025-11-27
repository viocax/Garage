sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoaded extends SettingsState {
  final bool isSoundEnabled;
  final String speedUnit; // 'km/h' or 'mph'
  final String distanceUnit; // 'km' or 'mi'
  final String mapType; // 'standard', 'satellite', 'hybrid'
  final bool showSpeedCameras;
  final bool showAverageSpeed;
  final bool allowDataCollection;

  const SettingsLoaded({
    required this.isSoundEnabled,
    required this.speedUnit,
    required this.distanceUnit,
    required this.mapType,
    required this.showSpeedCameras,
    required this.showAverageSpeed,
    required this.allowDataCollection,
  });

  SettingsLoaded copyWith({
    bool? isSoundEnabled,
    String? speedUnit,
    String? distanceUnit,
    String? mapType,
    bool? showSpeedCameras,
    bool? showAverageSpeed,
    bool? allowDataCollection,
  }) {
    return SettingsLoaded(
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      speedUnit: speedUnit ?? this.speedUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      mapType: mapType ?? this.mapType,
      showSpeedCameras: showSpeedCameras ?? this.showSpeedCameras,
      showAverageSpeed: showAverageSpeed ?? this.showAverageSpeed,
      allowDataCollection: allowDataCollection ?? this.allowDataCollection,
    );
  }
}
