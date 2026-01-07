import 'dart:io';

import 'package:get_it/get_it.dart';

import '../repositories/repositories.dart';
import '../service/services.dart';

final getIt = GetIt.instance;

/// 初始化依賴注入
Future<void> setupServiceLocator() async {
  // Service layer
  getIt.registerLazySingleton<IsarService>(() => IsarService());
  getIt.registerLazySingleton<HttpService>(() => HttpService());
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(),
  ); // 使用預設的 GeolocatorWrapper
  getIt.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(),
  );
  getIt.registerLazySingleton<TtsService>(() => TtsService());

  // Cloud Sync Services (Singleton - 保持認證狀態)
  getIt.registerLazySingleton<CloudSyncService>(() {
    if (Platform.isIOS) {
      return ICloudSyncService();
    }
    return GoogleDriveSyncService();
  });

  // Ad Service
  getIt.registerLazySingleton<AdService>(() => MobileAdService());

  // Repository layer
  getIt.registerLazySingleton<ISpeedCameraRepository>(
    () => LocalSpeedCameraRepository(),
  );
  getIt.registerLazySingleton<UserSettingsRepository>(
    () => LocalUserSettingsRepository(),
  );
  getIt.registerLazySingleton<VehicleRepository>(
    () => LocalVehicleRepository(),
  );
  getIt.registerFactory<CloudSyncRepository>(() => LocalCloudSyncRepository());
  getIt.registerLazySingleton<AppOpenAdRepository>(
    () => AppOpenAdRepository(getIt<UserSettingsRepository>()),
  );
  getIt.registerLazySingleton<AdRepository>(
    () =>
        LocalAdRepository(getIt<AdService>(), getIt<UserSettingsRepository>()),
  );
}

/// 重置所有依賴（測試用）
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

// MARK: 目前沒有類似像Swift可以做到scope內部在宣告其他Type(inner class ..)
// 暫時這樣先處理
extension GetItExtensions on GetIt {
  // BlocScopes get bloc => BlocScopes(this);
  ServiceScopes get service => ServiceScopes(this);
  RepositoryScopes get repo => RepositoryScopes(this);
}

class ServiceScopes {
  final GetIt _getIt;
  ServiceScopes(this._getIt);

  HttpService get network => _getIt<HttpService>();
  IsarService get isarDB => _getIt<IsarService>();
  LocationService get location => _getIt<LocationService>();
  SharedPreferencesService get preferences =>
      _getIt<SharedPreferencesService>();
  TtsService get tts => _getIt<TtsService>();
  CloudSyncService get cloudSync => _getIt<CloudSyncService>();
  AdService get ad => _getIt<AdService>();
}

class RepositoryScopes {
  final GetIt _getIt;
  RepositoryScopes(this._getIt);

  ISpeedCameraRepository get speedCamera => _getIt<ISpeedCameraRepository>();
  UserSettingsRepository get userSettings => _getIt<UserSettingsRepository>();
  VehicleRepository get vehicle => _getIt<VehicleRepository>();
  CloudSyncRepository get cloudSync => _getIt<CloudSyncRepository>();
  AppOpenAdRepository get appOpenAd => _getIt<AppOpenAdRepository>();
  AdRepository get ad => _getIt<AdRepository>();
}
