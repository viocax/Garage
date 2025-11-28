import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/speed_camera.dart';

/// Isar 資料庫服務（單例模式）
class IsarService {
  static final IsarService instance = IsarService._init();
  static Isar? _isar;

  IsarService._init();

  /// 取得 Isar 實例
  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    _isar = await _initIsar();
    return _isar!;
  }

  /// 初始化 Isar 資料庫
  Future<Isar> _initIsar() async {
    debugPrint('IsarService: 初始化 Isar 資料庫');

    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [SpeedCameraSchema],
      directory: dir.path,
      inspector: kDebugMode, // 只在 debug 模式啟用 inspector
    );

    debugPrint('IsarService: Isar 資料庫已初始化於 ${dir.path}');
    return isar;
  }

  /// 關閉資料庫
  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
      debugPrint('IsarService: Isar 資料庫已關閉');
    }
  }

  /// 清空所有資料（用於測試或重置）
  Future<void> clearAll() async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.clear();
    });
    debugPrint('IsarService: 所有資料已清空');
  }

  /// 取得資料庫統計資訊
  Future<Map<String, dynamic>> getStats() async {
    final db = await isar;
    final cameraCount = await db.speedCameras.count();
    final size = await db.getSize();

    return {
      'speedCameraCount': cameraCount,
      'databaseSize': size,
      'databaseSizeFormatted': '${(size / 1024).toStringAsFixed(2)} KB',
    };
  }
}
