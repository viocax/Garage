import 'package:flutter/material.dart';
import 'package:garage/screen/settings/settings_page.dart';
import 'package:garage/screen/settings/speed_detection_settings/speed_detection_settings_page.dart';
import 'package:garage/screen/records/records_page.dart';
import 'package:garage/screen/speed/speedCamera/speed_camera_page.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/screen/app/home/garage_home_page.dart';
import 'package:garage/screen/app/launch/launch_page.dart';
import 'package:garage/screen/records/add_record/add_record_page.dart';
import 'package:garage/core/models/vehicle.dart';


/// 路由路徑枚舉，統一管理所有路由的 path 和 name
class AppPath {
  final String name;
  final AppPath? previous;

  const AppPath({
    required this.name,
    this.previous,
  });

  // static instances
  static final launch = AppPath(name: 'launch');
  static final home = AppPath(name: 'home');

  static final speedometer =
      AppPath(name: 'speedometer', previous: home);

  static final records =
      AppPath(name: 'records', previous: home);

  static final addRecord =
      AppPath(name: 'addRecord', previous: records);

  static final settings =
      AppPath(name: 'settings', previous: home);

  static final speedDetectionSettings =
      AppPath(name: 'speedDetectionSettings', previous: settings);

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
                      path: AppPath.speedDetectionSettings.path,
                      name: AppPath.speedDetectionSettings.name,
                      // 使用 root navigator，跳過 shell 直接全屏顯示
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const SpeedDetectionSettingsPage(),
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
