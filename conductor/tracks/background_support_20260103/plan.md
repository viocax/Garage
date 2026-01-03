# Plan: 實作背景執行支援 (Background Execution Support)

## Phase 1: 環境配置與權限 (Environment & Permissions)
- [x] Task: 更新 iOS Info.plist，添加 `location` 到 `UIBackgroundModes` 並說明定位意圖。
- [x] Task: 更新 Android AndroidManifest.xml，添加 `ACCESS_BACKGROUND_LOCATION` 與 `FOREGROUND_SERVICE` 權限。
- [x] Task: 更新 `geolocator` 的 `LocationSettings` 配置，啟用背景更新模式。
- [x] Task: Conductor - User Manual Verification 'Phase 1' (Protocol in workflow.md)

## Phase 2: 基礎功能實作 (Implementation)
- [x] Task: 修改 `LocationService`，實作背景模式切換邏輯。
- [x] Task: 確保 `TtsService` 在背景下能透過 `AVAudioSession` (iOS) 播放聲音。
- [x] Task: 在背景觸發一次模擬告警，測試流程是否通暢。
- [x] Task: Conductor - User Manual Verification 'Phase 2' (Protocol in workflow.md)

## Phase 3: 穩定性與測試 (Stability & Testing)
- [x] Task: 實作 `LocationPolicy` 策略，根據 App 前背景狀態調整定位精度與耗電。
- [x] Task: 強化權限請求邏輯，引導使用者開啟「始終允許」定位權限。
- [x] Task: 驗證當關閉定位功能時，背景服務能正確停止以省電。
- [x] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
