import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/speed_camera_model.dart';

void main() {
  group('SpeedCameraModel', () {
    late SpeedCameraModel testModel;

    setUp(() {
      testModel = SpeedCameraModel(
        speedLimit: 50,
        currentSpeed: 60.0,
        distance: 500.0,
        isOverSpeed: true,
        latitude: 25.0330,
        longitude: 121.5654,
        heading: 180.0,
      );
    });

    group('建構子', () {
      test('應該正確建立 SpeedCameraModel', () {
        expect(testModel.speedLimit, 50);
        expect(testModel.currentSpeed, 60.0);
        expect(testModel.distance, 500.0);
        expect(testModel.isOverSpeed, true);
        expect(testModel.latitude, 25.0330);
        expect(testModel.longitude, 121.5654);
        expect(testModel.heading, 180.0);
      });

      test('heading 應該有預設值 0.0', () {
        final model = SpeedCameraModel(
          speedLimit: 50,
          currentSpeed: 40.0,
          distance: 300.0,
          isOverSpeed: false,
          latitude: 25.0,
          longitude: 121.0,
        );

        expect(model.heading, 0.0);
      });
    });

    group('maxSpeed 常數', () {
      test('maxSpeed 應該是 300', () {
        expect(SpeedCameraModel.maxSpeed, 300);
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新單一欄位', () {
        final updated = testModel.copyWith(currentSpeed: 80.0);

        expect(updated.speedLimit, testModel.speedLimit);
        expect(updated.currentSpeed, 80.0);
        expect(updated.distance, testModel.distance);
        expect(updated.isOverSpeed, testModel.isOverSpeed);
        expect(updated.latitude, testModel.latitude);
        expect(updated.longitude, testModel.longitude);
        expect(updated.heading, testModel.heading);
      });

      test('應該正確複製並更新多個欄位', () {
        final updated = testModel.copyWith(
          speedLimit: 70,
          currentSpeed: 65.0,
          isOverSpeed: false,
          heading: 90.0,
        );

        expect(updated.speedLimit, 70);
        expect(updated.currentSpeed, 65.0);
        expect(updated.isOverSpeed, false);
        expect(updated.heading, 90.0);
        // 未更新的欄位應保持原值
        expect(updated.distance, testModel.distance);
        expect(updated.latitude, testModel.latitude);
        expect(updated.longitude, testModel.longitude);
      });

      test('不傳入參數時應該返回相等的副本', () {
        final copied = testModel.copyWith();

        expect(copied.speedLimit, testModel.speedLimit);
        expect(copied.currentSpeed, testModel.currentSpeed);
        expect(copied.distance, testModel.distance);
        expect(copied.isOverSpeed, testModel.isOverSpeed);
        expect(copied.latitude, testModel.latitude);
        expect(copied.longitude, testModel.longitude);
        expect(copied.heading, testModel.heading);
      });
    });

    group('calculateDuration', () {
      test('速度為 0 時應該返回 Duration.zero', () {
        final model = testModel.copyWith(currentSpeed: 0.0);
        final duration = model.calculateDuration();

        expect(duration, Duration.zero);
      });

      test('低速時應該返回較短的持續時間', () {
        final model = testModel.copyWith(currentSpeed: 10.0);
        final duration = model.calculateDuration();

        // 最小持續時間約 4700ms
        expect(duration.inMilliseconds, greaterThanOrEqualTo(4700));
        expect(duration.inMilliseconds, lessThanOrEqualTo(5200));
      });

      test('高速時應該返回較長的持續時間', () {
        final model = testModel.copyWith(currentSpeed: 280.0);
        final duration = model.calculateDuration();

        // 接近最大持續時間 5200ms
        expect(duration.inMilliseconds, greaterThan(5000));
        expect(duration.inMilliseconds, lessThanOrEqualTo(5200));
      });

      test('速度與持續時間應該成正比', () {
        final lowSpeedModel = testModel.copyWith(currentSpeed: 50.0);
        final highSpeedModel = testModel.copyWith(currentSpeed: 200.0);

        final lowSpeedDuration = lowSpeedModel.calculateDuration();
        final highSpeedDuration = highSpeedModel.calculateDuration();

        expect(
          highSpeedDuration.inMilliseconds,
          greaterThan(lowSpeedDuration.inMilliseconds),
        );
      });

      test('速度超過 maxSpeed 時應該被限制', () {
        final model1 = testModel.copyWith(currentSpeed: 300.0);
        final model2 = testModel.copyWith(currentSpeed: 500.0);

        final duration1 = model1.calculateDuration();
        final duration2 = model2.calculateDuration();

        // 超過 maxSpeed 的速度應該被限制，所以持續時間應該相同
        expect(duration1.inMilliseconds, duration2.inMilliseconds);
      });

      test('持續時間應該在 4700-5200ms 範圍內', () {
        for (double speed = 1; speed <= 300; speed += 50) {
          final model = testModel.copyWith(currentSpeed: speed);
          final duration = model.calculateDuration();

          expect(
            duration.inMilliseconds,
            greaterThanOrEqualTo(4700),
            reason: 'Speed: $speed should have duration >= 4700ms',
          );
          expect(
            duration.inMilliseconds,
            lessThanOrEqualTo(5200),
            reason: 'Speed: $speed should have duration <= 5200ms',
          );
        }
      });

      test('負速度應該被處理為 0', () {
        final model = testModel.copyWith(currentSpeed: -50.0);
        final duration = model.calculateDuration();

        // 負速度被 clamp 到 0，所以 speedRatio 是 0
        // 但因為原始速度不是 0，所以不會直接返回 Duration.zero
        expect(duration.inMilliseconds, 4700);
      });
    });

    group('超速判斷', () {
      test('速度超過限速時 isOverSpeed 應該為 true', () {
        final model = SpeedCameraModel(
          speedLimit: 50,
          currentSpeed: 60.0,
          distance: 500.0,
          isOverSpeed: true,
          latitude: 25.0,
          longitude: 121.0,
        );

        expect(model.isOverSpeed, true);
        expect(model.currentSpeed > model.speedLimit, true);
      });

      test('速度低於限速時 isOverSpeed 應該為 false', () {
        final model = SpeedCameraModel(
          speedLimit: 50,
          currentSpeed: 40.0,
          distance: 500.0,
          isOverSpeed: false,
          latitude: 25.0,
          longitude: 121.0,
        );

        expect(model.isOverSpeed, false);
        expect(model.currentSpeed < model.speedLimit, true);
      });
    });

    group('方向（heading）', () {
      test('heading 應該可以是 0-360 之間的任意值', () {
        for (double heading = 0; heading <= 360; heading += 45) {
          final model = testModel.copyWith(heading: heading);
          expect(model.heading, heading);
        }
      });
    });
  });
}
