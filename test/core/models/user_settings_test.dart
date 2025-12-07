import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/models/speed_unit.dart';

void main() {
  group('UserSettings Model', () {
    test('應該建立預設設定', () {
      final settings = UserSettings.defaults();

      expect(settings.speedUnit, SpeedUnit.kmh);
      expect(settings.isVoiceAlertEnabled, true);
      expect(settings.voiceVolume, 0.8);
      expect(settings.isPushNotificationEnabled, true);
    });

    test('copyWith 應該正確更新欄位', () {
      final original = UserSettings.defaults();
      final updated = original.copyWith(
        speedUnit: SpeedUnit.mph,
        isVoiceAlertEnabled: false,
        voiceVolume: 0.5,
      );

      expect(updated.speedUnit, SpeedUnit.mph);
      expect(updated.isVoiceAlertEnabled, false);
      expect(updated.voiceVolume, 0.5);
      // 未更新的欄位應保持原值
      expect(updated.alertDistance, 500);
      expect(updated.isPushNotificationEnabled, true);
    });

    test('toJson 應該正確轉換為 JSON', () {
      final settings = UserSettings(
        speedUnit: SpeedUnit.mph,
        isVoiceAlertEnabled: false,
        voiceVolume: 0.6,
        alertDistance: 300,
      );

      final json = settings.toJson();

      expect(json['speedUnit'], 'mph');
      expect(json['isVoiceAlertEnabled'], false);
      expect(json['voiceVolume'], 0.6);
      expect(json['alertDistance'], 300);
    });

    test('fromJson 應該正確從 JSON 建立物件', () {
      final json = {
        'speedUnit': 'mph',
        'isVoiceAlertEnabled': false,
        'voiceVolume': 0.6,
        'voiceSpeechRate': 0.7,
        'alertDistance': 300,
        'speedTolerance': 10,
        'isPushNotificationEnabled': false,
        'isMaintenanceReminderEnabled': true,
        'maintenanceReminderDays': 14,
        'isAnalyticsEnabled': true,
        'isAutoBackupEnabled': true,
        'showSpeedLimit': false,
        'showSpeedCamera': true,
        'mapDisplayMode': 'satellite',
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.speedUnit, SpeedUnit.mph);
      expect(settings.isVoiceAlertEnabled, false);
      expect(settings.voiceVolume, 0.6);
      expect(settings.voiceSpeechRate, 0.7);
      expect(settings.alertDistance, 300);
      expect(settings.speedTolerance, 10);
      expect(settings.isPushNotificationEnabled, false);
      expect(settings.isMaintenanceReminderEnabled, true);
      expect(settings.maintenanceReminderDays, 14);
      expect(settings.isAnalyticsEnabled, true);
      expect(settings.isAutoBackupEnabled, true);
      expect(settings.showSpeedLimit, false);
      expect(settings.showSpeedCamera, true);
      expect(settings.mapDisplayMode, MapDisplayMode.satellite);
    });

    test('fromJson 應該在無效資料時使用預設值', () {
      final json = {
        'speedUnit': 'invalid',
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.speedUnit, SpeedUnit.kmh);
      expect(settings.isVoiceAlertEnabled, true);
      expect(settings.voiceVolume, 0.8);
    });

    test('序列化與反序列化應該保持一致', () {
      final original = UserSettings(
        speedUnit: SpeedUnit.mph,
        isVoiceAlertEnabled: false,
        voiceVolume: 0.9,
        voiceSpeechRate: 0.4,
        alertDistance: 800,
        speedTolerance: 15,
        isPushNotificationEnabled: false,
        isMaintenanceReminderEnabled: false,
        maintenanceReminderDays: 30,
        isAnalyticsEnabled: true,
        isAutoBackupEnabled: true,
        lastBackupTime: DateTime(2024, 1, 1, 12, 0),
        showSpeedLimit: false,
        showSpeedCamera: false,
        mapDisplayMode: MapDisplayMode.satellite,
      );

      final json = original.toJson();
      final decoded = UserSettings.fromJson(json);

      expect(decoded.speedUnit, original.speedUnit);
      expect(decoded.isVoiceAlertEnabled, original.isVoiceAlertEnabled);
      expect(decoded.voiceVolume, original.voiceVolume);
      expect(decoded.voiceSpeechRate, original.voiceSpeechRate);
      expect(decoded.alertDistance, original.alertDistance);
      expect(decoded.speedTolerance, original.speedTolerance);
      expect(decoded.isPushNotificationEnabled, original.isPushNotificationEnabled);
      expect(decoded.isMaintenanceReminderEnabled, original.isMaintenanceReminderEnabled);
      expect(decoded.maintenanceReminderDays, original.maintenanceReminderDays);
      expect(decoded.isAnalyticsEnabled, original.isAnalyticsEnabled);
      expect(decoded.isAutoBackupEnabled, original.isAutoBackupEnabled);
      expect(decoded.lastBackupTime, original.lastBackupTime);
      expect(decoded.showSpeedLimit, original.showSpeedLimit);
      expect(decoded.showSpeedCamera, original.showSpeedCamera);
      expect(decoded.mapDisplayMode, original.mapDisplayMode);
    });

    test('相等性比較應該正確運作', () {
      final settings1 = UserSettings.defaults();
      final settings2 = UserSettings.defaults();
      final settings3 = UserSettings.defaults().copyWith(
        speedUnit: SpeedUnit.mph,
      );

      expect(settings1 == settings2, true);
      expect(settings1 == settings3, false);
      expect(settings1.hashCode == settings2.hashCode, true);
      expect(settings1.hashCode == settings3.hashCode, false);
    });

    test('toString 應該返回有意義的字串', () {
      final settings = UserSettings.defaults();
      final str = settings.toString();

      expect(str, contains('UserSettings'));
      expect(str, contains('speedUnit'));
      expect(str, contains('isVoiceAlertEnabled'));
      expect(str, contains('voiceVolume'));
    });
  });

  group('Enum Tests', () {
    test('MapDisplayMode 應該有正確的顯示名稱', () {
      expect(MapDisplayMode.standard.displayName, '標準');
      expect(MapDisplayMode.satellite.displayName, '衛星');
    });
  });

  group('JSON Edge Cases', () {
    test('處理 null lastBackupTime', () {
      final json = {
        'lastBackupTime': null,
      };

      final settings = UserSettings.fromJson(json);
      expect(settings.lastBackupTime, null);
    });

    test('處理有效的 lastBackupTime', () {
      final now = DateTime.now();
      final json = {
        'lastBackupTime': now.toIso8601String(),
      };

      final settings = UserSettings.fromJson(json);
      expect(settings.lastBackupTime, isNotNull);
      expect(settings.lastBackupTime?.year, now.year);
      expect(settings.lastBackupTime?.month, now.month);
      expect(settings.lastBackupTime?.day, now.day);
    });

    test('處理數值類型轉換', () {
      final json = {
        'voiceVolume': 0.8, // double
        'alertDistance': 500, // int
        'speedTolerance': 5, // int
      };

      final settings = UserSettings.fromJson(json);
      expect(settings.voiceVolume, 0.8);
      expect(settings.alertDistance, 500);
      expect(settings.speedTolerance, 5);
    });

    test('處理空 JSON', () {
      final json = <String, dynamic>{};
      final settings = UserSettings.fromJson(json);

      // 應該使用預設值
      expect(settings.speedUnit, SpeedUnit.kmh);
      expect(settings.isVoiceAlertEnabled, true);
      expect(settings.voiceVolume, 0.8);
    });
  });
}
