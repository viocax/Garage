import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/interval_zone.dart';
import 'package:garage/core/service/location/interval_manager.dart';

void main() {
  group('IntervalManager', () {
    late IntervalManager intervalManager;
    late IntervalZone testZone;

    setUp(() {
      intervalManager = IntervalManager();
      testZone = const IntervalZone(
        id: 'ZONE001',
        startCameraId: 'START',
        endCameraId: 'END',
        distance: 2000.0, // 2km
        speedLimit: 60,
      );
    });

    test('初始狀態應為未啟用', () {
      expect(intervalManager.isActive, isFalse);
      expect(intervalManager.currentZone, isNull);
    });

    group('進入與離開區間', () {
      test('進入區間後狀態應為啟用', () {
        intervalManager.enterZone(testZone);
        expect(intervalManager.isActive, isTrue);
        expect(intervalManager.currentZone, testZone);
      });

      test('離開區間後狀態應為停用並重置', () {
        intervalManager.enterZone(testZone);
        intervalManager.exitZone();
        expect(intervalManager.isActive, isFalse);
        expect(intervalManager.currentZone, isNull);
      });
    });

    group('平均速度計算 (calculateStatus)', () {
      test('計算邏輯：1km 跑 60 秒，平均速度應為 60km/h', () {
        final entryTime = DateTime(2026, 1, 1, 12, 0, 0);
        intervalManager.enterZone(testZone, startTime: entryTime);

        final updateTime = entryTime.add(const Duration(seconds: 60));
        
        final state = intervalManager.calculateStatus(
          distanceTraveled: 1000.0,
          currentTime: updateTime,
        );

        expect(state.averageSpeed, closeTo(60.0, 0.1));
        expect(state.remainingDistance, 1000.0);
        expect(state.distanceTraveled, 1000.0);
        expect(state.timeElapsed, 60);
        expect(state.isOverSpeed, isFalse);
      });

      test('計算邏輯：1km 跑 30 秒，平均速度應為 120km/h 且超速', () {
        final entryTime = DateTime(2026, 1, 1, 12, 0, 0);
        intervalManager.enterZone(testZone, startTime: entryTime);

        final updateTime = entryTime.add(const Duration(seconds: 30));
        
        final state = intervalManager.calculateStatus(
          distanceTraveled: 1000.0,
          currentTime: updateTime,
        );

        expect(state.averageSpeed, closeTo(120.0, 0.1));
        expect(state.isOverSpeed, isTrue);
      });

      test('當時間差為 0 時，平均速度應為 0', () {
        final entryTime = DateTime(2026, 1, 1, 12, 0, 0);
        intervalManager.enterZone(testZone, startTime: entryTime);

        final state = intervalManager.calculateStatus(
          distanceTraveled: 0.0,
          currentTime: entryTime,
        );

        expect(state.averageSpeed, 0);
        expect(state.timeElapsed, 0);
      });

      test('未進入區間時調用應返回全 0 狀態', () {
        final state = intervalManager.calculateStatus(distanceTraveled: 100);
        expect(state.averageSpeed, 0);
        expect(state.distanceTraveled, 0);
      });
    });
  });
}
