import 'package:flutter/material.dart';
import 'package:garage/core/utils/log.dart';

/// 1. 定義介面
/// 所有要進入 Queue 的物件都要實作這個 execute 方法
abstract class QueueableItem {
  /// 當這個 Future 完成 (complete) 時，視為條件滿足，Queue 會自動將其移除
  Future<void> execute();
}

/// 2. 實作自動移除的 Queue
class AutoReleaseQueue {
  // 使用 List 作為 FIFO 佇列
  final List<QueueableItem> _queue = [];

  // 用來防止同時開啟多個處理迴圈的鎖
  bool _isProcessing = false;

  // 用來標記是否要取消處理
  bool _isCancelled = false;

  QueueableItem? get lastItem {
    if (_queue.isEmpty) return null;
    return _queue.last;
  }

  /// 取得目前隊列中的任務數量
  int get length => _queue.length;

  /// 是否正在處理中
  bool get isProcessing => _isProcessing;

  /// 加入項目並嘗試觸發處理
  void enqueue(QueueableItem item) {
    _queue.add(item);
    _processNext();
  }

  /// 清空隊列中等待的任務
  /// 不會影響當前正在執行的任務
  void clear() {
    _queue.clear();
    Log.d('AutoReleaseQueue: 已清空隊列，剩餘任務數: ${_queue.length}');
  }

  /// 取消所有任務（包括當前正在執行的）
  /// 當前任務會執行完畢，但不會繼續處理後續任務
  void cancelAll() {
    _isCancelled = true;
    _queue.clear();
    Log.d('AutoReleaseQueue: 已取消所有任務');
  }

  /// 內部的遞迴/迴圈處理邏輯
  Future<void> _processNext() async {
    // 如果正在處理中，或佇列是空的，就直接返回
    if (_isProcessing || _queue.isEmpty) {
      return;
    }

    // 鎖定狀態
    _isProcessing = true;

    // 使用 while 迴圈確保佇列清空前不會停止
    while (_queue.isNotEmpty && !_isCancelled) {
      // 1. Peek: 取得隊首 (暫不移除)
      final currentItem = _queue.first;

      try {
        // 2. Execute & Wait: 執行並等待條件滿足
        // 這裡是關鍵：await 會暫停這裡的程式碼執行，直到 Future 完成
        await currentItem.execute();
      } catch (e) {
        // 錯誤處理：即使失敗也要繼續，避免卡死整個 Queue
        Log.e("AutoReleaseQueue: Item execution failed", e);
      }

      // 3. Dequeue: 條件滿足後，移除隊首
      _queue.removeAt(0);
    }

    // 解除鎖定並重置取消標記
    _isProcessing = false;
    _isCancelled = false;
  }
}
