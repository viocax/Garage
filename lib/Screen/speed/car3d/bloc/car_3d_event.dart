sealed class Car3DEvent {
  const Car3DEvent();
}

// 加載 3D 模型事件
final class LoadCar3DModel extends Car3DEvent {
  const LoadCar3DModel();
}

// 開始動畫事件
final class StartCar3DAnimation extends Car3DEvent {
  const StartCar3DAnimation();
}

// 停止動畫事件
final class StopCar3DAnimation extends Car3DEvent {
  const StopCar3DAnimation();
}
