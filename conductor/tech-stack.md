# Technology Stack & Architecture

## Core Framework & Language

| Item | Technology |
|------|------------|
| Language | Dart (SDK ^3.10.1) |
| Framework | Flutter 3.10+ |
| Platforms | iOS (Primary), Android |

## Phase Planning

| Phase | Scope | Status |
|-------|-------|--------|
| **Phase 1** | Vehicle Records, Multi-vehicle, Charts, Ad System | 🔄 In Progress |
| **Phase 2** | QR Code Invoice Scanner, Cloud Sync, Subscription | 📋 Planned |
| **Phase 3** | Speed Camera Alerts, Interval Checks, 3D Animation | 📋 Planned |

## Architecture: Clean Architecture + BLoC

Data Flow: **UI → BLoC → UseCase → Repository → Service/DataSource**

### Layers

- **Presentation Layer**: Widgets + BLoC (State Management)
- **Domain Layer**: UseCases + Entities + Repository Interfaces
- **Data Layer**: Repository Implementations + Data Sources (Services)

### Dependency Injection

- **Tool**: `get_it` (Service Locator)
- **Registration**: `lib/core/di/service_locator.dart`
- **Scoping**: Services/Repositories as Singletons, BLoCs as Factories

## Data Layer & Persistence

| Usage | Technology |
|-------|------------|
| Local Database | `isar_community` (NoSQL) |
| Local Storage | `shared_preferences` |
| Networking | `dio` |
| Serialization | `json_serializable` |

## UI & Visuals

| Usage | Technology |
|-------|------------|
| Design System | Glassmorphism + Dark Theme |
| 3D Graphics | `model_viewer_plus` |
| Charts | `fl_chart` |
| Typography | `google_fonts` |
| Localization | `easy_localization` |

## Services & Integration

| Usage | Technology |
|-------|------------|
| Maps | `flutter_map` (OpenStreetMap) |
| Location | `geolocator` |
| TTS | `flutter_tts` |
| Cloud Sync | `icloud_storage`, `googleapis` |
| Monetization | `google_mobile_ads` (AdMob) |
| Analytics | Firebase Crashlytics |

## Development & DevOps

| Usage | Technology |
|-------|------------|
| Code Generation | `build_runner` |
| Testing | `flutter_test`, `bloc_test`, `mocktail` |
| Logging | `logger` (via `Log` wrapper) |
| Deployment | `fastlane` (iOS) |
