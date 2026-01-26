import 'package:equatable/equatable.dart';
import 'package:garage/core/models/speed_camera_model.dart';
import 'package:garage/core/models/speed_unit.dart';

sealed class SpeedState extends Equatable {
  const SpeedState();

  @override
  List<Object?> get props => [];
}

// 位置數據
class LocationData extends Equatable {
  final double latitude;
  final double longitude;

  const LocationData({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

// 速度數據狀態
final class SpeedData extends SpeedState {
  final SpeedUnit unit; // 速度單位
  final String? lowerSpeed; // 最低速限
  final String? upperSpeed; // 最高速限
  final int alertDistance; // 警告距離
  final bool isDetecting; // 是否正在偵測
  final bool showPermissionAlert; // 是否顯示權限警示
  final String? errorMessage; // 錯誤訊息（用於顯示 Toast）

  // Getter - 當 lat/lng 都是 0.0 時表示還沒有取得位置
  LocationData? get currentLocation {
    if (model.latitude == 0.0 && model.longitude == 0.0) {
      return null;
    }
    return LocationData(latitude: model.latitude, longitude: model.longitude);
  }

  bool get isOverSpeed => model.isOverSpeed;
  bool get isInSector => model.isInSector;

  /// 是否應該顯示警告（超速且在偵測範圍內）
  bool get isWarning => isOverSpeed && isInSector;

  bool get isStartAnimation => model.currentSpeed > 0;
  bool get isInterval => model.isInterval;
  double get averageSpeed => model.averageSpeed;
  double get remainingDistance => model.remainingDistance;

  String get displaySpeed {
    switch (unit) {
      case SpeedUnit.kmh:
        return model.currentSpeed.round().toString();
      case SpeedUnit.mph:
        return model.currentSpeed.mile.round().toString();
    }
  }

  final SpeedCameraModel model;
  final List<LocationData> cameraLocations;

  const SpeedData({
    required this.model,
    this.cameraLocations = const [],
    required this.unit,
    required this.alertDistance,
    this.lowerSpeed,
    this.upperSpeed,
    this.isDetecting = false,
    this.showPermissionAlert = false,
    this.errorMessage,
  });

  SpeedData copyWith({
    SpeedCameraModel? model,
    List<LocationData>? cameraLocations,
    SpeedUnit? unit,
    int? alertDistance,
    String? lowerSpeed,
    String? upperSpeed,
    bool? isDetecting,
    bool? showPermissionAlert,
    String? errorMessage,
  }) {
    return SpeedData(
      model: model ?? this.model,
      cameraLocations: cameraLocations ?? this.cameraLocations,
      unit: unit ?? this.unit,
      alertDistance: alertDistance ?? this.alertDistance,
      lowerSpeed: lowerSpeed ?? this.lowerSpeed,
      upperSpeed: upperSpeed ?? this.upperSpeed,
      isDetecting: isDetecting ?? this.isDetecting,
      showPermissionAlert: showPermissionAlert ?? this.showPermissionAlert,
      errorMessage: errorMessage,
    );
  }

  SpeedData copyDetailWith({
    double? speed,
    int? alertDistance,
    SpeedUnit? unit,
    String? lowerSpeed,
    String? upperSpeed,
    bool? isOverSpeed,
    bool? isDetecting,
    List<LocationData>? cameraLocations,
  }) {
    return SpeedData(
      model: model.copyWith(
        currentSpeed: speed,
        distance: alertDistance?.toDouble(),
        isOverSpeed: isOverSpeed,
      ),
      cameraLocations: cameraLocations ?? this.cameraLocations,
      unit: unit ?? this.unit,
      alertDistance: alertDistance ?? this.alertDistance,
      lowerSpeed: lowerSpeed ?? this.lowerSpeed,
      upperSpeed: upperSpeed ?? this.upperSpeed,
      isDetecting: isDetecting ?? this.isDetecting,
    );
  }

  @override
  List<Object?> get props => [
    unit,
    lowerSpeed,
    upperSpeed,
    alertDistance,
    isDetecting,
    showPermissionAlert,
    errorMessage,
    model,
    cameraLocations,
  ];
}
