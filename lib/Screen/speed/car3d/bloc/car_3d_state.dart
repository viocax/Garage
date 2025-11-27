sealed class Car3DState {
  const Car3DState();
}

// 加載中
final class Car3DLoading extends Car3DState {
  const Car3DLoading();
}

// 加載失敗
final class Car3DLoadError extends Car3DState {
  final String error;

  const Car3DLoadError(this.error);
}

// 模型已加載，動畫停止
final class Car3DReady extends Car3DState {
  final String modelSrc;

  const Car3DReady(this.modelSrc);
}

// 模型已加載，動畫中
final class Car3DAnimating extends Car3DState {
  final String modelSrc;

  const Car3DAnimating(this.modelSrc);
}
