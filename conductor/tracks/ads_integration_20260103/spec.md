# Spec: 廣告整合規格書

## 1. 廣告單元 ID (Test IDs)

開發階段統一使用 Google 提供的測試 ID，以避免帳號違規。

| 廣告格式 | iOS Test ID | Android Test ID |
| :--- | :--- | :--- |
| **App ID** | `ca-app-pub-3940256099942544~1458002511` | `ca-app-pub-3940256099942544~3347511713` |
| **Banner** | `ca-app-pub-3940256099942544/2934735716` | `ca-app-pub-3940256099942544/6300978111` |
| **Interstitial** | `ca-app-pub-3940256099942544/4411468910` | `ca-app-pub-3940256099942544/1033173712` |
| **Rewarded** | `ca-app-pub-3940256099942544/1712485313` | `ca-app-pub-3940256099942544/5224354917` |
| **Native Advanced** | `ca-app-pub-3940256099942544/3986624511` | `ca-app-pub-3940256099942544/2247696110` |
| **App Open** | `ca-app-pub-3940256099942544/5662855259` | `ca-app-pub-3940256099942544/3419835294` |

## 2. 元件與邏輯設計

### 2.1 AdService
- **職責**：
  - 初始化 MobileAds SDK。
  - 管理廣告的預載 (Pre-load) 以加快顯示速度。
  - 提供 `showInterstitial()`, `showRewarded()` 等方法。
  - 監聽 App Lifecycle 處理 App Open Ad。
- **介面**：
  ```dart
  abstract class AdService {
    Future<void> initialize();
    Widget getBannerAd({required AdSize size});
    Future<void> showInterstitialAd({required VoidCallback onComplete});
    Future<void> showRewardedAd({required Function(RewardItem) onUserEarnedReward});
    Future<void> loadNativeAd();
    bool get isAdFree; 
  }
  ```

### 2.2 顯示策略

| 頁面/功能 | 廣告類型 | 觸發時機/位置 | 備註 |
| :--- | :--- | :--- | :--- |
| **App 啟動/切換** | App Open | 從背景回到前景時 | 需設定 Cool-down (如 4 小時)，避免頻繁干擾。 |
| **設定頁面** | Banner | 頁面底部 (BottomNavigationBar 上方) | 固定顯示。 |
| **新增紀錄** | Interstitial | 按下「儲存」且資料寫入成功後 | 這是高價值操作斷點。 |
| **紀錄列表** | Native | 列表中每隔 8 筆資料插入一則 | 樣式需客製化以融入 App 風格。 |
| **設定頁面** | Rewarded | 使用者主動點擊「觀看廣告移除 Banner」 | 獎勵：24 小時內 `isAdFree = true`。 |

### 2.3 安全規範
- **測速儀表板 (Speed Dashboard)**：嚴禁顯示任何廣告。
- **行車模式中**：嚴禁彈出任何全螢幕廣告。

## 3. UI 整合

### 3.1 Banner
- 使用 `SizedBox` 包裹 `AdWidget`。
- 高度依據 `AdSize.banner` (通常 50px) 或 `AdSize.fullBanner`。

### 3.2 Native Ad
- 在 `ListView.builder` 中，根據 index 判斷是否回傳廣告 Widget。
- 例如：`if (index % 8 == 0 && index != 0) return NativeAdWidget();`

## 4. 未來擴充 (IAP)
- 目前 `isAdFree` 僅由 Rewarded Ad 觸發暫時性狀態。
- 未來接入 RevenueCat 或 In_app_purchase 後，將此狀態永久寫入 UserSettings 或雲端。
