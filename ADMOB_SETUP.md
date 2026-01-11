# AdMob 廣告配置指南

本文檔記錄 Garage App 的 Google AdMob 廣告完整配置流程和檢查清單。

---

## 📊 廣告配置概覽

### 已實現的廣告類型

| 廣告類型 | 位置 | 顯示時機 | 控制機制 |
|---------|------|----------|----------|
| **Interstitial（插頁式）** | 新增記錄/車輛完成後 | 操作成功時 | 5分鐘冷卻 + 廣告票券 |
| **Banner（橫幅）** | Records/Settings/車輛管理頁面底部 | 頁面載入時 | 12小時免除期 |
| **Rewarded（獎勵）** | 設定 → 廣告管理 | 用戶主動觀看 | 無限制 |
| **Native（原生）** | 所有記錄列表 | 每 8 條記錄插入 1 個 | 免廣告用戶跳過 |
| **App Open** | 應用恢復 | 後台返回前台 | 4 小時快取 |

---

## ✅ 已完成配置

### 1. AdMob 控制台配置

#### Android App ID
```
ca-app-pub-8569390201968394~5911085961
```

#### iOS App ID
```
ca-app-pub-8569390201968394~9990109387
```

#### Ad Unit IDs（各平台 5 個）

| 類型 | Android | iOS |
|------|---------|-----|
| Banner | `ca-app-pub-8569390201968394/5200817139` | `ca-app-pub-8569390201968394/5416261945` |
| Interstitial | `ca-app-pub-8569390201968394/9411347278` | `ca-app-pub-8569390201968394/4987202322` |
| Rewarded | `ca-app-pub-8569390201968394/6785183937` | `ca-app-pub-8569390201968394/3751826485` |
| Native | `ca-app-pub-8569390201968394/6112581733` | `ca-app-pub-8569390201968394/6432145933` |
| App Open | `ca-app-pub-8569390201968394/1457013246` | `ca-app-pub-8569390201968394/1477016930` |

### 2. 代碼配置

#### ✅ `lib/core/config/ad_config.dart`
- 已配置所有生產環境 Ad Unit ID
- 保留測試 ID 用於開發階段

#### ✅ `lib/core/config/ad_constants.dart`（新建）
集中管理廣告參數：
```dart
- interstitialCooldown: Duration(minutes: 5)        // 插頁式廣告冷卻時間
- interstitialRetryDelays: [2s, 4s, 8s]            // 重試延遲序列
- bannerAdFreeDuration: Duration(hours: 12)         // 橫幅廣告免除時長
- appOpenCacheDuration: Duration(hours: 4)          // App Open 快取期限
- nativeAdInterval: 8                               // 原生廣告間隔
- adTicketRewardAmount: 1                           // 票券獎勵數量
```

#### ✅ `lib/core/service/ad/mobile_ad_service.dart`
- 已添加測試設備配置功能（只在 Debug 模式啟用）
- 支援 Android 和 iOS 測試設備 ID

### 3. 平台配置

#### ✅ Android - `android/app/src/main/AndroidManifest.xml`
```xml
<!-- App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-8569390201968394~5911085961"/>

<!-- 廣告 ID 權限 (Android 13+ 必須) -->
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

#### ✅ iOS - `ios/Runner/Info.plist`
```xml
<!-- App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-8569390201968394~9990109387</string>

