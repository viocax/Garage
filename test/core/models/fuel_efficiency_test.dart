import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/vehicle_record.dart';

void main() {
  group('VehicleRecord - Fuel Efficiency', () {
    test('calculateFuelEfficiency returns correct km/L', () {
      final record = VehicleRecord()
        ..typeName = 'fuel'
        ..km = 1000
        ..fuelData = FuelData(fuelAmount: 50);

      // (1000 - 500) / 50 = 10.0
      final efficiency = record.calculateFuelEfficiency(500);
      expect(efficiency, 10.0);
    });

    test('calculateFuelEfficiency returns 0.0 when fuelAmount is 0', () {
      final record = VehicleRecord()
        ..typeName = 'fuel'
        ..km = 1000
        ..fuelData = FuelData(fuelAmount: 0);

      final efficiency = record.calculateFuelEfficiency(500);
      expect(efficiency, 0.0);
    });

    test('calculateFuelEfficiency returns 0.0 when type is not fuel', () {
      final record = VehicleRecord()
        ..typeName = 'maintenance'
        ..km = 1000;

      final efficiency = record.calculateFuelEfficiency(500);
      expect(efficiency, 0.0);
    });

    test(
      'calculateFuelEfficiency returns 0.0 when km difference is not positive',
      () {
        final record = VehicleRecord()
          ..typeName = 'fuel'
          ..km = 1000
          ..fuelData = FuelData(fuelAmount: 50);

        expect(record.calculateFuelEfficiency(1000), 0.0);
        expect(record.calculateFuelEfficiency(1100), 0.0);
      },
    );
  });
}
