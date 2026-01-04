# Garage App - 軟體規格書

> 版本：v0.2
> 最後更新：2025/12/28
> 狀態：PH1 開發中

---

## 1. 產品概述

### 1.1 產品定位

Garage 是一款專為汽車愛好者設計的車輛管理 App，主打 **保養/加油/消費紀錄** 與 **測速照相提醒** 兩大核心功能，採用簡潔的 Apple 風格設計，讓車主輕鬆管理愛車的所有花費與行車安全。

### 1.2 目標用戶

- 重視愛車保養的車主
- 汽車改裝愛好者
- 需要測速提醒的通勤族

### 1.3 核心價值

| 價值 | 說明 |
|------|------|
| 紀錄管理 | 一站式管理保養、加油等所有車輛花費 |
| 行車安全 | 測速照相提醒，避免超速罰單 |
| 簡潔易用 | Apple 風格 UI，操作直覺無負擔 |

---

## 2. 技術規格

### 2.1 開發框架

| 項目 | 選擇 |
|------|------|
| 框架 | Flutter |
| 平台 | iOS / Android |
| 資料儲存 | Isar Community (本地資料庫) + SharedPreferences (設定) |
| 狀態管理 | Flutter BLoC |
| 路由 | GoRouter |
| 依賴注入 | GetIt |

### 2.2 Phase 規劃

| Phase | 功能範圍 | 狀態 |
|-------|----------|------|
| **PH1** | 測速提醒（固定點）、紀錄 CRUD、本地儲存、設定頁面 | 🔄 開發中 |
| **PH2** | 區間測速、導航整合、雲端同步、訂閱制功能 | 📋 規劃中 |

---

## 3. 專案結構

### 3.1 程式碼架構

```
lib/
├── main.dart                    # 應用程式入口
├── core/                        # 核心層
│   ├── di/                      # 依賴注入 (GetIt)
│   ├── extensions/              # 擴展方法
│   ├── mixins/                  # Mixins
│   ├── models/                  # 資料模型
│   ├── repositories/            # 資料儲存庫層
│   ├── service/                 # 服務層
│   │   ├── network/             # HTTP 網路服務
│   │   ├── location/            # GPS 位置服務
│   │   ├── tts/                 # 文字轉語音服務
│   │   └── shared_preferences/  # 本地偏好設定
│   └── utils/                   # 工具類
├── screen/                      # 頁面層
│   ├── app/                     # 應用程式層 (Home, Launch)
│   ├── speed/                   # 測速頁面
│   ├── records/                 # 紀錄頁面
│   └── settings/                # 設定頁面
├── router/                      # 路由配置
├── theme/                       # 主題和樣式
└── widgets/                     # 共用元件
```

### 3.2 App 路由結構

```
launch (啟動頁)
  ↓
home (首頁 - Tab Navigation)
  ├─ /home/speedometer      # 測速頁面
  ├─ /home/records          # 紀錄頁面
  │  ├─ addRecord           # 新增紀錄
  │  └─ addVehicle          # 新增車輛
  └─ /home/settings         # 設定頁面
     ├─ vehicleManagement   # 車輛管理
     └─ speedDetectionSettings  # 測速設定
```

---

## 4. 測速頁面規格

### 4.1 實作狀態: ✅ 已完成

### 4.2 畫面結構

```
┌─────────────────────────────────────┐
│                                     │
│      🗺️ 地圖顯示區域                 │
│      (OpenStreetMap / flutter_map)   │
│                                     │
│           ┌───────────┐             │
│           │    72     │             │
│           │   km/h    │             │
│           └───────────┘             │
│                                     │
│         ┌─────────────────┐         │
│         │ ⚠️ 500m 限速 50  │         │
│         └─────────────────┘         │
│                                     │
│      ┌────────────────────────┐     │
│      │   🚗 3D 車輛動畫        │     │
│      └────────────────────────┘     │
│                                     │
├─────────────────────────────────────┤
│   測速    │   紀錄    │    設定     │
└─────────────────────────────────────┘
```

### 4.3 功能規格

#### 4.3.1 速度顯示（HUD 風格）

| 項目 | 規格 |
|------|------|
| 資料來源 | GPS speed（geolocator） |
| 更新頻率 | 動態 distanceFilter（依車速調整） |
| 顯示格式 | 整數，支援 km/h 或 mph |
| 顏色邏輯 | 正常：白色、接近超速：橘色、超速：紅色 |

