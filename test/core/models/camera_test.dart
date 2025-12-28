import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/camera.dart';

void main() {
  group('Camera Model', () {
    late Camera testCamera;

    setUp(() {
      testCamera = const Camera(
        id: 'CAM001',
        speedLimit: 50,
        latitude: 25.0330,
        longitude: 121.5654,
        direction: '北向南',
        description: '台北市信義區信義路四段',
      );
    });

    group('建構子', () {
      test('應該正確建立 Camera 物件', () {
        expect(testCamera.id, 'CAM001');
        expect(testCamera.speedLimit, 50);
        expect(testCamera.latitude, 25.0330);
        expect(testCamera.longitude, 121.5654);
        expect(testCamera.direction, '北向南');
        expect(testCamera.description, '台北市信義區信義路四段');
      });
    });

    group('fromJson', () {
      test('應該正確從 JSON 建立物件', () {
        final json = {
          'id': 'CAM002',
          'lim': 60,
          'lat': 25.0478,
          'lon': 121.5170,
          'dir': '東向西',
          'disc': '台北市中山區中山北路',
        };

        final camera = Camera.fromJson(json);

        expect(camera.id, 'CAM002');
        expect(camera.speedLimit, 60);
        expect(camera.latitude, 25.0478);
        expect(camera.longitude, 121.5170);
        expect(camera.direction, '東向西');
        expect(camera.description, '台北市中山區中山北路');
      });

      test('應該在缺少欄位時使用預設值', () {
        final json = <String, dynamic>{};

        final camera = Camera.fromJson(json);

        expect(camera.id, '');
        expect(camera.speedLimit, 0);
        expect(camera.latitude, 0.0);
        expect(camera.longitude, 0.0);
        expect(camera.direction, '');
        expect(camera.description, '');
      });

      test('應該正確處理 null 值', () {
        final json = {
          'id': null,
          'lim': null,
          'lat': null,
          'lon': null,
          'dir': null,
          'disc': null,
        };

        final camera = Camera.fromJson(json);

        expect(camera.id, '');
        expect(camera.speedLimit, 0);
        expect(camera.latitude, 0.0);
        expect(camera.longitude, 0.0);
        expect(camera.direction, '');
        expect(camera.description, '');
      });

      test('應該正確處理 int 類型的座標', () {
        final json = {
          'id': 'CAM003',
          'lim': 70,
          'lat': 25, // int instead of double
          'lon': 121, // int instead of double
          'dir': '南向北',
          'disc': '測試',
        };

        final camera = Camera.fromJson(json);

        expect(camera.latitude, 25.0);
        expect(camera.longitude, 121.0);
      });
    });

    group('toJson', () {
      test('應該正確轉換為 JSON', () {
        final json = testCamera.toJson();

        expect(json['id'], 'CAM001');
        expect(json['lim'], 50);
        expect(json['lat'], 25.0330);
        expect(json['lon'], 121.5654);
        expect(json['dir'], '北向南');
        expect(json['disc'], '台北市信義區信義路四段');
      });

      test('序列化與反序列化應該保持一致', () {
        final json = testCamera.toJson();
        final deserialized = Camera.fromJson(json);

        expect(deserialized.id, testCamera.id);
        expect(deserialized.speedLimit, testCamera.speedLimit);
        expect(deserialized.latitude, testCamera.latitude);
        expect(deserialized.longitude, testCamera.longitude);
        expect(deserialized.direction, testCamera.direction);
        expect(deserialized.description, testCamera.description);
      });
    });

    group('distanceTo', () {
      test('應該正確計算相同位置的距離 (0 公尺)', () {
        final distance = testCamera.distanceTo(
          testCamera.latitude,
          testCamera.longitude,
        );

        expect(distance, closeTo(0, 0.1));
      });

      test('應該正確計算短距離', () {
        // 約 1 公里的距離
        const lat2 = 25.0420; // 約北移 1 公里
        const lon2 = 121.5654;

        final distance = testCamera.distanceTo(lat2, lon2);

        // 預期約 1000 公尺，允許一些誤差
        expect(distance, closeTo(1000, 50));
      });

      test('應該正確計算較長距離', () {
        // 測試較長距離的計算（台北信義區到南方約 100 公里處）
        const southLat = 24.1330; // 約南移 100 公里
        const southLon = 121.5654;

        final distance = testCamera.distanceTo(southLat, southLon);

        // 預期約 100 公里，允許一些誤差
        expect(distance, closeTo(100000, 5000));
      });

      test('距離計算應該是正數', () {
        final distance = testCamera.distanceTo(0, 0);
        expect(distance, greaterThan(0));
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新單一欄位', () {
        final updated = testCamera.copyWith(speedLimit: 80);

        expect(updated.id, testCamera.id);
        expect(updated.speedLimit, 80);
        expect(updated.latitude, testCamera.latitude);
        expect(updated.longitude, testCamera.longitude);
        expect(updated.direction, testCamera.direction);
        expect(updated.description, testCamera.description);
      });

      test('應該正確複製並更新多個欄位', () {
        final updated = testCamera.copyWith(
          id: 'NEW_ID',
          speedLimit: 100,
          direction: '西向東',
        );

        expect(updated.id, 'NEW_ID');
        expect(updated.speedLimit, 100);
        expect(updated.direction, '西向東');
        // 未更新的欄位應保持原值
        expect(updated.latitude, testCamera.latitude);
        expect(updated.longitude, testCamera.longitude);
        expect(updated.description, testCamera.description);
      });

      test('不傳入參數時應該返回相等的副本', () {
        final copied = testCamera.copyWith();

        expect(copied.id, testCamera.id);
        expect(copied.speedLimit, testCamera.speedLimit);
        expect(copied.latitude, testCamera.latitude);
        expect(copied.longitude, testCamera.longitude);
        expect(copied.direction, testCamera.direction);
        expect(copied.description, testCamera.description);
      });
    });

    group('相等性', () {
      test('相同 id 的 Camera 應該相等', () {
        final camera1 = testCamera;
        final camera2 = testCamera.copyWith(speedLimit: 100);

        expect(camera1 == camera2, true);
      });

      test('不同 id 的 Camera 應該不相等', () {
        final camera1 = testCamera;
        final camera2 = testCamera.copyWith(id: 'DIFFERENT_ID');

        expect(camera1 == camera2, false);
      });

      test('hashCode 應該基於 id', () {
        final camera1 = testCamera;
        final camera2 = testCamera.copyWith(speedLimit: 100);

        expect(camera1.hashCode, camera2.hashCode);
      });

      test('identical 物件應該相等', () {
        expect(testCamera == testCamera, true);
      });
    });

    group('toString', () {
      test('應該返回有意義的字串表示', () {
        final str = testCamera.toString();

        expect(str, contains('Camera'));
        expect(str, contains('CAM001'));
        expect(str, contains('50 km/h'));
        expect(str, contains('北向南'));
        expect(str, contains('台北市信義區信義路四段'));
      });
    });
  });
}
