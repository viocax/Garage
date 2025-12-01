import 'package:garage/core/service/location/location_service.dart';
import 'speed_camera.dart';

class NearSpeedCamera {
  final SpeedCamera speedCamera;
  final LatLng currentLocation;
  final double currentSpeed;

  NearSpeedCamera({
    required this.speedCamera,
    required this.currentLocation,
    required this.currentSpeed,
  });

  double get distance => speedCamera.distanceTo(
    currentLocation.latitude,
    currentLocation.longitude,
  );
}
