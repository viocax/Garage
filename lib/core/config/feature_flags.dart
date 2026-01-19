/// Feature Flags for controlling feature visibility
///
/// 這個類別用於控制各功能在 UI 上的顯示與否。
/// 在第一版發布時，將部分功能設為 false 以隱藏。
/// 當準備好發布時，只需將對應的 flag 改為 true 即可開啟。
///
/// 注意：這僅控制 UI 入口，底層的邏輯和 Service 依然完整保留。
class FeatureFlags {
  FeatureFlags._();

  /// 測速照相功能 (Speedometer Tab + Speed Detection Settings)
  /// 包含：Speedometer Tab、測速設置入口
  static const bool enableSpeedCamera = false;

  /// 雲端同步功能 (Cloud Sync)
  /// 包含：雲端同步入口、資料管理區塊
  static const bool enableCloudSync = false;

  /// 廣告管理功能 (Ad Management)
  /// 包含：廣告管理入口
  static const bool enableAdManagement = false;

  /// 使用條款與開源授權入口
  /// 包含：使用條款、開源授權
  static const bool enableLegalDocuments = false;
}
