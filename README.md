# garage

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Known Issues

### Android Build Failure (2025-11-29)
**Issue:** `isar_flutter_libs` version 3.1.0+1 is incompatible with Android Gradle Plugin (AGP) 8.0+ (specifically 8.11.1 used in this project).
**Error:** `Namespace not specified. Specify a namespace in the module's build file: .../isar_flutter_libs-3.1.0+1/android/build.gradle`
**Cause:** AGP 8.0+ requires a `namespace` declaration in `build.gradle` for all modules, which the older `isar_flutter_libs` package lacks.
**Proposed Solution:** Migrate to `isar_community` packages or update to a version that supports AGP 8.0+.
