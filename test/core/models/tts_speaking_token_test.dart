import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/tts_speaking_token.dart';

void main() {
  group('TTSSpeakingToken', () {
    late DateTime testTime;
    late TTSSpeakingToken testToken;

    setUp(() {
      testTime = DateTime(2024, 1, 15, 10, 30, 0);
      testToken = TTSSpeakingToken(
        currentSpeed: 65.0,
        speedLimit: 50.0,
        distance: 300.0,
        lastReportTime: testTime,
      );
    });

    group('建構子', () {
      test('應該正確建立 TTSSpeakingToken', () {
        expect(testToken.currentSpeed, 65.0);
        expect(testToken.speedLimit, 50.0);
        expect(testToken.distance, 300.0);
        expect(testToken.lastReportTime, testTime);
      });

      test('可選的 onExecute 回調應該可以設定', () async {
        var executed = false;

        final token = TTSSpeakingToken(
          currentSpeed: 60.0,
          speedLimit: 50.0,
          distance: 200.0,
          lastReportTime: testTime,
          onExecute: (t) async {
            executed = true;
          },
        );

        expect(token, isNotNull);
        await token.execute();
        expect(executed, true);
      });
    });

    group('QueueableItem 實作', () {
      test('execute 應該呼叫 onExecute 回調', () async {
        var executeCount = 0;
        TTSSpeakingToken? receivedToken;

        final token = TTSSpeakingToken(
          currentSpeed: 60.0,
          speedLimit: 50.0,
          distance: 200.0,
          lastReportTime: testTime,
          onExecute: (t) async {
            executeCount++;
            receivedToken = t;
          },
        );

        await token.execute();

        expect(executeCount, 1);
        expect(receivedToken, token);
      });

      test('execute 在沒有 onExecute 時不應該拋出錯誤', () async {
        final token = TTSSpeakingToken(
          currentSpeed: 60.0,
          speedLimit: 50.0,
          distance: 200.0,
          lastReportTime: testTime,
        );

        // 不應該拋出錯誤
        await expectLater(token.execute(), completes);
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新單一欄位', () {
        final updated = testToken.copyWith(currentSpeed: 80.0);

        expect(updated.currentSpeed, 80.0);
        expect(updated.speedLimit, testToken.speedLimit);
        expect(updated.distance, testToken.distance);
        expect(updated.lastReportTime, testToken.lastReportTime);
      });

      test('應該正確複製並更新多個欄位', () {
        final newTime = DateTime(2024, 1, 15, 11, 0, 0);
        final updated = testToken.copyWith(
          currentSpeed: 70.0,
          speedLimit: 60.0,
          distance: 400.0,
          lastReportTime: newTime,
        );

        expect(updated.currentSpeed, 70.0);
        expect(updated.speedLimit, 60.0);
        expect(updated.distance, 400.0);
        expect(updated.lastReportTime, newTime);
      });

      test('應該可以更新 onExecute 回調', () async {
        var newCallbackCalled = false;

        final updated = testToken.copyWith(
          onExecute: (t) async {
            newCallbackCalled = true;
          },
        );

        await updated.execute();

        expect(newCallbackCalled, true);
      });

      test('不傳入參數時應該返回相等的副本', () {
        final copied = testToken.copyWith();

        expect(copied.currentSpeed, testToken.currentSpeed);
        expect(copied.speedLimit, testToken.speedLimit);
        expect(copied.distance, testToken.distance);
        expect(copied.lastReportTime, testToken.lastReportTime);
      });
    });

    group('toString', () {
      test('超速時應該包含 "已超速"', () {
        final token = TTSSpeakingToken(
          currentSpeed: 65.0,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        final str = token.toString();

        expect(str, contains('前方 300 公尺'));
        expect(str, contains('限速 50 公里'));
        expect(str, contains('目前速度 65 公里'));
        expect(str, contains('已超速'));
      });

      test('未超速時應該包含 "未超速，請注意"', () {
        final token = TTSSpeakingToken(
          currentSpeed: 45.0,
          speedLimit: 50.0,
          distance: 500.0,
          lastReportTime: testTime,
        );

        final str = token.toString();

        expect(str, contains('前方 500 公尺'));
        expect(str, contains('限速 50 公里'));
        expect(str, contains('目前速度 45 公里'));
        expect(str, contains('未超速，請注意'));
      });

      test('剛好達到限速時應該顯示 "未超速"', () {
        final token = TTSSpeakingToken(
          currentSpeed: 50.0,
          speedLimit: 50.0,
          distance: 400.0,
          lastReportTime: testTime,
        );

        final str = token.toString();

        expect(str, contains('未超速，請注意'));
      });

      test('數值應該四捨五入到整數', () {
        final token = TTSSpeakingToken(
          currentSpeed: 65.7,
          speedLimit: 50.5,
          distance: 300.3,
          lastReportTime: testTime,
        );

        final str = token.toString();

        expect(str, contains('前方 300 公尺'));
        // toStringAsFixed(0) 會四捨五入，50.5 -> 51
        expect(str, contains('限速 51 公里'));
        expect(str, contains('目前速度 66 公里'));
      });
    });

    group('相等性', () {
      test('相同屬性的 token 應該相等', () {
        final token1 = TTSSpeakingToken(
          currentSpeed: 65.0,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        final token2 = TTSSpeakingToken(
          currentSpeed: 65.0,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        expect(token1 == token2, true);
      });

      test('不同 currentSpeed 的 token 應該不相等', () {
        final token1 = testToken;
        final token2 = testToken.copyWith(currentSpeed: 70.0);

        expect(token1 == token2, false);
      });

      test('不同 speedLimit 的 token 應該不相等', () {
        final token1 = testToken;
        final token2 = testToken.copyWith(speedLimit: 60.0);

        expect(token1 == token2, false);
      });

      test('不同 distance 的 token 應該不相等', () {
        final token1 = testToken;
        final token2 = testToken.copyWith(distance: 400.0);

        expect(token1 == token2, false);
      });

      test('不同 lastReportTime 的 token 應該不相等', () {
        final token1 = testToken;
        final token2 = testToken.copyWith(
          lastReportTime: DateTime(2024, 1, 15, 12, 0, 0),
        );

        expect(token1 == token2, false);
      });

      test('identical 物件應該相等', () {
        expect(testToken == testToken, true);
      });
    });

    group('hashCode', () {
      test('相等的 token 應該有相同的 hashCode', () {
        final token1 = TTSSpeakingToken(
          currentSpeed: 65.0,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        final token2 = TTSSpeakingToken(
          currentSpeed: 65.0,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        expect(token1.hashCode, token2.hashCode);
      });

      test('不相等的 token 通常有不同的 hashCode', () {
        final token1 = testToken;
        final token2 = testToken.copyWith(currentSpeed: 100.0);

        // 注意：hashCode 不同不是必須的，但相等的物件必須有相同的 hashCode
        // 這裡我們只是測試它們確實不同
        expect(token1.hashCode == token2.hashCode, false);
      });
    });

    group('超速判斷邏輯', () {
      test('速度略高於限速時為超速', () {
        final token = TTSSpeakingToken(
          currentSpeed: 50.1,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        expect(token.currentSpeed > token.speedLimit, true);
        expect(token.toString(), contains('已超速'));
      });

      test('速度略低於限速時為未超速', () {
        final token = TTSSpeakingToken(
          currentSpeed: 49.9,
          speedLimit: 50.0,
          distance: 300.0,
          lastReportTime: testTime,
        );

        expect(token.currentSpeed < token.speedLimit, true);
        expect(token.toString(), contains('未超速'));
      });
    });
  });
}
