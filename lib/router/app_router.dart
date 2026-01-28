import 'package:flutter/material.dart';
import 'package:garage/screen/settings/settings_page.dart';

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
import 'package:garage/screen/invoice_scanner/invoice_scanner_page.dart';
import 'package:garage/core/models/vehicle.dart';

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

  static final invoiceScanner = AppPath(
    name: 'invoiceScanner',
    previous: addRecord,
  );

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
          pageBuilder: (context, state, shell) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: GarageHomePage(shell: shell),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeIn,
                      ).animate(animation),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutQuart,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
            );
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
                        final vehicle = state.extra as Vehicle?;
                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: AddVehiclePage(vehicle: vehicle),
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
                    GoRoute(
                      path: AppPath.invoiceScanner.path,
                      name: AppPath.invoiceScanner.name,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const InvoiceScannerPage(),
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

  /// Push 到指定路径并等待返回结果
  Future<T?> pushPathWithResult<T>(AppPath path, {Object? extra}) async {
    return await GoRouter.of(this).pushNamed<T>(path.name, extra: extra);
  }

  /// 安全的 pop，如果无法 pop 则显示提示
  void safePop() {
    if (canPop()) {
      GoRouter.of(this).pop();
    } else {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text('common.error'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
