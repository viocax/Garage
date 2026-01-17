# Technology Stack & Architecture

## Core Framework & Language
*   **Language:** Dart (SDK ^3.10.1)
*   **Framework:** Flutter (3.10+)
*   **Target Platforms:** iOS (Primary), Android

## Architecture: Clean Architecture + BLoC

The project follows **Clean Architecture** principles to separate concerns and ensure testability and maintainability.

### 1. Layers (Separation of Concerns)

The data flow is strict and unidirectional: **UI -> BLoC -> UseCase -> Repository -> Service/DataSource**.

*   **Presentation Layer (UI & State):**
    *   **Widgets:** Pure UI components (Screens, Pages). They **only** interact with BLoCs.
    *   **BLoC (Business Logic Component):** Manages state. Receives events from UI, executes UseCases, and emits new States. It **never** accesses Repositories or Services directly.

*   **Domain Layer (Business Rules):**
    *   **UseCases (Interactors):** Encapsulate specific business rules (e.g., `GetInvoicesUseCase`, `SyncDataUseCase`). They orchestrate data flow from Repositories.
    *   **Entities (Models):** Pure Dart objects representing business data, independent of frameworks (e.g., `Vehicle`, `Invoice`).
    *   **Repository Interfaces:** Abstract definitions of data operations (e.g., `IVehicleRepository`). Inverts dependency so Domain doesn't know about Data.

*   **Data Layer (Implementation):**
    *   **Repositories (impl):** Implement Domain interfaces. Coordinate data retrieval from multiple sources (e.g., Local DB vs Cloud). **Wait! Where do I put logic?** -> Simple data fetching/caching logic goes here. Complex business rules go to UseCases.
    *   **Data Sources (Services):**
        *   **Local:** `IsarService`, `SharedPreferencesService`.
        *   **Remote:** `MofApiInvoiceService`, `FirebaseService`, `DriveService`.

### 2. Dependency Injection (DI)

*   **Tool:** `get_it` (Service Locator pattern).
*   **Registration:** All dependencies are registered in `lib/core/di/service_locator.dart`.
*   **Scoping:**
    *   Services/Repositories are typically Singletons/LazySingletons.
    *   BLoCs are often Factories (created per screen) or Singletons (if global).

## Data Layer & Persistence

*   **Local Database:** `isar_community` (NoSQL, binary storage)
    *   Used for storing `Vehicle`, `VehicleRecord`, `Settings`.
*   **Local Storage:** `shared_preferences` (Key-value pairs for simple user settings like Theme, Locale).
*   **Networking:** `dio` (HTTP client) preferred over `http` for interceptors/global config.
*   **Serialization:** `json_serializable` (via `build_runner`).

## UI & Visuals

*   **Design System:** Custom "Glassmorphism" theme.
*   **3D Graphics:** `model_viewer_plus` (GLB model rendering).
*   **Charts:** `fl_chart`.
*   **Typography:** `google_fonts`.
*   **Localization:** `easy_localization`.

## Services & Integration

*   **Maps:** `flutter_map` (OpenStreetMap).
*   **Location:** `geolocator`.
*   **TTS:** `flutter_tts`.
*   **Cloud Sync:**
    *   iCloud (`icloud_storage`)
    *   Google Drive (`googleapis`)
*   **Monetization:** `google_mobile_ads` (AdMob).
*   **Analytics:** Firebase Crashlytics.

## Development & DevOps

*   **Code Generation:** `build_runner`.
*   **Testing:** `flutter_test`, `bloc_test`, `mocktail`.
*   **Logging:** `logger` (Use strict `Log` class wrapper).
*   **Deployment:** `fastlane` (iOS automation).
