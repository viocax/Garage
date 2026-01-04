# Plan: 訂閱制與進階統計 (Pro Subscription & Advanced Statistics)

## Phase 1: 進階統計功能 (Advanced Statistics) [checkpoint: 2a0dee1]
- [x] Task: 更新 `VehicleRecord` 模型，增加油耗計算輔助方法 `km/L`。 50b5a48
- [x] Task: 實作 `FuelEfficiencyChart` 元件，展示加油效率趨勢（折線圖）。 2c7afd6
- [x] Task: 實作 `AnnualExpenseComparison` 元件，比較不同年度的總花費。 2c7afd6
- [x] Task: 整合進階統計至 `AllRecordsPage`，並為非訂閱用戶實作鎖定/預覽遮蓋 UI。 1d20d64
- [x] Task: Conductor - User Manual Verification 'Phase 1' (Protocol in workflow.md)

## Phase 2: RevenueCat 整合與訂閱架構 (RevenueCat Integration)
- [ ] Task: 安裝 `purchases_flutter` 並實作 `SubscriptionService` 初始化核心邏輯。
- [ ] Task: 實作 `SubscriptionRepository` 以管理訂閱狀態流與購買動作。
- [ ] Task: 建立 `PremiumPage` 訂閱頁面 UI，包含月訂閱與年訂閱選項。
- [ ] Task: 實作「還原購買 (Restore Purchases)」功能並驗證狀態同步。
- [ ] Task: Conductor - User Manual Verification 'Phase 2' (Protocol in workflow.md)

## Phase 3: 功能門控與權限實作 (Feature Gating)
- [ ] Task: 整合訂閱狀態至 `AdRepository`，為 Pro 用戶移除所有廣告單元。
- [ ] Task: 限制「雲端備份與還原」功能僅供 Pro 用戶使用。
- [ ] Task: 解鎖 Phase 1 實作的進階統計圖表。
- [ ] Task: 實作訂閱成功後的歡迎導引或狀態標籤更新。
- [ ] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
