import 'package:flutter_bloc/flutter_bloc.dart';
import 'launch_event.dart';
import 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  LaunchBloc() : super(const LaunchInitializing()) {
    on<StartInitialization>(_onStartInitialization);
  }

  Future<void> _onStartInitialization(
    StartInitialization event,
    Emitter<LaunchState> emit,
  ) async {
    try {
      // TODO: 在這裡執行初始化任務
      // - 載入配置
      // - 呼叫 API
      // - 初始化資料庫
      // - 等等...

      // 模擬初始化延遲
      await Future.delayed(const Duration(seconds: 3));

      // 初始化完成
      emit(const LaunchCompleted());
    } catch (e) {
      emit(LaunchError('初始化失敗: $e'));
    }
  }
}
