# Garage 車庫

一款專為汽車愛好者設計的 iOS 車輛管理 App，結合 **測速照相提醒** 與 **保養/消費紀錄** 功能。

## 功能特色

### 測速照相提醒
- 即時 GPS 速度偵測
- 前方測速照相警示（距離 + 限速）
- TTS 語音播報提醒
- 地圖顯示測速照相位置
- 3D 車輛動畫視覺效果
- 超速顏色警告（正常/接近/超速）

### 車輛紀錄管理
- 多車輛管理
- 加油紀錄（油種、公升數、單價、油耗計算）
- 保養紀錄（多項目、下次保養里程）
- 其他消費紀錄
- 分類統計圖表
- 月度/年度花費統計

### 個人化設定
- 速度單位切換（km/h / mph）
- 語音提示開關與音量調整
- 提醒距離與超速容忍值設定
- 地圖顯示模式（標準/衛星）

### 雲端同步
- 手動備份/還原資料到雲端
- iOS 支援 iCloud 與 Google Drive
- Android 支援 Google Drive
- 資料以 JSON 格式儲存

## 技術架構

| 項目 | 技術 |
|------|------|
| 框架 | Flutter 3.10+ |
| 平台 | iOS |
| 狀態管理 | BLoC |
| 路由 | GoRouter |
| 依賴注入 | GetIt |
| 本地資料庫 | Isar |
| 設定儲存 | SharedPreferences |
| 地圖 | flutter_map (OpenStreetMap) |
| 圖表 | fl_chart |
| 語音 | flutter_tts |

## 專案結構

```
lib/
├── main.dart
├── core/
│   ├── di/                 # 依賴注入設定
│   ├── models/             # 資料模型
│   ├── repositories/       # 資料儲存庫
│   ├── service/            # 服務層
│   │   ├── cloud_sync/     # 雲端同步 (iCloud, Google Drive)
│   │   ├── location/       # GPS 定位
│   │   ├── network/        # 網路請求
│   │   ├── tts/            # 語音播報
│   │   └── shared_preferences/
│   ├── mixins/             # Mixins
│   ├── extensions/         # Extensions
│   └── utils/              # 工具類
├── screen/
│   ├── app/
│   │   ├── home/           # 主頁 TabBar
│   │   └── launch/         # 啟動頁
│   ├── speed/
│   │   ├── speedCamera/    # 測速照相頁
│   │   └── car3d/          # 3D 車輛動畫
│   ├── records/
│   │   ├── add_record/     # 新增紀錄
│   │   ├── add_vehicle/    # 新增車輛
│   │   ├── all_records/    # 全部紀錄
│   │   └── bloc/           # 紀錄狀態管理
│   └── settings/
│       ├── cloud_sync/              # 雲端同步頁面
│       ├── vehicle_management/      # 車輛管理
│       ├── speed_detection_settings/ # 測速設定
│       ├── widgets/
│       └── bloc/
├── router/                 # GoRouter 路由設定
├── theme/                  # AppTheme 主題樣式
└── widgets/                # 共用元件
```

## 環境需求

- Flutter SDK >= 3.10.1
- Dart SDK >= 3.10.1
- Xcode 15+
- iOS 12.0+


## 主要依賴

| 用途 | 套件 |
|------|------|
| 狀態管理 | flutter_bloc, equatable |
| 路由 | go_router |
| 依賴注入 | get_it |
| 本地資料庫 | isar_community |
| 位置服務 | geolocator |
| 地圖 | flutter_map, latlong2 |
| 3D 模型 | model_viewer_plus |
| 語音播報 | flutter_tts |
| 圖表 | fl_chart |
| 網路 | dio |
| 字體 | google_fonts |
| Google 登入 | google_sign_in, googleapis |
| iCloud 儲存 | icloud_storage |

## 開發進度

- [x] 測速頁面 - 即時速度與照相提醒
- [x] 紀錄頁面 - 車輛與消費管理
- [x] 設定頁面 - 個人化選項
- [x] 3D 車輛動畫
- [x] TTS 語音播報
- [x] 分類統計圖表
- [ ] 背景執行支援
- [ ] 區間測速偵測
- [ ] 導航整合
- [x] 雲端同步 (iOS: iCloud / Android: Google Drive)
  - [x] CloudSyncService 抽象介面與 Factory 模式
  - [x] CloudSyncPage UI（設定 → 同步雲端）
  - [x] CloudSyncBloc 狀態管理
  - [x] iOS Google Drive 同步
    - Google Sign-In 設定完成
    - 資料存於 App Data folder（隱藏）
  - [x] iOS iCloud 同步
    - Container ID: `iCloud.com.drake.garage`
    - 需在 Apple Developer Portal 建立 iCloud Container
  - [ ] Android Google Sign-In 設定（需根據環境產生 SHA-1）
    - Debug: `./gradlew signingReport` 取得 SHA-1
    - Release: 用正式 keystore 產生 SHA-1
    - 至 Google Cloud Console 建立 Android OAuth 憑證
  - [ ] Isar 資料庫匯出/匯入邏輯（目前為 placeholder）
- [ ] 資料匯出
- [ ] 錯誤處理
- [ ] localizeString
- [ ] model 授權
- [ ] OpenMap 授權
- [ ] 訂閱制
- [ ] 廣告

## 授權

本專案僅供個人學習使用。
