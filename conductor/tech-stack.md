# Technology Stack

## Core Framework & Language
*   **Language:** Dart (SDK ^3.10.1)
*   **Framework:** Flutter (3.10+)
*   **Target Platforms:** iOS (Primary), Android

## Architecture & State Management
*   **Pattern:** BLoC (Business Logic Component)
*   **State Management:** `flutter_bloc`, `equatable`
*   **Dependency Injection:** `get_it` (Service Locator pattern)
*   **Routing:** `go_router` (Declarative routing)

## Data Layer
*   **Local Database:** `isar_community` (NoSQL, binary storage)
*   **Local Storage:** `shared_preferences` (Key-value pairs for settings)
*   **Networking:** `dio` (HTTP client), `http`
*   **Serialization:** `json_serializable` (via `build_runner`)

## UI & Visuals
*   **Design Style:** Glassmorphism, Dark Theme
*   **3D Graphics:** `model_viewer_plus` (GLB model rendering)
*   **Charts:** `fl_chart` (Financial and performance data)
*   **Typography:** `google_fonts`
*   **Localization:** `easy_localization`

## Maps & Driving Services
*   **Maps:** `flutter_map` (OpenStreetMap integration)
*   **Coordinate Math:** `latlong2`
*   **Location:** `geolocator`
*   **Voice:** `flutter_tts` (Text-to-Speech alerts)
*   **Spatial Indexing:** `quadtree` (Efficient camera lookup)

## Services & Integration
*   **Cloud Sync:** 
    *   iCloud (via `icloud_storage`)
    *   Google Drive (via `googleapis`, `google_sign_in`)
*   **Monetization:** `google_mobile_ads` (AdMob)
*   **Analytics & Error Tracking:** Firebase Core, Firebase Crashlytics
*   **System Interaction:** `url_launcher`, `in_app_review`, `mobile_scanner`

## Development & DevOps
*   **Code Generation:** `build_runner`, `isar_community_generator`
*   **Testing:** `flutter_test`, `bloc_test`, `mocktail`
*   **Logging:** `logger` (Custom `Log` utility)
*   **Deployment:** `fastlane` (iOS automation)
