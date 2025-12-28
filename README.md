# Garage - 車輛管理助手

一款專為汽車愛好者設計的車輛管理 App，主打 **測速照相提醒** 與 **保養/加油紀錄** 兩大核心功能。

## 功能特色

### 測速照相提醒
- 即時 GPS 速度偵測
- 前方測速照相警示（距離 + 限速）
- TTS 語音播報提醒
- 地圖顯示測速照相位置
- 3D 車輛動畫視覺效果
- 超速顏色警告（正常/接近/超速）

### 車輛紀錄管理
- 多車輛管理支援
- 加油紀錄（油種、公升數、單價）
- 保養紀錄（多項目、下次保養里程）
- 其他消費紀錄
- 保養健康度追蹤
- 月度/總計花費統計

### 個人化設定
- 速度單位切換（km/h / mph）
- 語音提示開關與音量調整
- 提醒距離與超速容忍值設定
- 地圖顯示模式（標準/衛星）

## 技術架構

| 項目 | 技術選擇 |
|------|----------|
| 框架 | Flutter |
| 平台 | iOS / Android |
| 狀態管理 | Flutter BLoC |
| 路由 | GoRouter |
| 依賴注入 | GetIt |
| 資料庫 | Isar Community |
| 設定儲存 | SharedPreferences |

## 專案結構

```
lib/
├── main.dart                # 應用程式入口
├── core/                    # 核心層
│   ├── di/                  # 依賴注入
│   ├── models/              # 資料模型
│   ├── repositories/        # 資料儲存庫
│   ├── service/             # 服務層
│   └── utils/               # 工具類
├── screen/                  # 頁面層
│   ├── app/                 # 應用層 (Home, Launch)
│   ├── speed/               # 測速頁面
│   ├── records/             # 紀錄頁面
│   └── settings/            # 設定頁面
├── router/                  # 路由配置
├── theme/                   # 主題樣式
└── widgets/                 # 共用元件
```

## 開始使用

### 環境需求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- iOS 12.0+ / Android API 21+

### 安裝步驟

```bash
# 1. 複製專案
git clone https://github.com/your-repo/garage.git
cd garage

# 2. 安裝依賴
flutter pub get

# 3. 生成 Isar 程式碼
dart run build_runner build

# 4. 執行應用
flutter run
```

### 開發指令

```bash
# 執行測試
flutter test

# 分析程式碼
flutter analyze

# 生成程式碼（Isar models）
dart run build_runner build --delete-conflicting-outputs

# 建置 APK
flutter build apk --release

# 建置 iOS
flutter build ios --release
```

## 主要依賴套件

| 類別 | 套件 |
|------|------|
| 狀態管理 | `flutter_bloc`, `equatable` |
| 路由 | `go_router` |
| 依賴注入 | `get_it` |
| 資料庫 | `isar_community` |
| 位置服務 | `geolocator` |
| 地圖 | `flutter_map`, `latlong2` |
| 3D 模型 | `model_viewer_plus` |
| TTS | `flutter_tts` |
| 網路 | `dio` |

## 開發進度

### Phase 1（開發中）
- [x] 測速頁面 - 即時速度與照相提醒
- [x] 紀錄頁面 - 車輛與消費管理
- [x] 設定頁面 - 個人化選項
- [x] 3D 車輛動畫
- [x] TTS 語音播報
- [ ] 背景執行支援

### Phase 2（規劃中）
- [ ] 區間測速偵測
- [ ] 導航整合
- [ ] 雲端同步
- [ ] 資料匯出

## 授權

本專案僅供個人學習使用。

## 文件

詳細規格請參閱 [Garage 軟體規格書](./Garage_軟體規格書_v0.1.md)
