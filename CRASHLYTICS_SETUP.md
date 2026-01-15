# Firebase Crashlytics 配置指南

本文檔記錄 Garage App 的 Firebase Crashlytics 完整配置流程與使用方式。

## 目錄
- [功能概述](#功能概述)
- [iOS 配置](#ios-配置)
- [使用方式](#使用方式)
- [測試驗證](#測試驗證)
- [BLoC 整合](#bloc-整合)
- [故障排除](#故障排除)
- [相關資源](#相關資源)

## 功能概述

Firebase Crashlytics 提供即時崩潰報告和錯誤追蹤，協助快速定位和修復問題：

### 主要功能
- ✅ **自動錯誤捕獲**：自動捕獲 Flutter framework 錯誤
- ✅ **平台層支援**：自動捕獲 iOS native 層崩潰
- ✅ **非致命錯誤記錄**：記錄不會導致崩潰的錯誤
- ✅ **用戶追蹤**：設定用戶識別碼以追蹤特定用戶問題
- ✅ **自定義日誌**：附加上下文資訊到崩潰報告
- ✅ **Debug 模式停用**：開發時自動停用數據收集，避免測試資料污染

### 實作位置
- **服務實作**：`lib/core/service/firebase_service.dart`
- **初始化**：`lib/main.dart`
- **依賴注入**：`lib/core/di/service_locator.dart`

---

## iOS 配置

### 1. Firebase 專案設定

#### 步驟 1：建立 Firebase 專案
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「新增專案」或選擇現有專案
3. 依照指示完成專案設定

#### 步驟 2：新增 iOS 應用程式
1. 在 Firebase Console 點擊「新增應用程式」
2. 選擇 iOS 圖示
3. 輸入以下資訊：
   - **iOS 套件 ID**：`com.drake.garage`
   - **應用程式暱稱**：Garage（選填）
   - **App Store ID**：（選填，上架後填入）

#### 步驟 3：下載配置檔案
1. 下載 `GoogleService-Info.plist`
2. 將檔案放置於專案的 `ios/Runner/` 目錄
3. 確認檔案在 Xcode 專案中正確加入

**重要**：`GoogleService-Info.plist` 包含敏感資訊，已在 `.gitignore` 中排除，請勿提交到版本控制。

### 2. Dependencies 配置

專案的 `pubspec.yaml` 已包含必要依賴：

```yaml
dependencies:
  firebase_core: ^3.13.0
  firebase_crashlytics: ^4.3.4
```

無需額外配置，執行 `flutter pub get` 即可。

### 3. 初始化流程

應用程式啟動時的初始化順序（`main.dart`）：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化 Firebase Core
  await Firebase.initializeApp();

  // 2. 初始化依賴注入容器
  await setupServiceLocator();

  // 3. 初始化 Firebase 服務 (包含 Crashlytics)
  await getIt.service.firebase.initialize();

  // 4. 啟動應用程式
  runApp(const GarageApp());
}
```

### 4. 自動配置說明

`FirebaseService.initialize()` 會自動完成以下配置：

- ✅ **環境檢測**：Debug 模式下自動停用數據收集
- ✅ **Flutter 錯誤捕獲**：設定 `FlutterError.onError` 處理器
- ✅ **平台錯誤捕獲**：設定 `PlatformDispatcher.onError` 處理器
- ✅ **錯誤格式化**：自動格式化錯誤訊息和堆疊追蹤

---

## 使用方式

### 記錄非致命錯誤

當捕獲到異常但不希望應用程式崩潰時使用：

```dart
try {
  await riskyOperation();
} catch (e, stack) {
  await getIt.service.firebase.recordError(
    e,
    stack,
    reason: '資料同步失敗',
    fatal: false,
  );

  // 可以繼續執行或向用戶顯示錯誤訊息
  Log.e('同步失敗，已記錄到 Crashlytics', e, stack);
}
```

### 記錄日誌

附加上下文資訊到後續的崩潰報告：

```dart
// 記錄用戶操作流程
await getIt.service.firebase.log('用戶進入設定頁面');
await getIt.service.firebase.log('開始資料同步: $vehicleCount 輛車');
await getIt.service.firebase.log('同步完成: ${syncResult.success}');

// 這些日誌會附加到接下來發生的任何崩潰報告中
```

### 設定用戶識別碼

追蹤特定用戶的問題（用於調查用戶回報的問題）：

```dart
// 用戶登入後設定
await getIt.service.firebase.setUserIdentifier('user_12345');

// 用戶登出時清除
await getIt.service.firebase.setUserIdentifier('');
```

### 自定義鍵值對

附加額外的應用程式狀態資訊：

```dart
// 記錄應用程式狀態
await getIt.service.firebase.setCustomKey('vehicle_count', 5);
await getIt.service.firebase.setCustomKey('last_sync', DateTime.now().toString());
await getIt.service.firebase.setCustomKey('app_version', '1.0.0');
await getIt.service.firebase.setCustomKey('has_premium', true);

// 這些資訊會附加到所有後續的崩潰報告中
```

---

## 測試驗證

### 前提條件

⚠️ **重要**：Crashlytics 在 iOS Simulator 上無法完整運作，**必須使用實體設備測試**。

### 方法 1：觸發測試崩潰（可選）

```dart
// 在開發環境或 Debug 選單中觸發
getIt.service.firebase.triggerTestCrash();
```

**注意**：此方法會導致應用程式崩潰，請謹慎使用。

### 方法 2：記錄測試錯誤（推薦）

```dart
// 在設定頁面或測試功能中執行
try {
  throw Exception('這是一個測試錯誤');
} catch (e, stack) {
  await getIt.service.firebase.recordError(
    e,
    stack,
    reason: 'Crashlytics 測試',
    fatal: false,
  );
  Log.i('測試錯誤已記錄到 Crashlytics');
}
```

### 驗證步驟

1. **執行應用程式**（實體設備）
   ```bash
   flutter run --release
   ```

2. **觸發錯誤**（使用上述方法之一）

3. **重啟應用程式**
   - Crashlytics 在應用程式下次啟動時才會上傳報告

4. **查看 Firebase Console**
   - 前往 [Firebase Console](https://console.firebase.google.com/)
   - 選擇專案 → Crashlytics
   - 等待 5-10 分鐘（報告處理時間）
   - 應該能看到崩潰或錯誤報告

### 驗證清單

- [ ] GoogleService-Info.plist 已正確放置
- [ ] 使用實體 iOS 設備（非 Simulator）
- [ ] 使用 Release 模式（Debug 模式已停用 Crashlytics）
- [ ] 觸發錯誤後已重啟應用程式
- [ ] 等待 5-10 分鐘後檢查 Firebase Console
- [ ] 能在 Crashlytics 儀表板看到報告

---

## BLoC 整合

### 在 BLoC 中自動記錄錯誤

覆寫 `onError` 方法以自動記錄所有 BLoC 錯誤：

```dart
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);

    // 自動記錄所有 BLoC 錯誤到 Crashlytics
    getIt.service.firebase.recordError(
      error,
      stackTrace,
      reason: 'VehicleBloc error: ${event.runtimeType}',
      fatal: false,
    );

    // 同時記錄到本地日誌
    Log.e('VehicleBloc 錯誤', error, stackTrace);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());
      final vehicles = await repository.getAllVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e, stack) {
      // 錯誤會自動被 onError 捕獲並記錄
      emit(VehicleError(e.toString()));
    }
  }
}
```

### Repository 層錯誤處理

在 Repository 中記錄關鍵操作的錯誤：

```dart
class VehicleRepository {
  Future<List<Vehicle>> getVehicles() async {
    try {
      // 記錄操作開始
      await getIt.service.firebase.log('開始載入車輛清單');

      final vehicles = await _database.getAll();

      // 記錄成功資訊
      await getIt.service.firebase.log('成功載入 ${vehicles.length} 輛車');
      await getIt.service.firebase.setCustomKey('last_vehicle_count', vehicles.length);

      return vehicles;
    } catch (e, stack) {
      Log.e('載入車輛失敗', e, stack);

      // 記錄非致命錯誤
      await getIt.service.firebase.recordError(
        e,
        stack,
        reason: 'Database query failed in VehicleRepository',
        fatal: false,
      );

      rethrow; // 向上層拋出，讓 BLoC 處理
    }
  }
}
```

---

## 故障排除

### 問題 1：崩潰報告未顯示在 Firebase Console

**可能原因與解決方案**：

1. **使用了 Simulator**
   - ✅ 解決：使用實體 iOS 設備測試

2. **GoogleService-Info.plist 未正確放置**
   - ✅ 檢查：檔案位於 `ios/Runner/GoogleService-Info.plist`
   - ✅ 檢查：檔案已在 Xcode 專案中加入

3. **使用 Debug 模式**
   - ✅ 解決：使用 Release 模式執行
   ```bash
   flutter run --release
   ```

4. **未重啟應用程式**
   - ✅ 解決：觸發錯誤後，完全關閉並重新啟動應用程式
   - Crashlytics 在下次啟動時才會上傳報告

5. **報告處理延遲**
   - ✅ 解決：等待 5-10 分鐘後再檢查 Firebase Console
   - 首次報告可能需要更長時間

### 問題 2：Debug 模式下看不到日誌

**這是預期行為**：

- Debug 模式下 Crashlytics 數據收集已停用
- 原因：避免開發時的測試數據污染生產環境報告
- 解決：使用 `Log` 工具查看即時日誌

```dart
// Debug 模式使用 Log 工具
Log.d('這個會在 Debug 模式顯示');

// Crashlytics 日誌僅在 Release 模式有效
await getIt.service.firebase.log('這個僅在 Release 模式記錄');
```

### 問題 3：Build 失敗或 Crashlytics 初始化錯誤

**解決步驟**：

```bash
# 1. 清理 iOS Pods
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..

# 2. 清理 Flutter build cache
flutter clean

# 3. 重新獲取依賴
flutter pub get

# 4. 重新建置
flutter build ios --release
```

### 問題 4：無法連接 Firebase

**檢查清單**：

- [ ] 網路連線正常
- [ ] Firebase 專案狀態正常（檢查 Firebase Console）
- [ ] GoogleService-Info.plist 內容正確（Bundle ID 等）
- [ ] 應用程式有網路權限（iOS 預設已有）

---

## 相關資源

### 官方文檔
- [Firebase Crashlytics 官方文檔](https://firebase.google.com/docs/crashlytics)
- [FlutterFire Crashlytics](https://firebase.flutter.dev/docs/crashlytics/overview)
- [Firebase Console](https://console.firebase.google.com/)

### 專案相關
- [Garage App 日誌管理指南](README.md#日誌管理-logging)
- [AdMob 配置指南](ADMOB_SETUP.md)
- [軟體規格書](Garage_軟體規格書_v0.1.md)

### 程式碼位置
- **Firebase 服務**：`lib/core/service/firebase_service.dart`
- **Log 工具**：`lib/core/utils/log.dart`
- **應用程式初始化**：`lib/main.dart`
- **服務定位器**：`lib/core/di/service_locator.dart`

---

## 最佳實踐

### 1. 錯誤分類

使用 `reason` 參數為錯誤分類，便於在 Firebase Console 中過濾：

```dart
// ✅ 好的做法：使用明確的分類
await crashlytics.recordError(e, stack, reason: 'Network: API timeout');
await crashlytics.recordError(e, stack, reason: 'Database: Query failed');
await crashlytics.recordError(e, stack, reason: 'UI: Invalid state');

// ❌ 避免：過於籠統的描述
await crashlytics.recordError(e, stack, reason: 'Error');
```

### 2. 日誌使用

記錄關鍵操作流程，協助重現問題：

```dart
// 記錄用戶操作序列
await crashlytics.log('用戶點擊新增車輛按鈕');
await crashlytics.log('開啟車輛表單');
await crashlytics.log('用戶輸入車輛資訊');
await crashlytics.log('提交表單');
// 如果此時發生錯誤，日誌會顯示完整操作流程
```

### 3. 自定義鍵使用

記錄重要的應用程式狀態：

```dart
// 應用程式狀態
await crashlytics.setCustomKey('app_version', packageInfo.version);
await crashlytics.setCustomKey('build_number', packageInfo.buildNumber);

// 用戶狀態
await crashlytics.setCustomKey('is_logged_in', authState.isAuthenticated);
await crashlytics.setCustomKey('subscription_status', user.subscriptionType);

// 功能使用情況
await crashlytics.setCustomKey('vehicles_count', vehicles.length);
await crashlytics.setCustomKey('last_sync_time', lastSyncTime.toString());
```

---

**最後更新**：2026-01-12
**版本**：1.0.0
**維護者**：Garage Development Team
