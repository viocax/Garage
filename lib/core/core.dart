/// 核心功能匯出檔案
///
/// 提供統一的入口點來存取核心功能，包含資料模型、資料倉儲、依賴注入等。
library core;

// Models
export 'models/speed_camera.dart';
export 'models/tabbar_type.dart';

// Repositories (只匯出介面，不匯出實作)
export 'repositories/speed_camera_repository.dart';

// Dependency Injection
// export 'di/service_locator.dart';

// Database (僅供內部使用，一般不需要直接存取)
// export 'database/isar_service.dart';