#### 4.3.2 3D 車輛場景

| 項目 | 規格 |
|------|------|
| 技術 | model_viewer_plus |
| 模型 | 3D 汽車模型 |
| 動態感 | 根據車速調整動畫速度 |

#### 4.3.3 測速照相提醒

| 項目 | 規格 |
|------|------|
| 提醒距離 | 可設定（預設 1000m） |
| 顯示內容 | 距離（公尺）+ 限速 |
| 多點處理 | 只顯示最近一點 |
| 提醒方式 | 視覺 + TTS 語音播報 |
| 資料來源 | 本地 JSON（台灣測速照相點位） |
| 效能優化 | QuadTree 快速查詢附近相機 |

#### 4.3.4 地圖顯示

| 項目 | 規格 |
|------|------|
| 套件 | flutter_map |
| 圖層 | OpenStreetMap |
| 顯示模式 | 標準/衛星（可切換） |
| 標記 | 測速照相位置標記 |

#### 4.3.5 省電機制

| 車速 | distanceFilter |
|------|---------------|
| < 10 km/h（靜止/塞車） | 較大間距 |
| 10-60 km/h（市區） | 中等間距 |
| > 60 km/h（快速道路） | 較小間距 |

### 4.4 測速資料結構

```dart
class Camera {
  String id;            // 相機 ID
  int speedLimit;       // 限速 (km/h)
  double latitude;      // 緯度
  double longitude;     // 經度
  String direction;     // 方向
  String description;   // 描述
}
```

### 4.5 區間測速 (PH2)

> 📋 Phase 2 規劃中

| 階段 | 觸發條件 | 系統行為 |
|------|----------|----------|
| 進入區間 | 通過起點 | 記錄時間、開始計算 |
| 區間內 | 在起點與終點之間 | 顯示「區間測速中」+ 目前均速 + 剩餘距離 |
| 離開區間 | 通過終點 | 計算平均速度、判斷是否超速 |

---

## 5. 紀錄頁面規格

### 5.1 實作狀態: ✅ 已完成

### 5.2 畫面結構

```
┌─────────────────────────────────────┐
│  紀錄                               │
├─────────────────────────────────────┤
│                                     │
│  🚗 車輛選擇器                       │
│     ├─ 車輛 1                       │
│     ├─ 車輛 2                       │
│     └─ + 新增車輛                   │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 保養健康度條                    ││
│  │ [====== 80% ======]            ││
│  │ 距下次保養：2000 km             ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────┐ ┌────────────┐│
│  │ 本月花費        │ │ 總花費     ││
│  │ $12,500        │ │ $156,200  ││
│  └─────────────────┘ └────────────┘│
│                                     │
├─────────────────────────────────────┤
│  最近紀錄                           │
│                                     │
│  ⛽ 加油      $1,200   2025/12/24  │
│  🔧 保養      $3,500   2025/12/20  │
│  📋 其他      $500     2025/12/15  │
│                                     │
│              ＋ 新增紀錄             │
├─────────────────────────────────────┤
│   測速    │   紀錄    │    設定     │
└─────────────────────────────────────┘
```

### 5.3 記錄類型

#### 5.3.1 加油記錄 (RecordTypeFuel)

| 欄位 | 必填 | 說明 |
|------|------|------|
| 日期 | ✅ | 加油日期 |
| 金額 | ✅ | 加油金額 |
| 里程 | ✅ | 當前里程 |
| 油種 | ✅ | 92/95/98/柴油 |
| 加油量 | ⬜ | 公升數 |
| 單價 | ⬜ | 每公升油價 |
| 剩餘油量 | ⬜ | 百分比 |

#### 5.3.2 保養記錄 (RecordTypeMaintenance)

| 欄位 | 必填 | 說明 |
|------|------|------|
| 日期 | ✅ | 保養日期 |
| 金額 | ✅ | 總金額 |
| 里程 | ✅ | 當前里程 |
| 保養項目 | ✅ | 可多項（項目名稱、金額、備註） |
| 下次保養里程 | ⬜ | 用於計算保養提醒 |

#### 5.3.3 其他記錄 (RecordTypeOther)

