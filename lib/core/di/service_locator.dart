import 'package:garage/core/repositories/local_user_settings_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart'
    show UserSettingsRepository;
import 'package:garage/core/repositories/vehicle_repository.dart';
import 'package:garage/core/repositories/local_vehicle_repository.dart';
import 'package:garage/core/repositories/cloud_sync_repository.dart';
import 'package:garage/core/repositories/local_cloud_sync_repository.dart';
import 'package:garage/core/repositories/app_open_ad_repository.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/local_ad_repository.dart';
import 'package:garage/core/service/ad/ad_service.dart';
import 'package:garage/core/service/ad/mobile_ad_service.dart';
import 'package:get_it/get_it.dart';
import '../service/isar_service.dart';
import '../service/network/http_service.dart';
import '../service/location/location_service.dart';
import '../service/shared_preferences/shared_preferences_service.dart';
import '../service/tts/tts_service.dart';
import '../service/cloud_sync/icloud_sync_service.dart';
import '../service/cloud_sync/google_drive_sync_service.dart';
import '../repositories/speed_camera_repository.dart';
import '../repositories/local_speed_camera_repository.dart';

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
  getIt.registerLazySingleton<ICloudSyncService>(() => ICloudSyncService());
  getIt.registerLazySingleton<GoogleDriveSyncService>(
    () => GoogleDriveSyncService(),
  );

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
  ICloudSyncService get iCloudSync => _getIt<ICloudSyncService>();
  GoogleDriveSyncService get googleDriveSync =>
      _getIt<GoogleDriveSyncService>();
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
