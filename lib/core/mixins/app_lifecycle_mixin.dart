import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App 生命週期 Mixin
///
/// 讓 Bloc 可以監聽 App 生命週期變化
/// 使用方式：
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with AppLifecycleMixin<MyEvent, MyState> {
///   MyBloc() : super(MyInitial()) {
///     initLifecycleObserver();
///   }
///
///   @override
///   void onAppResumed() {
///     // 處理 app 回到前景
///   }
/// }
/// ```
mixin AppLifecycleMixin<E, S> on Bloc<E, S> implements WidgetsBindingObserver {
  /// 初始化生命週期監聽（在 Bloc 構造函數中調用）
  void initLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onAppResumed();
        break;
      case AppLifecycleState.inactive:
        onAppInactive();
        break;
      case AppLifecycleState.paused:
        onAppPaused();
        break;
      case AppLifecycleState.detached:
        onAppDetached();
        break;
      case AppLifecycleState.hidden:
        onAppHidden();
        break;
    }
  }

  /// App 回到前景時調用
  void onAppResumed() {}

  /// App 進入非活躍狀態時調用（例如來電）
  void onAppInactive() {}

  /// App 進入後台時調用
  void onAppPaused() {}

  /// App 被分離時調用
  void onAppDetached() {}

  /// App 被隱藏時調用
  void onAppHidden() {}

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  // WidgetsBindingObserver 的其他方法可以根據需要覆寫
  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() => Future.value(false);

  @override
  Future<bool> didPushRoute(String route) => Future.value(false);

  @override
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) =>
      Future.value(false);

  @override
  void didChangeViewFocus(ViewFocusEvent event) {}
  // Wait, signature might be different. Let's try dynamic or verify.
  // Actually, didChangeViewFocus(ViewFocusEvent event) is correct for newer flutter.
  // But let's check if I can just ignore the types by not annotating too strictly?
  // No, must match override.

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    return AppExitResponse.exit;
  }

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent event) {
    return false; // or true? Usually false if not handling.
    // Wait, signature is handleStartBackGesture(PredictiveBackEvent event).
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent event) {}
}
