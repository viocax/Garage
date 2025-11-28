import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/router/app_router.dart';
import 'package:garage/screen/app/launch/bloc/launch_bloc.dart';
import 'package:garage/screen/app/launch/bloc/launch_state.dart';
import 'package:garage/theme/app_theme.dart';

/// 啟動頁面
///
/// 在應用啟動時顯示，執行初始化任務（如載入配置、呼叫 API 等）
/// 完成後自動跳轉到主頁面
class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaunchBloc, LaunchState>(
      listener: (context, state) {
        switch (state) {
          case LaunchCompleted():
            // 初始化完成，跳轉到主頁面
            context.go(AppRouter.speedometer);
          case LaunchError(:final message):
            // 顯示錯誤訊息
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case LaunchInitializing():
            // 初始化中，不做任何事
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.accentColor,
        body: BlocBuilder<LaunchBloc, LaunchState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '愛車管家',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // 載入指示器
                  const CircularProgressIndicator(),
                  if (state is LaunchError) ...[
                    const SizedBox(height: 24),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
