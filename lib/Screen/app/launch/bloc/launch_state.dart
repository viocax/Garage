sealed class LaunchState {
  const LaunchState();
}

/// 初始化中
final class LaunchInitializing extends LaunchState {
  const LaunchInitializing();
}

/// 初始化完成
final class LaunchCompleted extends LaunchState {
  const LaunchCompleted();
}

/// 初始化失敗
final class LaunchError extends LaunchState {
  final String message;

  const LaunchError(this.message);
}
