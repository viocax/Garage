import 'package:geolocator/geolocator.dart';

abstract class GeolocatorInterface {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position> getCurrentPosition();
  Stream<Position> getPositionStream();
}

class GeolocatorWrapper implements GeolocatorInterface {
  final LocationSettings locationSettings;

  const GeolocatorWrapper({required this.locationSettings});

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position> getCurrentPosition() =>
      Geolocator.getCurrentPosition(locationSettings: locationSettings);

  @override
  Stream<Position> getPositionStream() =>
      Geolocator.getPositionStream(locationSettings: locationSettings);
}
