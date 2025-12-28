import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/speed_unit.dart';

void main() {
  group('SpeedUnit Enum', () {
    test('應該有正確的 displayName', () {
      expect(SpeedUnit.kmh.displayName, 'km/h');
      expect(SpeedUnit.mph.displayName, 'mph');
    });

    test('應該有正確的列舉值數量', () {
      expect(SpeedUnit.values.length, 2);
    });

    test('應該可以透過名稱取得列舉值', () {
      expect(SpeedUnit.values.byName('kmh'), SpeedUnit.kmh);
      expect(SpeedUnit.values.byName('mph'), SpeedUnit.mph);
    });
  });

  group('SpeedUnitExtension', () {
    group('mile getter', () {
      test('應該正確將公里轉換為英里', () {
        const double kmValue = 100.0;
        final mileValue = kmValue.mile;

        // 100 km ≈ 62.1371 miles
        expect(mileValue, closeTo(62.1371, 0.0001));
      });

      test('0 公里應該轉換為 0 英里', () {
        expect(0.0.mile, 0.0);
      });

      test('應該正確處理小數值', () {
        const double kmValue = 1.60934;
        final mileValue = kmValue.mile;

        // 1.60934 km = 1 mile (約)
        expect(mileValue, closeTo(1.0, 0.001));
      });
    });

    group('km getter', () {
      test('應該正確將英里轉換為公里', () {
        const double mileValue = 100.0;
        final kmValue = mileValue.km;

        // 100 miles ≈ 160.934 km
        expect(kmValue, closeTo(160.934, 0.001));
      });

      test('0 英里應該轉換為 0 公里', () {
        expect(0.0.km, 0.0);
      });

      test('應該正確處理小數值', () {
        const double mileValue = 0.621371;
        final kmValue = mileValue.km;

        // 0.621371 miles ≈ 1 km
        expect(kmValue, closeTo(1.0, 0.001));
      });
    });

    group('format 方法', () {
      test('應該正確格式化速度為 km/h', () {
        const double speed = 120.5;
        final formatted = speed.format(SpeedUnit.kmh);

        expect(formatted, '120.50km/h');
      });

      test('應該正確格式化速度為 mph', () {
        const double speed = 75.25;
        final formatted = speed.format(SpeedUnit.mph);

        expect(formatted, '75.25mph');
      });

      test('應該保留兩位小數', () {
        const double speed = 100.0;
        final formatted = speed.format(SpeedUnit.kmh);

        expect(formatted, '100.00km/h');
      });

      test('應該正確處理零值', () {
        const double speed = 0.0;
        final formatted = speed.format(SpeedUnit.kmh);

        expect(formatted, '0.00km/h');
      });
    });

    group('轉換的數學正確性', () {
      test('公里轉英里再轉回公里應該接近原值', () {
        const double originalKm = 100.0;
        final miles = originalKm.mile;
        final backToKm = miles.km;

        expect(backToKm, closeTo(originalKm, 0.01));
      });

      test('英里轉公里再轉回英里應該接近原值', () {
        const double originalMiles = 62.5;
        final km = originalMiles.km;
        final backToMiles = km.mile;

        expect(backToMiles, closeTo(originalMiles, 0.01));
      });
    });
  });
}
