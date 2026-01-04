# Plan: 訂閱制與進階統計 (Pro Subscription & Advanced Statistics)

## Phase 1: 進階統計功能 (Advanced Statistics) [checkpoint: 2a0dee1]
- [x] Task: 更新 `VehicleRecord` 模型，增加油耗計算輔助方法 `km/L`。 50b5a48
- [x] Task: 實作 `FuelEfficiencyChart` 元件，展示加油效率趨勢（折線圖）。 2c7afd6
- [x] Task: 實作 `AnnualExpenseComparison` 元件，比較不同年度的總花費。 2c7afd6
- [x] Task: 整合進階統計至 `AllRecordsPage`，並為非訂閱用戶實作鎖定/預覽遮蓋 UI。 1d20d64
- [x] Task: Conductor - User Manual Verification 'Phase 1' (Protocol in workflow.md)

## Phase 2: RevenueCat 整合與訂閱架構 (RevenueCat Integration)
- [x] Task: 安裝 `purchases_flutter` 並實作 `SubscriptionService` 初始化核心邏輯。
- [x] Task: 實作 `SubscriptionRepository` 以管理訂閱狀態流與購買動作力。
- [~] Task: 建立 `PremiumPage` 訂閱頁面 UI，包含月訂閱與年訂閱選項。
- [ ] Task: 實作「還原購買 (Restore Purchases)」功能並驗證狀態同步。
- [ ] Task: Conductor - User Manual Verification 'Phase 2' (Protocol in workflow.md)

## Phase 3: 功能權限控管 (Feature Gating)
- [x] Task: 實作 AdService 的 `removeAds` 邏輯，當 `isPro` 為 true 時停用所有廣告。
- [x] Task: 實作 Cloud Sync 的權限檢查，非 Pro 用戶限制使用雲端備份功能。
- [x] Task: 在全域 Bloc (如 `AppBloc` 或透過 `SubscriptionRepository` 流) 中實作訂閱狀態的自動更新。
- [ ] Task: 實作訂閱成功後的歡迎導引或狀態標籤更新。
- [ ] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
