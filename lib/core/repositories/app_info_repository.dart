import 'package:package_info_plus/package_info_plus.dart';

/// App 資訊 Repository 介面
///
/// 提供應用程式版本資訊的讀取
abstract class AppInfoRepository {
  /// 取得 App 版本號 (e.g., "0.0.1")
  Future<String> getAppVersion();

  /// 取得 Build Number (e.g., "1")
  Future<String> getBuildNumber();

  /// 取得完整版本字串 (e.g., "Garage v0.0.1")
  Future<String> getFullVersionString();
}

/// App 資訊 Repository 本地實作
///
/// 使用 package_info_plus 從 native 層讀取版本資訊
class LocalAppInfoRepository implements AppInfoRepository {
  PackageInfo? _cachedInfo;

  Future<PackageInfo> _getPackageInfo() async {
    _cachedInfo ??= await PackageInfo.fromPlatform();
    return _cachedInfo!;
  }

  @override
  Future<String> getAppVersion() async {
    final info = await _getPackageInfo();
    return info.version;
  }

  @override
  Future<String> getBuildNumber() async {
    final info = await _getPackageInfo();
    return info.buildNumber;
  }

  @override
  Future<String> getFullVersionString() async {
    final info = await _getPackageInfo();
    return 'Garage v${info.version}';
  }
}
