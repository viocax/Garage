# Tech Stack - Garage (車庫)

## 1. Core Frameworks & Languages
- **Language**: [Dart](https://dart.dev/)
- **Framework**: [Flutter](https://flutter.dev/) (3.10+)
- **Platforms**: iOS, Android

## 2. State Management & Architecture
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [Cubit](https://pub.dev/packages/bloc)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Data Models**: [equatable](https://pub.dev/packages/equatable)

## 3. Data Storage & Persistence
- **Local Database**: [isar_community](https://isar.dev/) (High-performance NoSQL)
- **Persistent Settings**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Cloud Sync**: 
  - [icloud_storage](https://pub.dev/packages/icloud_storage) (iOS)
  - [google_sign_in](https://pub.dev/packages/google_sign_in) & [googleapis](https://pub.dev/packages/googleapis) (Android/Google Drive)

## 4. UI, Maps & Graphics
- **3D Rendering**: [model_viewer_plus](https://pub.dev/packages/model_viewer_plus)
- **Maps**: [flutter_map](https://pub.dev/packages/flutter_map) (OpenStreetMap based)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts)
- **Theming**: Custom specialized dark themed UI

## 5. Device Services
- **Location**: [geolocator](https://pub.dev/packages/geolocator)
- **Text-to-Speech**: [flutter_tts](https://pub.dev/packages/flutter_tts)
- **Network**: [dio](https://pub.dev/packages/dio)
