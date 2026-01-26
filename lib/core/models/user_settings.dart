import 'speed_unit.dart';

/// 使用者設定模型
class UserSettings {
  // ===== 測速設定 =====
  /// 速度單位
  final SpeedUnit speedUnit;

  /// 語音提示開關
  final bool isVoiceAlertEnabled;

  /// 語音音量 (0.0 - 1.0)
  final double voiceVolume;

  /// 語音語速 (0.0 - 1.0)
  final double voiceSpeechRate;

  /// 提前提醒距離（公尺）
  final int alertDistance;

  /// 超速容忍值（km/h）
  final int speedTolerance;

  /// 偵測扇形角度（度）
  final double sectorAngle;

  // ===== 通知設定 =====
  /// 推送通知開關
  final bool isPushNotificationEnabled;

  /// 保養提醒通知
  final bool isMaintenanceReminderEnabled;

  /// 提前幾天提醒保養
  final int maintenanceReminderDays;

  // ===== 隱私與資料 =====
  /// 是否允許資料分析
  final bool isAnalyticsEnabled;

  /// 是否允許自動備份
  final bool isAutoBackupEnabled;

  /// 上次備份時間
  final DateTime? lastBackupTime;

  // ===== 顯示設定 =====
  /// 是否顯示速度上限
  final bool showSpeedLimit;

  /// 是否顯示測速照相機
  final bool showSpeedCamera;

  /// 地圖顯示模式（標準/衛星）
  final MapDisplayMode mapDisplayMode;

  // ===== 進階設定 =====
  /// 是否免廣告 (VIP)
  final bool isAdFree;

  /// 廣告票券數量 (可用於跳過插頁廣告)
  final int adTicketCount;

  /// 橫幅廣告移除期限 (獎勵廣告)
  final DateTime? bannerAdFreeUntil;

  const UserSettings({
    // 測速設定
    this.speedUnit = SpeedUnit.kmh,
    this.isVoiceAlertEnabled = false,
    this.voiceVolume = 0.8,
    this.voiceSpeechRate = 0.5,
    this.alertDistance = 500,
    this.speedTolerance = 0,
    this.sectorAngle = 60.0,

    // 通知設定
    this.isPushNotificationEnabled = true,
    this.isMaintenanceReminderEnabled = true,
    this.maintenanceReminderDays = 7,

    // 隱私與資料
    this.isAnalyticsEnabled = false,
    this.isAutoBackupEnabled = false,
    this.lastBackupTime,

    // 顯示設定
    this.showSpeedLimit = true,
    this.showSpeedCamera = true,
    this.mapDisplayMode = MapDisplayMode.standard,

    // 進階設定
    this.isAdFree = false,
    this.adTicketCount = 0,
    this.bannerAdFreeUntil,
  });

  /// 預設設定
  factory UserSettings.defaults() {
    return const UserSettings();
  }

  /// 從 JSON 建立
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      // 測速設定
      speedUnit: SpeedUnit.values.firstWhere(
        (e) => e.name == json['speedUnit'],
        orElse: () => SpeedUnit.kmh,
      ),
      isVoiceAlertEnabled: json['isVoiceAlertEnabled'] ?? false,
      voiceVolume: (json['voiceVolume'] as num?)?.toDouble() ?? 0.8,
      voiceSpeechRate: (json['voiceSpeechRate'] as num?)?.toDouble() ?? 0.5,
      alertDistance: json['alertDistance'] ?? 500,
      speedTolerance: json['speedTolerance'] ?? 0,
      sectorAngle: (json['sectorAngle'] as num?)?.toDouble() ?? 60.0,

      // 通知設定
      isPushNotificationEnabled: json['isPushNotificationEnabled'] ?? true,
      isMaintenanceReminderEnabled:
          json['isMaintenanceReminderEnabled'] ?? true,
      maintenanceReminderDays: json['maintenanceReminderDays'] ?? 7,

      // 隱私與資料
      isAnalyticsEnabled: json['isAnalyticsEnabled'] ?? false,
      isAutoBackupEnabled: json['isAutoBackupEnabled'] ?? false,
      lastBackupTime: json['lastBackupTime'] != null
          ? DateTime.parse(json['lastBackupTime'])
          : null,

      // 顯示設定
      showSpeedLimit: json['showSpeedLimit'] ?? true,
      showSpeedCamera: json['showSpeedCamera'] ?? true,
      mapDisplayMode: MapDisplayMode.values.firstWhere(
        (e) => e.name == json['mapDisplayMode'],
        orElse: () => MapDisplayMode.standard,
      ),

      // 進階設定
      isAdFree: json['isAdFree'] ?? false,
      adTicketCount: json['adTicketCount'] ?? 0,
      bannerAdFreeUntil: json['bannerAdFreeUntil'] != null
          ? DateTime.parse(json['bannerAdFreeUntil'])
          : null,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      // 測速設定
      'speedUnit': speedUnit.name,
      'isVoiceAlertEnabled': isVoiceAlertEnabled,
      'voiceVolume': voiceVolume,
      'voiceSpeechRate': voiceSpeechRate,
      'alertDistance': alertDistance,
      'speedTolerance': speedTolerance,
      'sectorAngle': sectorAngle,

      // 通知設定
      'isPushNotificationEnabled': isPushNotificationEnabled,
      'isMaintenanceReminderEnabled': isMaintenanceReminderEnabled,
      'maintenanceReminderDays': maintenanceReminderDays,