<!-- 追蹤權限說明 (iOS 14.5+ 必須) -->
<key>NSUserTrackingUsageDescription</key>
<string>我們會使用您的資料來提供個性化的廣告體驗，以支持應用的免費使用。</string>
```

---

## ⏳ 待完成配置

### 1. 測試設備 ID 配置（開發階段必須）

#### 為什麼需要？
- 使用正式 Ad Unit ID 但避免帳號被封禁
- 可以安全點擊測試廣告
- 不影響收益統計

#### 如何獲取測試設備 ID？

##### Android 設備
1. 運行應用（Debug 模式）
2. 觸發任何廣告
3. 查看 Logcat，搜索 `test ads`
4. 找到類似訊息：
   ```
   To get test ads on this device, call:
   MobileAds.setRequestConfiguration(...
       .setTestDeviceIds(Arrays.asList("33BE2250B43518CCDA7DE426D04EE231"))
   ```
5. 複製設備 ID：`33BE2250B43518CCDA7DE426D04EE231`

##### iOS 設備
1. 運行應用（Debug 模式）
2. 觸發任何廣告
3. 查看 Xcode Console，搜索 `test ads`
4. 找到類似訊息：
   ```
   <Google> To get test ads on this device, set:
   GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers =
   @[ @"2077ef9a63d2b398840261c8221a0c9b" ];
   ```
5. 複製設備 ID：`2077ef9a63d2b398840261c8221a0c9b`

#### 配置位置
編輯 `lib/core/service/ad/mobile_ad_service.dart` 第 37-40 行：

```dart
final List<String> testDeviceIds = [
  '33BE2250B43518CCDA7DE426D04EE231',  // Android 設備
  '2077ef9a63d2b398840261c8221a0c9b',  // iOS 設備
];
```

#### 驗證成功
運行應用後看到：
```
✅ AdMob 測試設備已配置: [33BE2250B43518CCDA7DE426D04EE231]
```
廣告會顯示 "Test Ad" 標籤。

---

### 2. Google Play Console - Data Safety 表單（Android 上架時）

#### 必須聲明的數據類型

##### A. Location（位置）
```
✓ Approximate location（大致位置）
✓ Precise location（精確位置）

Collection: Required
Purpose: App functionality（應用功能 - 測速照相）
Shared: No
```

##### B. Device or other IDs（設備或其他 ID）
```
✓ Advertising ID（廣告 ID）

Collection: Required
Purpose: Advertising or marketing（廣告或行銷）
Shared: Yes - Third parties (Google AdMob)
```

##### C. App activity（應用活動）
如果使用 Firebase Analytics：
```
✓ App interactions（應用互動）

Collection: Optional
Purpose: Analytics（分析）
Shared: Yes - Google Analytics
```

#### 關鍵問題回答

| 問題 | 回答 |
|------|------|
| 是否收集或分享用戶數據？ | Yes |
| 傳輸中的數據是否加密？ | Yes |
| 是否提供數據刪除方式？ | No（廣告 ID 無法刪除，但用戶可重置）|

---

### 3. App Store Connect - App Privacy（iOS 上架時）

#### 必須聲明的數據類型

##### A. Data Used to Track You（用於追蹤您的資料）
```
✓ Advertising Data
  - Purpose: Third-Party Advertising
  - Linked to User: No

✓ Device ID
  - Purpose: Third-Party Advertising
  - Linked to User: No
```

##### B. Data Collected（收集的資料）

**Location:**
```
✓ Precise Location
  - Purpose: App Functionality（測速照相）
  - Linked to User: Yes
  - Used for Tracking: No
```

**Identifiers:**
```
✓ Device ID
  - Purpose: Third-Party Advertising
  - Linked to User: No
  - Used for Tracking: Yes

✓ Advertising Data
  - Purpose: Third-Party Advertising
  - Linked to User: No
  - Used for Tracking: Yes
```

---

### 4. 隱私政策頁面（必須）

#### 為什麼需要？
- Google Play 和 App Store 強制要求
- 使用第三方廣告服務必須提供
- 必須包含 AdMob 數據使用說明

#### 必須包含的內容

##### 基本資訊
- 應用收集哪些數據
- 數據如何使用
- 與誰分享數據
- 用戶權利說明

##### AdMob 相關條款（必須）
```
本應用使用 Google AdMob 服務展示廣告。AdMob 可能會收集：
- 廣告標識符（IDFA/AAID）
- 設備資訊（型號、作業系統版本）
- IP 位址
- 應用互動數據

這些數據用於：
- 提供個性化廣告
- 廣告效果分析
- 防詐欺檢測

詳細資訊請參考：
- Google 隱私權政策: https://policies.google.com/privacy
- AdMob 數據使用說明: https://support.google.com/admob/answer/6128543
```

##### 位置數據條款
```
本應用收集精確位置數據用於：
- 顯示附近的測速照相機
- 背景監測並提醒用戶

位置數據不會用於廣告追蹤或與第三方分享。
```

#### 發布位置
1. **建議：** 創建專門的隱私政策網頁
   - 可使用 GitHub Pages 免費託管
   - URL 範例：`https://yourname.github.io/garage-privacy-policy/`

2. **或使用：** Google Play / App Store 商品資訊中的文字說明
   - 不推薦，因為無法提供超連結

#### 隱私政策生成工具（可選）
- https://app-privacy-policy-generator.nisrulz.com/
- https://www.termsfeed.com/privacy-policy-generator/

---

### 5. 原生廣告自定義樣式（可選，提升用戶體驗）

#### 當前狀態
- 使用 Google 預設樣式
- 可能與應用設計不一致

#### 優化建議
需要在原生代碼層實作：

##### Android
1. 創建自定義 Layout XML
2. 在 `MainActivity.kt` 註冊 Factory

##### iOS
1. 創建 NIB 文件定義 UI
2. 在 `AppDelegate.swift` 註冊 Factory

**優先級：** 中等（不影響審核，但影響體驗）

---

## 🚨 上架前檢查清單

### Android (Google Play)

- [x] AndroidManifest.xml 包含 App ID
- [x] AndroidManifest.xml 包含 AD_ID 權限
- [ ] 測試設備 ID 已配置並測試
- [ ] Data Safety 表單已填寫
- [ ] 隱私政策 URL 已提供
- [ ] APK/AAB 已通過內部測試

### iOS (App Store)

- [x] Info.plist 包含 App ID
- [x] Info.plist 包含 NSUserTrackingUsageDescription
- [ ] 測試設備 ID 已配置並測試
- [ ] App Privacy 標籤已填寫
- [ ] 隱私政策 URL 已提供
- [ ] TestFlight 內部測試已通過

### 通用

- [ ] 測試所有 5 種廣告類型正常顯示
- [ ] 測試廣告冷卻機制正常運作
- [ ] 測試廣告票券系統正常運作
- [ ] 測試獎勵廣告獎勵正確發放
- [ ] 確認 Release 模式不使用測試設備配置
- [ ] AdMob 帳號已完成支付資訊設定

---

## 📱 測試流程

### 開發階段測試（使用測試設備）

1. **配置測試設備 ID**
   - 按照「待完成配置 #1」步驟獲取並配置

2. **運行應用（Debug 模式）**
   ```bash
   flutter run
   ```

3. **驗證配置成功**
   - Console 顯示：`✅ AdMob 測試設備已配置`
   - 廣告顯示 "Test Ad" 標籤

4. **測試各類型廣告**
   - Banner: 進入 Records/Settings 頁面
   - Interstitial: 新增一筆記錄
   - Rewarded: 設定 → 廣告管理 → 獲取票券
   - Native: 查看所有記錄列表
   - App Open: 將應用切到背景再返回

5. **測試廣告機制**
   - 冷卻時間：5 分鐘內連續新增記錄，第二次不應顯示廣告
   - 票券系統：觀看獎勵廣告獲取票券 → 新增記錄應跳過廣告
   - Banner 免除：觀看獎勵廣告 → Banner 應消失 12 小時

### 發布前測試（Release 模式）

1. **移除測試設備 ID**
   ```dart
   final List<String> testDeviceIds = [
     // 清空或註釋掉所有設備 ID
   ];
   ```

2. **構建 Release 版本**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

3. **內部測試**
   - Android: Google Play Internal Testing
   - iOS: TestFlight

4. **驗證正式廣告**
   - 確認不顯示 "Test Ad" 標籤
   - ⚠️ 不要點擊廣告
   - 確認 AdMob 控制台有請求計數

---

## ⚙️ 廣告參數調整

### 可調整的參數（在 `AdConstants`）

```dart
// 插頁式廣告冷卻時間（避免打擾用戶）
static const Duration interstitialCooldown = Duration(minutes: 5);

// 橫幅廣告免除時長（獎勵廣告獎勵）
static const Duration bannerAdFreeDuration = Duration(hours: 12);

// App Open 廣告快取期限
static const Duration appOpenCacheDuration = Duration(hours: 4);

// 原生廣告間隔（每 N 條記錄插入 1 個）
static const int nativeAdInterval = 8;

// 廣告票券獎勵數量
static const int adTicketRewardAmount = 1;
```

### 調整建議

#### 提高收益
- 減少 `interstitialCooldown`（例如 3 分鐘）
- 減少 `nativeAdInterval`（例如每 5 條）

#### 提升體驗
- 增加 `interstitialCooldown`（例如 10 分鐘）
- 增加 `bannerAdFreeDuration`（例如 24 小時）
- 增加 `adTicketRewardAmount`（例如 3 張）

---

## 🔍 常見問題

### Q1: 為什麼測試時看到的是測試廣告？
A: 因為你的設備 ID 已添加到測試列表。這是正確的，確保開發時不會影響帳號。

### Q2: Release 版本會顯示測試廣告嗎？
A: 不會。測試設備配置只在 `!kReleaseMode` 時啟用，發布版本會自動忽略。

### Q3: 用戶拒絕追蹤權限會怎樣？
A:
- iOS: 會顯示非個性化廣告，收益較低但仍有收入
- Android: 多數用戶不會主動關閉，默認允許

### Q4: 如何檢查廣告是否正常運作？
A:
1. AdMob 控制台查看請求數
2. 應用內測試各類型廣告
3. 檢查 Console 日誌無錯誤

### Q5: 廣告載入失敗怎麼辦？
A:
- 檢查網路連接
- 確認 App ID 和 Ad Unit ID 正確
- 查看 Console 錯誤訊息
- 等待 AdMob 審核通過（新帳號需要時間）

### Q6: 何時可以開始產生收益？
A:
- App 上架後即可開始
- AdMob 需要累積 $100 才能提領
- 通常需要數千到數萬用戶才能達到

---

## 📞 支援資源

### Google AdMob
- 官方文檔: https://developers.google.com/admob/flutter
- 政策中心: https://support.google.com/admob/answer/6128543
- 問題回報: https://support.google.com/admob/

### Flutter Plugin
- pub.dev: https://pub.dev/packages/google_mobile_ads
- GitHub: https://github.com/googleads/googleads-mobile-flutter

---

**最後更新：** 2026-01-11
**版本：** 1.0.0
**維護者：** Garage App Team
