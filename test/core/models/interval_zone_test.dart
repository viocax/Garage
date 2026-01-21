import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/interval_zone.dart';

void main() {
  group('IntervalZone Model', () {
    late IntervalZone testZone;

    setUp(() {
      testZone = const IntervalZone(
        id: 'ZONE001',
        startCameraId: 'CAM_START',
        endCameraId: 'CAM_END',
        distance: 2500.0,
        speedLimit: 60,
      );
    });

    group('建構子', () {
      test('應該正確建立 IntervalZone 物件', () {
        expect(testZone.id, 'ZONE001');
        expect(testZone.startCameraId, 'CAM_START');
        expect(testZone.endCameraId, 'CAM_END');
        expect(testZone.distance, 2500.0);
        expect(testZone.speedLimit, 60);
      });
    });

    group('fromJson', () {
      test('應該正確從 JSON 建立物件', () {
        final json = {
          'id': 'ZONE002',
          'start_id': 'CAM_A',
          'end_id': 'CAM_B',
          'dist': 3000.0,
          'lim': 80,
        };

        final zone = IntervalZone.fromJson(json);

        expect(zone.id, 'ZONE002');
        expect(zone.startCameraId, 'CAM_A');
        expect(zone.endCameraId, 'CAM_B');
        expect(zone.distance, 3000.0);
        expect(zone.speedLimit, 80);
      });

      test('應該在缺少欄位時使用預設值', () {
        final json = <String, dynamic>{};

        final zone = IntervalZone.fromJson(json);

        expect(zone.id, '');
        expect(zone.startCameraId, '');
        expect(zone.endCameraId, '');
        expect(zone.distance, 0.0);
        expect(zone.speedLimit, 0);
      });
    });

    group('toJson', () {
      test('應該正確轉換為 JSON', () {
        final json = testZone.toJson();

        expect(json['id'], 'ZONE001');
        expect(json['start_id'], 'CAM_START');
        expect(json['end_id'], 'CAM_END');
        expect(json['dist'], 2500.0);
        expect(json['lim'], 60);
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新欄位', () {
        final updated = testZone.copyWith(speedLimit: 100);

        expect(updated.id, testZone.id);
        expect(updated.speedLimit, 100);
        expect(updated.distance, testZone.distance);
      });
    });
  });
}