| 欄位 | 必填 | 說明 |
|------|------|------|
| 標題 | ✅ | 記錄標題 |
| 日期 | ✅ | 日期 |
| 金額 | ✅ | 金額 |
| 里程 | ⬜ | 當前里程 |
| 備註 | ⬜ | 文字備註 |

### 5.4 保養健康度

計算公式：
```
healthPercentage = remindKm / maintenanceIntervalKm
（限制在 0.0 ~ 1.0 之間）
```

---

## 6. 設定頁面規格

### 6.1 實作狀態: ✅ 已完成

### 6.2 設定項目

#### 6.2.1 測速設定

| 項目 | 類型 | 說明 |
|------|------|------|
| 速度單位 | 選擇 | km/h 或 mph |
| 語音提示 | 開關 | 啟用/關閉 TTS 播報 |
| 語音音量 | 滑桿 | 0.0 ~ 1.0 |
| 語音速度 | 滑桿 | 0.0 ~ 1.0 |
| 提醒距離 | 選擇 | 500m / 1000m / 1500m / 2000m |
| 超速容忍值 | 選擇 | 0 / 5 / 10 / 15 km/h |

#### 6.2.2 通知設定

| 項目 | 類型 | 說明 |
|------|------|------|
| 推送通知 | 開關 | 啟用/關閉 |
| 保養提醒 | 開關 | 啟用/關閉 |
| 提前提醒天數 | 選擇 | 3 / 7 / 14 / 30 天 |

#### 6.2.3 隱私與資料

| 項目 | 類型 | 說明 |
|------|------|------|
| 數據分析 | 開關 | 啟用/關閉 |
| 自動備份 | 開關 | 啟用/關閉 |

#### 6.2.4 顯示設定

| 項目 | 類型 | 說明 |
|------|------|------|
| 顯示速度上限 | 開關 | 地圖上顯示限速 |
| 顯示測速照相 | 開關 | 地圖上顯示照相機位置 |
| 地圖模式 | 選擇 | 標準 / 衛星 |

#### 6.2.5 車輛管理

- 車輛列表
- 新增/編輯車輛
- 車輛排序

---

## 7. 資料結構

### 7.1 車輛資料 (Vehicle)

```dart
@collection
class Vehicle {
  Id id;                        // Isar 自動增量 ID
  String vehicleId;             // UUID（唯一識別）
  String carName;               // 車輛名稱
  String licensePlate;          // 車牌號碼
  int currentKm;                // 當前里程
  int maintenanceIntervalKm;    // 保養間隔（預設 5000）
  int kmToNextMaintenance;      // 下次保養里程
  int order;                    // 排序順序

  // 關聯
  final records = IsarLinks<VehicleRecord>();

  // 計算屬性
  double get maintenanceHealth; // 保養健康度 (0-1)
  int get remindKm;             // 剩餘里程
  String get totalSpent;        // 總消費
  String get spentThisMonth;    // 本月消費
}
```

### 7.2 紀錄資料 (VehicleRecord)

```dart
@collection
class VehicleRecord {
  Id id;
  String recordId;              // UUID
  String typeName;              // 記錄類型
  String title;                 // 標題
  DateTime date;                // 日期
  double cost;                  // 費用
  int km;                       // 里程

  // 類型資料（三選一）
  FuelData? fuelData;
  List<MaintenanceData>? maintenanceData;
  OtherData? otherData;
}
```

### 7.3 嵌入式資料類別

```dart
@embedded
class FuelData {
  FuelType fuelType;      // 92, 95, 98, 柴油
  double fuelAmount;      // 加油量
  double pricePerLiter;   // 單價
  int remainingFuel;      // 剩餘油量 %
}

@embedded
class MaintenanceData {
  String item;            // 保養項目
  double amount;          // 金額
  int? nextMaintenanceKm; // 下次保養里程
  String note;            // 備註
}

@embedded
class OtherData {
  double amount;          // 金額
  String note;            // 備註
}
```

### 7.4 使用者設定 (UserSettings)

