import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/garage_home_page.dart';
import 'package:garage/screen/app/launch/launch_page.dart';

/// 應用程式的路由配置
class AppRouter {
  /// 路由路徑
  static const String launch = '/';
  static const String home = '/home';

  /// 建立並返回 GoRouter 實例
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: launch,
      routes: [
        GoRoute(
          path: launch,
          name: 'launch',
          builder: (context, state) => const LaunchPage(),
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => BlocProvider(
            create: (context) => GarageHomeBloc(),
            child: const GarageHomePage(),
          ),
        ),
      ],
    );
  }
}
