# Spec: 實作背景執行支援 (Background Execution Support)

## 1. 概述
目前 App 在進入背景後會停止 GPS 定位更新，導致測速警報失效。本賽道目標是讓 App 支援背景模式下的位置更新與語音提醒 (TTS)。

## 2. 核心需求
- **背景定位更新**：App 進入背景或螢幕關閉時，仍能獲取 GPS 資料。
- **背景 TTS 播報**：在背景觸發測速警報時，語音提醒應能正常運作。
- **平台適配**：
  - **iOS**: 設定 `UIBackgroundModes` 包含 `location`。
  - **Android**: 實作 Foreground Service 並獲取 `ACCESS_BACKGROUND_LOCATION` 權限。

## 3. 技術方案
- **套件選擇**：延續現有的 `geolocator`，需配置其背景設定；考慮引入 `flutter_background_service` 若標準定位模式不足以維持背景存活。
- **權限處理**：更新 `Info.plist` 與 `AndroidManifest.xml`。
- **省電考量**：僅在測速功能開啟時啟動背景服務，避免不必要的耗電。

## 4. 驗證標準
- App 進入背景後，於模擬路測（Simulation）中仍能聽到語音警報。
- 完成後需檢查是否有記憶體洩漏或過度耗電問題。
