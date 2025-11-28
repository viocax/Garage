sealed class LaunchEvent {
  const LaunchEvent();
}

/// 開始初始化應用程式
final class StartInitialization extends LaunchEvent {
  const StartInitialization();
}
