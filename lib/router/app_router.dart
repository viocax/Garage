import 'package:flutter/material.dart';
import 'package:garage/screen/settings/settings_page.dart';
import 'package:garage/screen/settings/static_content_page.dart';
import 'package:garage/core/utils/app_documents.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:garage/screen/settings/speed_detection_settings/speed_detection_settings_page.dart';
import 'package:garage/screen/settings/vehicle_management/vehicle_management_page.dart';
import 'package:garage/screen/settings/cloud_sync/cloud_sync_page.dart';
import 'package:garage/screen/records/records_page.dart';
import 'package:garage/screen/speed/speedCamera/speed_camera_page.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/screen/app/home/garage_home_page.dart';
import 'package:garage/screen/app/launch/launch_page.dart';
import 'package:garage/screen/records/add_record/add_record_page.dart';
import 'package:garage/screen/records/add_vehicle/add_vehicle_page.dart';
import 'package:garage/screen/records/all_records/all_records_page.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/screen/premium/premium_page.dart';

/// 路由路徑枚舉，統一管理所有路由的 path 和 name
class AppPath {
  final String name;
  final AppPath? previous;

  const AppPath({required this.name, this.previous});

  // static instances
  static final launch = AppPath(name: 'launch');
  static final home = AppPath(name: 'home');

  static final speedometer = AppPath(name: 'speedometer', previous: home);

  static final records = AppPath(name: 'records', previous: home);

  static final addRecord = AppPath(name: 'addRecord', previous: records);

  static final addVehicle = AppPath(name: 'addVehicle', previous: records);

  static final allRecords = AppPath(name: 'allRecords', previous: records);

  static final settings = AppPath(name: 'settings', previous: home);

  static final vehicleManagement = AppPath(
    name: 'vehicleManagement',
    previous: settings,
  );

  static final speedDetectionSettings = AppPath(
    name: 'speedDetectionSettings',
    previous: settings,
  );

  static final cloudSync = AppPath(name: 'cloudSync', previous: settings);

  static final premium = AppPath(name: 'premium', previous: settings);

  static final termsOfService = AppPath(
    name: 'termsOfService',
    previous: settings,
  );

  static final privacyPolicy = AppPath(
    name: 'privacyPolicy',
    previous: settings,
  );

  static final openSourceLicenses = AppPath(
    name: 'openSourceLicenses',
    previous: settings,
  );

  /// compute full path
  String get path {
    if (previous == null) {
      return '/$name';
    }
    return '${previous!.path}/$name';
  }
}

/// 應用程式的路由配置
class AppRouter {
  /// Root navigator key - 用於全屏路由
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// 建立並返回 GoRouter 實例
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppPath.launch.path,
      routes: [
        GoRoute(
          path: AppPath.launch.path,
          name: AppPath.launch.name,
          builder: (context, state) => const LaunchPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) {
            return GarageHomePage(shell: shell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppPath.speedometer.path,
                  name: AppPath.speedometer.name,
                  builder: (context, state) => const SpeedCameraPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppPath.records.path,
                  name: AppPath.records.name,
                  builder: (context, state) => const RecordsPage(),
                  routes: [
                    GoRoute(
                      path: AppPath.addRecord.path,
                      name: AppPath.addRecord.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final vehicle =
                            state.extra as Vehicle? ?? Vehicle.empty();
                        return AddRecordPage(vehicle: vehicle);
                      },
                    ),
                    GoRoute(
                      path: AppPath.addVehicle.path,
                      name: AppPath.addVehicle.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: const AddVehiclePage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: child,
                                );
                              },
                        );
                      },
                    ),
                    GoRoute(
                      path: AppPath.allRecords.path,
                      name: AppPath.allRecords.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final vehicle = state.extra as Vehicle;
                        return AllRecordsPage(vehicle: vehicle);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppPath.settings.path,
                  name: AppPath.settings.name,
                  builder: (context, state) => const SettingsPage(),
                  routes: [
                    GoRoute(
                      path: AppPath.vehicleManagement.path,
                      name: AppPath.vehicleManagement.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) =>
                          const VehicleManagementPage(),
                    ),
                    GoRoute(
                      path: AppPath.speedDetectionSettings.path,
                      name: AppPath.speedDetectionSettings.name,
                      // 使用 root navigator，跳過 shell 直接全屏顯示
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) =>
                          const SpeedDetectionSettingsPage(),
                    ),
                    GoRoute(
                      path: AppPath.cloudSync.path,
                      name: AppPath.cloudSync.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const CloudSyncPage(),
                    ),
                    GoRoute(
                      path: AppPath.termsOfService.path,
                      name: AppPath.termsOfService.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => StaticContentPage(
                        title: 'settings.termsOfService'.tr(),
                        markdownContent: AppDocuments.termsOfService,
                      ),
                    ),
                    GoRoute(
                      path: AppPath.privacyPolicy.path,
                      name: AppPath.privacyPolicy.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => StaticContentPage(
                        title: 'settings.privacyPolicy'.tr(),
                        markdownContent: AppDocuments.privacyPolicy,
                      ),
                    ),
                    GoRoute(
                      path: AppPath.openSourceLicenses.path,
                      name: AppPath.openSourceLicenses.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => StaticContentPage(
                        title: 'settings.openSourceLicenses'.tr(),
                        markdownContent: AppDocuments.openSourceLicenses,
                      ),
                    ),
                    GoRoute(
                      path: AppPath.premium.path,
                      name: AppPath.premium.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const PremiumPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

extension AppRouterExtension on BuildContext {
  /// 导航到指定路径
  void goPath(AppPath path, {Object? extra}) {
    GoRouter.of(this).goNamed(path.name, extra: extra);
  }

  /// 导航到指定路径并等待返回结果
  Future<T?> goPathWithResult<T>(AppPath path, {Object? extra}) async {
    return await GoRouter.of(this).pushNamed<T>(path.name, extra: extra);
  }
}
