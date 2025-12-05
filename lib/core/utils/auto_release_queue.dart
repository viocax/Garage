import 'package:flutter/material.dart';

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

  QueueableItem? get lastItem {
    if (_queue.isEmpty) return null;
    return _queue.last;
  }

  /// 加入項目並嘗試觸發處理
  void enqueue(QueueableItem item) {
    _queue.add(item);
    _processNext();
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
    while (_queue.isNotEmpty) {
      // 1. Peek: 取得隊首 (暫不移除)
      final currentItem = _queue.first;

      try {
        // 2. Execute & Wait: 執行並等待條件滿足
        // 這裡是關鍵：await 會暫停這裡的程式碼執行，直到 Future 完成
        await currentItem.execute();
      } catch (e) {
        // 錯誤處理：即使失敗也要繼續，避免卡死整個 Queue
        debugPrint("Item execution failed: $e");
      }

      // 3. Dequeue: 條件滿足後，移除隊首
      _queue.removeAt(0);
    }

    // 解除鎖定
    _isProcessing = false;
  }
}
