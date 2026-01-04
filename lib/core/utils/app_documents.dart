class AppDocuments {
  static const String privacyPolicy = '''
# 隱私政策 (Privacy Policy)

最後更新日期：2026年1月4日

感謝您選擇使用 **Garage**（以下簡稱「本應用程式」）。我們非常重視您的隱私，本政策將說明我們如何處理您的資訊。

## 1. 資訊收集與使用

### 位置資訊 (Location Data)
本應用程式的「測速提醒」功能需要存取您的即時位置資訊，以便在您接近測速照相點時發出提醒。
*   **本機處理**：位置資訊僅在您的裝置上進行即時運算。
*   **不予上傳**：我們**不會**將您的位置資訊上傳至任何伺服器，亦不會與任何第三方分享您的行蹤。

### 車輛與維修紀錄
您在 App 中輸入的所有數據（如加油、維修、車輛資訊）均儲存於您的裝置本地資料庫中。
*   **雲端同步**：若您主動開啟雲端同步功能，資料將加密傳輸至您個人的 iCloud 或 Google Drive 空間。開發者無法存取您的雲端備份。

## 2. 第三方服務

本應用程式使用以下第三方服務，其可能收集用於識別您身份的資訊：
*   **Google AdMob**：用於顯示廣告。AdMob 可能收集您的廣告識別碼 (IDFA/AAID) 以提供相關廣告。
*   **Google Sign-In / Google Drive**：用於 Android 端的備份功能。
*   **iCloud**：用於 iOS 端的備份功能。

## 3. 資料安全
我們致力於保護您的資料。既然您的資料主要儲存於您的裝置上，保護資料的最佳方式是確保您的裝置安全並定期進行雲端備份。

## 4. 您的權益
您可以隨時透過裝置設定撤回位置權限，或在 App 中清除所有本地資料。

---

# Privacy Policy

Last updated: January 4, 2026

Thank you for choosing **Garage**. We value your privacy and this policy explains how we handle your information.

## 1. Information Collection and Use

### Location Data
The "Speed Camera Warning" feature requires access to your real-time location.
*   **Local Processing**: Location data is processed locally on your device in real-time.
*   **No Upload**: We **do not** upload your location data to any server, nor do we share it with third parties.

## 2. Third-party Services
We use the following services:
*   **Google AdMob**: For advertising purposes.
*   **Google Sign-In / Cloud Storage**: For your data backup.

## 3. Contact Us
If you have any questions, please contact us via the feedback section in the App.
''';

  static const String termsOfService = '''
# 使用條款 (Terms of Service)

歡迎使用 **Garage**。透過安裝或使用本應用程式，即表示您同意受以下條款約束。

## 1. 服務內容
Garage 提供車輛維修管理、加油紀錄統計以及測速照相偵測提醒服務。

## 2. 免責聲明 (非常重要)

### 測速資料準確性
*   本應用程式提供的測速照相資訊僅供參考，**不代表 100% 準確或即時**。數據來源可能存在誤差，或因道路工程、法規變更而有所變動。
*   **使用者負有遵守交通法規的完全責任**。開發者對於因使用本 App 而導致的任何交通罰單、事故或損失，不負任何法律或賠償責任。

### GPS 訊號與裝置限制
*   測速提醒功能受限於您裝置的 GPS 精準度及收訊狀況。在隧道、室內或收訊不佳處可能無法正常運作。

## 3. 資料遺失
雖然本 App 提供雲端同步功能，但開發者不保證第三方服務（如 iCloud/Google Drive）的絕對穩定性。建議使用者重要資料應自行備份。

## 4. 地圖數據授權 (Map Data Attribution)
本應用程式的地圖數據由 **OpenStreetMap** 提供，並遵循 **Open Database License (ODbL)**。
*   © OpenStreetMap contributors

## 5. 服務變更
我們保留随时修改條款或停止服務的權利。

---

# Terms of Service

## 1. Service Description
Garage provides vehicle maintenance logging and speed camera alerts.

## 2. Disclaimer
*   Speed camera data is for reference only. Accuracy is **not guaranteed**.
*   **Users are solely responsible for following traffic laws**. We are not liable for any traffic tickets or accidents.
*   GPS accuracy depends on your hardware and environment.

## 3. Map Data Attribution
Map data in this application is provided by **OpenStreetMap** under the **Open Database License (ODbL)**.
*   © OpenStreetMap contributors

## 4. Changes
We reserve the right to modify these terms at any time.
''';
  static const String openSourceLicenses = '''
# 開源授權與致謝 (Open Source Licenses & Attributions)

## 3D 車輛模型 (3D Vehicle Models)
本應用程式中的 3D 車輛模型遵循 **Creative Commons Attribution 4.0 International (CC BY 4.0)** 授權。
*   授權詳情：[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

---

# Open Source Licenses & Attributions

## 3D Vehicle Models
The 3D vehicle models in this application are licensed under **Creative Commons Attribution 4.0 International (CC BY 4.0)**.
*   License details: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
''';
}
