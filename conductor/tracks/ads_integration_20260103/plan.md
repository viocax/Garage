# Plan: Google AdMob 整合計畫

本計畫旨在將五種主要的廣告形式整合至 Garage App 中，並確保與現有 UI/UX 融合，同時預留未來「移除廣告」的擴充介面。

## Phase 1: 基礎建設 (Infrastructure)
- [x] Task: 新增 `google_mobile_ads` 依賴套件。
- [x] Task: iOS 專案配置 (`Info.plist`) 加入 AdMob App ID (使用測試 ID)。
- [x] Task: Android 專案配置 (`AndroidManifest.xml`) 加入 AdMob App ID (使用測試 ID)。
- [x] Task: 建立 `AdService` 介面與實作，處理 SDK 初始化。
- [x] Task: 在 `ServiceLocator` (GetIt) 中註冊 `AdService`。
- [x] Task: 在 `UserSettings` 加入 `isAdFree` 欄位（預設為 false），作為未來付費解鎖的開關。

## Phase 2: 基礎廣告實作 (Banner & App Open)
- [x] Task: 實作 `BannerAdWidget` 共用元件。
- [x] Task: 在「設定頁面 (SettingsPage)」底部加入 Banner 廣告。
- [x] Task: 在「車輛管理 (VehicleManagementPage)」底部加入 Banner 廣告。
- [x] Task: 實作 `AppOpenAdRepository`，處理 App 從背景回到前景的廣告展示邏輯。
- [x] Task: 在 `AdService` (或 App Lifecycle) 中整合 `AppOpenAdRepository`，並設定頻率限制（如 4 小時一次）。

## Phase 3: 插頁式廣告 (Interstitial Ads)
- [x] Task: 在 `AdService` 中實作插頁式廣告的預載 (Pre-load) 與展示邏輯。
- [x] Task: 整合點 1：在「新增紀錄 (AddRecord)」成功並按下儲存後，顯示插頁廣告，關閉後才返回列表。
- [x] Task: 整合點 2：在「新增車輛 (AddVehicle)」成功後，顯示插頁廣告。
- [x] Task: 加入冷卻機制（Cooldown），確保短時間內連續操作不會連續跳出廣告。

## Phase 4: 原生廣告 (Native Ads)
- [ ] Task: 在 `AdService` 中實作原生廣告工廠。
- [ ] Task: 設計 `NativeAdCard` Widget，使其外觀與 `RecordCard` 相似（融合 UI）。
- [ ] Task: 修改 `RecordListBloc` 或列表邏輯，在每 8-10 筆紀錄中插入一個廣告佔位符。
- [ ] Task: 實作列表中的原生廣告渲染。

## Phase 5: 獎勵廣告 (Rewarded Ads)
- [ ] Task: 在 `AdService` 中實作獎勵廣告邏輯。
- [ ] Task: 在「設定頁面」新增「觀看廣告移除橫幅」的選項。
- [ ] Task: 實作獎勵回調邏輯：觀看完整影片後，將 `isAdFree` 暫時設為 true (例如 24 小時) 或僅移除 Banner。
- [ ] Task: 顯示 Toast 或 SnackBar 告知使用者獎勵已發放。

## Phase 6: 測試與優化
- [ ] Task: 全面測試 iOS 實機上的廣告展示與點擊。
- [ ] Task: 確認廣告不會在「測速儀表板」或「行車模式」中誤觸發。
- [x] Task: 檢查記憶體洩漏問題 (確保 Ad Object 正確 dispose)。
