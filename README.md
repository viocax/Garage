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
- 多國語系支援（繁體中文、英文）

### 雲端同步
- 手動備份/還原資料到雲端
- iOS 支援 iCloud 與 Google Drive
- Android 支援 Google Drive
- 資料以 JSON 格式儲存

## 技術架構

| 項目 | 技術 |
|------|------|
| 框架 | Flutter 3.10+ |
| 平台 | iOS, Android |
| 狀態管理 | BLoC |
| 路由 | GoRouter |
| 依賴注入 | GetIt |
| 本地資料庫 | Isar |
| 設定儲存 | SharedPreferences |
| 地圖 | flutter_map (OpenStreetMap) |
| 圖表 | fl_chart |
| 語音 | flutter_tts |
| 多語系 | easy_localization |

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

## Barrel Export 結構

專案使用 barrel export 模式統一管理 import，避免冗長的相對路徑。

### 使用方式

```dart
// ✅ 推薦：使用 barrel export
import 'package:garage/core/core.dart';

// ❌ 避免：直接引入個別檔案
import '../../models/vehicle.dart';
import '../../di/service_locator.dart';
```

### Sub-barrel 檔案結構

```
lib/core/
├── core.dart                      # 主 barrel（匯出所有 sub-barrel）
│
├── models/
│   └── models.dart                # 匯出所有 model
│       ├── camera.dart
│       ├── picker_option.dart
│       ├── speed_camera_model.dart
│       ├── speed_unit.dart
│       ├── tabbar_type.dart
│       ├── tts_speaking_token.dart
│       ├── user_settings.dart
│       ├── vehicle.dart
│       └── vehicle_record.dart
│
├── repositories/
│   └── repositories.dart          # 匯出所有 repository
│       ├── speed_camera_repository.dart
│       ├── local_speed_camera_repository.dart
│       ├── user_settings_repository.dart
│       ├── local_user_settings_repository.dart
│       ├── vehicle_repository.dart
│       ├── local_vehicle_repository.dart
│       ├── cloud_sync_repository.dart
│       ├── local_cloud_sync_repository.dart
│       ├── app_open_ad_repository.dart
│       ├── ad_repository.dart
│       └── local_ad_repository.dart
│
├── service/
│   └── services.dart              # 匯出所有 service
│       ├── isar_service.dart
│       ├── location/
│       │   ├── location_service.dart
│       │   └── geolocator_interface.dart
│       ├── network/
│       │   ├── http_service.dart
│       │   ├── api_request.dart
│       │   ├── http_exception.dart
│       │   └── http_method.dart
│       ├── tts/
│       │   ├── tts_service.dart
│       │   └── tts_interface.dart
│       ├── shared_preferences/
│       │   ├── shared_preferences_service.dart
│       │   └── shared_preferences_interface.dart
│       ├── cloud_sync/
│       │   └── cloud_sync.dart    # 匯出所有 cloud sync 相關 service
│       │       ├── cloud_sync_service.dart
│       │       ├── google_drive_sync_service.dart
│       │       └── icloud_sync_service.dart
│       └── ad/
│           ├── ad_service.dart
│           └── mobile_ad_service.dart
│
├── extensions/
│   └── extensions.dart            # 匯出所有 extension
│       └── dialog_extension.dart
│
├── mixins/
│   └── mixins.dart                # 匯出所有 mixin
│       └── app_lifecycle_mixin.dart
│
├── utils/
│   └── utils.dart                 # 匯出所有 utility
│       ├── auto_release_queue.dart
│       ├── stream_extensions.dart
│       └── app_documents.dart
│
└── di/
    └── service_locator.dart       # GetIt 依賴注入設定
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
| 多語系 | easy_localization |
| Google 登入 | google_sign_in, googleapis |
| iCloud 儲存 | icloud_storage |

## 開發進度

- [x] 測速頁面 - 即時速度與照相提醒
- [x] 紀錄頁面 - 車輛與消費管理
- [x] 設定頁面 - 個人化選項
- [x] 3D 車輛動畫
- [x] TTS 語音播報
- [x] 分類統計圖表
- [x] 背景執行支援
- [ ] 區間測速偵測
- [x] 雲端同步 (iOS: iCloud / Android: Google Drive)
  - [x] CloudSyncRepository 抽象介面與 Repository 模式
    - Service 為 Singleton（保持登入狀態）
    - Repository 為 Factory（無狀態）
  - [x] CloudSyncPage UI（設定 → 同步雲端）
  - [x] CloudSyncBloc 狀態管理
  - [x] VehicleRecord 加入 vehicleId 欄位（備份還原時重建關聯）
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
  - [x] Isar 資料庫匯出/匯入邏輯
    - 匯出所有 Vehicle 與 VehicleRecord 為 JSON
    - 還原時重建 IsarLinks 關聯
- [ ] 錯誤處理
- [x] localizeString
- [ ] 訂閱制
- [x] 廣告 (Google AdMob)
  - [x] 基礎配置 (iOS/Android App ID, SDK Init)
  - [x] Banner 廣告 (Settings, Vehicle Management)
  - [x] 插頁式廣告 (Add Record/Add Vehicle 成功後)
  - [x] 原生廣告 (All Records 列表中插入)
  - [x] 獎勵廣告 (Rewarded Ads)
    - [x] 廣告票券 (Ad Tickets) - 跳過插頁廣告
    - [x] 移除橫幅 (Remove Banner) - 12小時限時移除
    - [ ] 雲端同步單次解鎖 (Feature Unlock) - 待實作

## 聯絡與反饋

如果您在使用過程中有任何問題或建議，歡迎透過以下方式與我聯絡：
- **電子郵件**: [drake.garage.app@gmail.com](mailto:drake.garage.app@gmail.com)

## 授權

本專案僅供個人學習使用。
