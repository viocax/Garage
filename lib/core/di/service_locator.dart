import 'package:get_it/get_it.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/launch/bloc/launch_bloc.dart';
import 'package:garage/screen/speed/speedCamera/bloc/speed_bloc.dart';
import 'package:garage/screen/speed/car3d/bloc/car_3d_bloc.dart';
import 'package:garage/screen/settings/bloc/settings_bloc.dart';
// import '../service/isar_service.dart'; // MARK: Isar 暫時不使用
import '../service/network/http_service.dart';
import '../service/location/location_service.dart';
import '../service/shared_preferences/shared_preferences_service.dart';
import '../repositories/speed_camera_repository.dart';
import '../repositories/local_speed_camera_repository.dart';
import 'package:flutter/material.dart';

final getIt = GetIt.instance;

/// 初始化依賴注入
Future<void> setupServiceLocator() async {
  // Service layer
  // getIt.registerLazySingleton<IsarService>(() => IsarService()); // MARK: Isar 暫時不使用
  getIt.registerLazySingleton<HttpService>(() => HttpService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService());

  // Repository layer
  getIt.registerLazySingleton<ISpeedCameraRepository>(() => LocalSpeedCameraRepository());

  // Bloc layer
  getIt.registerFactory<GarageHomeBloc>(() => GarageHomeBloc());
  getIt.registerFactoryParam<LaunchBloc, TickerProvider, void>(
    (vsync, _) => LaunchBloc(vsync),
  );
  getIt.registerFactory<SpeedBloc>(() => SpeedBloc());
  getIt.registerFactory<Car3DBloc>(() => Car3DBloc());
  getIt.registerFactory<SettingsBloc>(() => SettingsBloc());
}

/// 重置所有依賴（測試用）
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

// MARK: 目前沒有類似像Swift可以做到scope內部在宣告其他Type(inner class ..)
// 暫時這樣先處理
extension GetItExtensions on GetIt {
  BlocScopes get bloc => BlocScopes(this);
  ServiceScopes get service => ServiceScopes(this);
  RepositoryScopes get repo => RepositoryScopes(this);
}

class BlocScopes {
  final GetIt _getIt;
  BlocScopes(this._getIt);

  GarageHomeBloc get home => _getIt<GarageHomeBloc>();
  LaunchBloc launch(TickerProvider vsync) => _getIt<LaunchBloc>(param1: vsync);
  SpeedBloc get speed => _getIt<SpeedBloc>();
  Car3DBloc get car3d => _getIt<Car3DBloc>();
  SettingsBloc get settings => _getIt<SettingsBloc>();
}

class ServiceScopes {
  final GetIt _getIt;
  ServiceScopes(this._getIt);

  HttpService get network => _getIt<HttpService>();
  // IsarService get isarDB => _getIt<IsarService>(); // MARK: Isar 暫時不使用
  LocationService get location => _getIt<LocationService>();
  SharedPreferencesService get preferences => _getIt<SharedPreferencesService>();
}

class RepositoryScopes {
  final GetIt _getIt;
  RepositoryScopes(this._getIt);

  ISpeedCameraRepository get speedCamera => _getIt<ISpeedCameraRepository>();
}