      // 隱私與資料
      'isAnalyticsEnabled': isAnalyticsEnabled,
      'isAutoBackupEnabled': isAutoBackupEnabled,
      'lastBackupTime': lastBackupTime?.toIso8601String(),

      // 顯示設定
      'showSpeedLimit': showSpeedLimit,
      'showSpeedCamera': showSpeedCamera,
      'mapDisplayMode': mapDisplayMode.name,

      // 進階設定
      // 進階設定
      'isAdFree': isAdFree,
      'adTicketCount': adTicketCount,
      'bannerAdFreeUntil': bannerAdFreeUntil?.toIso8601String(),
    };
  }

  /// 複製並修改部分欄位
  UserSettings copyWith({
    // 測速設定
    SpeedUnit? speedUnit,
    bool? isVoiceAlertEnabled,
    double? voiceVolume,
    double? voiceSpeechRate,
    String? voiceEngine,
    int? alertDistance,
    int? speedTolerance,
    double? sectorAngle,

    // 通知設定
    bool? isPushNotificationEnabled,
    bool? isMaintenanceReminderEnabled,
    int? maintenanceReminderDays,

    // 隱私與資料
    bool? isAnalyticsEnabled,
    bool? isAutoBackupEnabled,
    DateTime? lastBackupTime,

    // 顯示設定
    bool? showSpeedLimit,
    bool? showSpeedCamera,
    MapDisplayMode? mapDisplayMode,

    // 進階設定
    bool? isAdFree,
    int? adTicketCount,
    DateTime? bannerAdFreeUntil,
  }) {
    return UserSettings(
      // 測速設定
      speedUnit: speedUnit ?? this.speedUnit,
      isVoiceAlertEnabled: isVoiceAlertEnabled ?? this.isVoiceAlertEnabled,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceSpeechRate: voiceSpeechRate ?? this.voiceSpeechRate,
      alertDistance: alertDistance ?? this.alertDistance,
      speedTolerance: speedTolerance ?? this.speedTolerance,
      sectorAngle: sectorAngle ?? this.sectorAngle,

      // 通知設定
      isPushNotificationEnabled:
          isPushNotificationEnabled ?? this.isPushNotificationEnabled,
      isMaintenanceReminderEnabled:
          isMaintenanceReminderEnabled ?? this.isMaintenanceReminderEnabled,
      maintenanceReminderDays:
          maintenanceReminderDays ?? this.maintenanceReminderDays,

      // 隱私與資料
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      isAutoBackupEnabled: isAutoBackupEnabled ?? this.isAutoBackupEnabled,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,

      // 顯示設定
      showSpeedLimit: showSpeedLimit ?? this.showSpeedLimit,
      showSpeedCamera: showSpeedCamera ?? this.showSpeedCamera,
      mapDisplayMode: mapDisplayMode ?? this.mapDisplayMode,

      // 進階設定
      isAdFree: isAdFree ?? this.isAdFree,
      adTicketCount: adTicketCount ?? this.adTicketCount,
      bannerAdFreeUntil: bannerAdFreeUntil ?? this.bannerAdFreeUntil,
    );
  }

  @override
  String toString() {
    return 'UserSettings('
        'speedUnit: $speedUnit, '
        'isVoiceAlertEnabled: $isVoiceAlertEnabled, '
        'voiceVolume: $voiceVolume, '
        'isAdFree: $isAdFree, '
        'adTicketCount: $adTicketCount, '
        'bannerAdFreeUntil: $bannerAdFreeUntil'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings &&
        other.speedUnit == speedUnit &&
        other.isVoiceAlertEnabled == isVoiceAlertEnabled &&
        other.voiceVolume == voiceVolume &&
        other.voiceSpeechRate == voiceSpeechRate &&
        other.alertDistance == alertDistance &&
        other.speedTolerance == speedTolerance &&
        other.sectorAngle == sectorAngle &&
        other.isPushNotificationEnabled == isPushNotificationEnabled &&
        other.isMaintenanceReminderEnabled == isMaintenanceReminderEnabled &&
        other.maintenanceReminderDays == maintenanceReminderDays &&
        other.isAnalyticsEnabled == isAnalyticsEnabled &&
        other.isAutoBackupEnabled == isAutoBackupEnabled &&
        other.lastBackupTime == lastBackupTime &&
        other.showSpeedLimit == showSpeedLimit &&
        other.showSpeedCamera == showSpeedCamera &&
        other.mapDisplayMode == mapDisplayMode &&
        other.isAdFree == isAdFree &&
        other.adTicketCount == adTicketCount &&
        other.bannerAdFreeUntil == bannerAdFreeUntil;
  }

  @override
  int get hashCode {
    return Object.hash(
      speedUnit,
      isVoiceAlertEnabled,
      voiceVolume,
      voiceSpeechRate,
      alertDistance,
      speedTolerance,
      sectorAngle,
      isPushNotificationEnabled,
      isMaintenanceReminderEnabled,
      maintenanceReminderDays,
      isAnalyticsEnabled,
      isAutoBackupEnabled,
      lastBackupTime,
      showSpeedLimit,
      showSpeedCamera,
      mapDisplayMode,
      isAdFree,
      adTicketCount,
      bannerAdFreeUntil,
    );
  }
}

/// 地圖顯示模式
enum MapDisplayMode {
  standard('標準'),
  satellite('衛星');

  final String displayName;
  const MapDisplayMode(this.displayName);
}
