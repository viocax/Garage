# Garage 車庫

一款專為汽車愛好者設計的車輛管理 App，結合 **車輛紀錄管理** 與 **測速照相提醒** 功能。

## Features

### Phase 1: Vehicle Records *(Current)*
- 多車管理與保養健康度追蹤
- 加油 / 保養 / 其他消費紀錄
- 月度/年度統計圖表

### Phase 2: QR Code & Cloud Sync *(Planned)*
- 發票 QR Code 掃描
- iCloud / Google Drive 雲端同步
- Premium 訂閱制

### Phase 3: Speed Camera *(Planned)*
- 測速照相提醒 (TTS 語音)
- 區間測速計算
- 3D 車輛動畫

## Tech Stack

| 項目 | 技術 |
|------|------|
| Framework | Flutter 3.10+ |
| State | BLoC |
| Database | Isar |
| Design | Glassmorphism, Dark Theme |

## Quick Start

### Requirements
- Flutter SDK >= 3.10.1
- Xcode 15+ (iOS)
- iOS 12.0+

### Run
```bash
flutter pub get
flutter run
```

## Marketing Website

This project includes a separate Flutter Web project for the marketing landing page.

- **Source**: [`marketing_web/`](./marketing_web/)
- **Branch**: `feat/marketing-web-init`
- **Deployment Script**: [`deploy_marketing.sh`](./deploy_marketing.sh)
- **Live URL**: [https://drakehuang81.github.io/Garage/](https://drakehuang81.github.io/Garage/)

### Deployment

Run the deployment script from the project root:

```bash
./deploy_marketing.sh
```

This will build the web app and push it to the `gh-pages` branch.

## Documentation

詳細文件請參考 [`conductor/`](./conductor/)：

| 文件 | 說明 |
|------|------|
| [product.md](./conductor/product.md) | 產品定義、Roadmap |
| [spec.md](./conductor/spec.md) | UI 規格書 |
| [tech-stack.md](./conductor/tech-stack.md) | 技術架構 |
| [tracks.md](./conductor/tracks.md) | 開發進度追蹤 |

### Setup Guides
- [ADMOB_SETUP.md](./ADMOB_SETUP.md) - 廣告配置
- [CRASHLYTICS_SETUP.md](./CRASHLYTICS_SETUP.md) - 錯誤追蹤

## Project Structure

```
lib/
├── core/           # Models, Repositories, Services, DI
├── screen/         # UI Pages (speed, records, settings)
├── router/         # GoRouter
├── theme/          # AppTheme
└── widgets/        # Shared Components
```

## License

本專案僅供個人學習使用。

## Contact

- **Email**: [garagesup812860@gmail.com](mailto:garagesup812860@gmail.com)