```dart
class UserSettings {
  // 測速設定
  SpeedUnit speedUnit;
  bool isVoiceAlertEnabled;
  double voiceVolume;
  double voiceSpeechRate;
  int alertDistance;
  int speedTolerance;

  // 通知設定
  bool isPushNotificationEnabled;
  bool isMaintenanceReminderEnabled;
  int maintenanceReminderDays;

  // 隱私與資料
  bool isAnalyticsEnabled;
  bool isAutoBackupEnabled;
  DateTime? lastBackupTime;

  // 顯示設定
  bool showSpeedLimit;
  bool showSpeedCamera;
  MapDisplayMode mapDisplayMode;
}
```

---

## 8. 服務層架構

### 8.1 依賴注入配置

```dart
// 服務層（單例）
getIt.registerLazySingleton<IsarService>();
getIt.registerLazySingleton<HttpService>();
getIt.registerLazySingleton<LocationService>();
getIt.registerLazySingleton<SharedPreferencesService>();
getIt.registerLazySingleton<TtsService>();

// 儲存庫層（單例）
getIt.registerLazySingleton<ISpeedCameraRepository>();
getIt.registerLazySingleton<UserSettingsRepository>();
getIt.registerLazySingleton<VehicleRepository>();
```

### 8.2 主要服務

| 服務 | 說明 |
|------|------|
| IsarService | 資料庫初始化和管理 |
| LocationService | GPS 位置追蹤，自適應 distanceFilter |
| TtsService | 文字轉語音，支援隊列機制 |
| HttpService | HTTP 網路請求 |
| SharedPreferencesService | 本地偏好設定儲存 |

---

## 9. 狀態管理

### 9.1 BLoC 列表

| BLoC | 頁面 | 功能 |
|------|------|------|
| GarageHomeBloc | 首頁 | 底部標籤列狀態 |
| LaunchBloc | 啟動頁 | 應用初始化 |
| SpeedBloc | 測速頁 | 速度、限速、距離 |
| Car3DBloc | 測速頁 | 3D 車輛動畫 |
| RecordsBloc | 紀錄頁 | 車輛列表、記錄列表 |
| AddRecordBloc | 新增紀錄 | 表單處理 |
| AddVehicleBloc | 新增車輛 | 表單處理 |
| SettingsBloc | 設定頁 | 設定狀態和導航 |
| VehicleManagementBloc | 車輛管理 | 車輛 CRUD |
| SpeedDetectionSettingsBloc | 測速設定 | 設定項目狀態 |

---

## 10. 商業模式

### 10.1 免費版

- 基本保養/加油紀錄
- 里程追蹤
- 測速照相提醒
- Local Storage 儲存

### 10.2 付費/訂閱版（規劃中）

- 保養到期智慧提醒
- 花費統計圖表（月/年報表）
- 測速點即時更新 + 區間測速提醒
- 資料匯出（CSV/PDF）
- 無廣告
- 雲端同步

---

## 11. TODO 清單

### 11.1 PH1 - 進行中

- [x] 測速頁面基本功能
- [x] 紀錄頁面基本功能
- [x] 設定頁面基本功能
- [x] 車輛管理
- [x] 3D 車輛動畫
- [x] TTS 語音播報
- [ ] 背景執行（Foreground Service）
- [ ] iOS 背景定位

### 11.2 PH2 - 規劃中

- [ ] 區間測速
- [ ] 導航整合
- [ ] 雲端同步
- [ ] 訂閱制功能
- [ ] 資料匯出
- [ ] 多語言支援

### 11.3 待研究

- [ ] 測速資料自動更新機制
- [ ] iOS 背景定位審核要求
- [ ] App Store / Google Play 上架需求

---

## 附錄

### A. 主要依賴套件

| 類別 | 套件 |
|------|------|
| 狀態管理 | flutter_bloc, equatable |
| 路由 | go_router |
| 依賴注入 | get_it |
| 資料庫 | isar_community |
| 設定儲存 | shared_preferences |
| 位置服務 | geolocator |
| 地圖 | flutter_map, latlong2 |
| 3D 模型 | model_viewer_plus |
| TTS | flutter_tts |
| 網路 | dio |
| 效能優化 | quadtree |

### B. 版本紀錄

| 版本 | 日期 | 說明 |
|------|------|------|
| v0.1 | 2025/11/25 | 初版草稿，完成測速頁面、紀錄頁面規格 |
| v0.2 | 2025/12/28 | 根據實作更新規格，新增技術架構、資料結構、服務層等詳細說明 |
