import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/theme/app_theme.dart';

void main() {
  group('FuelType Enum', () {
    test('應該有正確的 label', () {
      expect(FuelType.octane92.label, '92');
      expect(FuelType.octane95.label, '95');
      expect(FuelType.octane98.label, '98');
      expect(FuelType.diesel.label, '柴油');
    });

    test('應該有 4 種燃油類型', () {
      expect(FuelType.values.length, 4);
    });
  });

  group('FuelData', () {
    group('建構子', () {
      test('應該有正確的預設值', () {
        final data = FuelData();

        expect(data.fuelType, FuelType.octane95);
        expect(data.fuelAmount, 0);
        expect(data.pricePerLiter, 0);
        expect(data.remainingFuel, 90);
      });

      test('應該正確設定自訂值', () {
        final data = FuelData(
          fuelType: FuelType.octane98,
          fuelAmount: 35.5,
          pricePerLiter: 32.5,
          remainingFuel: 75,
        );

        expect(data.fuelType, FuelType.octane98);
        expect(data.fuelAmount, 35.5);
        expect(data.pricePerLiter, 32.5);
        expect(data.remainingFuel, 75);
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新欄位', () {
        final original = FuelData(
          fuelType: FuelType.octane95,
          fuelAmount: 30.0,
          pricePerLiter: 30.0,
          remainingFuel: 80,
        );

        final updated = original.copyWith(
          fuelType: FuelType.diesel,
          pricePerLiter: 28.0,
        );

        expect(updated.fuelType, FuelType.diesel);
        expect(updated.fuelAmount, 30.0); // 未更新
        expect(updated.pricePerLiter, 28.0);
        expect(updated.remainingFuel, 80); // 未更新
      });
    });

    group('calculatedCost', () {
      test('應該正確計算總金額', () {
        final data = FuelData(
          fuelAmount: 40.0,
          pricePerLiter: 32.5,
        );

        expect(data.calculatedCost, 1300.0);
      });

      test('加油量為 0 時總金額應該為 0', () {
        final data = FuelData(
          fuelAmount: 0,
          pricePerLiter: 32.5,
        );

        expect(data.calculatedCost, 0);
      });
    });

    group('formattedSummary', () {
      test('柴油應該顯示 "柴油"', () {
        final data = FuelData(
          fuelType: FuelType.diesel,
          fuelAmount: 45.5,
        );

        expect(data.formattedSummary, '柴油  45.5L');
      });

      test('汽油應該顯示 "無鉛XX"', () {
        final data92 = FuelData(
          fuelType: FuelType.octane92,
          fuelAmount: 30.0,
        );
        final data95 = FuelData(
          fuelType: FuelType.octane95,
          fuelAmount: 35.0,
        );
        final data98 = FuelData(
          fuelType: FuelType.octane98,
          fuelAmount: 40.0,
        );

        expect(data92.formattedSummary, '無鉛92  30.0L');
        expect(data95.formattedSummary, '無鉛95  35.0L');
        expect(data98.formattedSummary, '無鉛98  40.0L');
      });
    });
  });

  group('MaintenanceData', () {
    group('建構子', () {
      test('應該有正確的預設值', () {
        final data = MaintenanceData();

        expect(data.item, '');
        expect(data.amount, 0);
        expect(data.nextMaintenanceKm, null);
        expect(data.note, '');
      });

      test('應該正確設定自訂值', () {
        final data = MaintenanceData(
          item: '機油',
          amount: 1500.0,
          nextMaintenanceKm: 55000,
          note: '使用 Mobil 1',
        );

        expect(data.item, '機油');
        expect(data.amount, 1500.0);
        expect(data.nextMaintenanceKm, 55000);
        expect(data.note, '使用 Mobil 1');
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新欄位', () {
        final original = MaintenanceData(
          item: '機油',
          amount: 1500.0,
          nextMaintenanceKm: 55000,
          note: '原廠',
        );

        final updated = original.copyWith(
          amount: 2000.0,
          note: '進口',
        );

        expect(updated.item, '機油'); // 未更新
        expect(updated.amount, 2000.0);
        expect(updated.nextMaintenanceKm, 55000); // 未更新
        expect(updated.note, '進口');
      });
    });
  });

  group('OtherData', () {
    group('建構子', () {
      test('應該有正確的預設值', () {
        final data = OtherData();

        expect(data.amount, 0);
        expect(data.note, '');
      });

      test('應該正確設定自訂值', () {
        final data = OtherData(
          amount: 500.0,
          note: '停車費',
        );

        expect(data.amount, 500.0);
        expect(data.note, '停車費');
      });
    });

    group('copyWith', () {
      test('應該正確複製並更新欄位', () {
        final original = OtherData(
          amount: 500.0,
          note: '停車費',
        );

        final updated = original.copyWith(amount: 600.0);

        expect(updated.amount, 600.0);
        expect(updated.note, '停車費'); // 未更新
      });
    });
  });

  group('RecordType Sealed Class', () {
    final testDate = DateTime(2024, 1, 15);
    const testOdometer = 50000;

    group('RecordTypeFuel', () {
      test('應該有正確的屬性', () {
        final recordType = RecordTypeFuel(
          data: FuelData(fuelAmount: 40.0, pricePerLiter: 32.0),
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.label, '加油');
        expect(recordType.icon, Icons.local_gas_station);
        expect(recordType.color, AppTheme.recordTypeFuelColor);
        expect(recordType.typeName, 'fuel');
        expect(recordType.recordDate, testDate);
        expect(recordType.odometer, testOdometer);
      });

      test('有效加油量時 validationError 應該為 null', () {
        final recordType = RecordTypeFuel(
          data: FuelData(fuelAmount: 40.0),
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, null);
      });

      test('加油量為 0 時應該有驗證錯誤', () {
        final recordType = RecordTypeFuel(
          data: FuelData(fuelAmount: 0),
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, '請輸入有效的加油量');
      });

      test('加油量為負數時應該有驗證錯誤', () {
        final recordType = RecordTypeFuel(
          data: FuelData(fuelAmount: -10),
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, '請輸入有效的加油量');
      });
    });

    group('RecordTypeMaintenance', () {
      test('應該有正確的屬性', () {
        final recordType = RecordTypeMaintenance(
          data: [MaintenanceData(item: '機油', amount: 1500)],
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.label, '保養');
        expect(recordType.icon, Icons.build);
        expect(recordType.color, AppTheme.recordTypeMaintenanceColor);
        expect(recordType.typeName, 'maintenance');
      });

      test('validEntries 應該過濾掉空項目', () {
        final recordType = RecordTypeMaintenance(
          data: [
            MaintenanceData(item: '機油', amount: 1500),
            MaintenanceData(item: '', amount: 500), // 空項目
            MaintenanceData(item: '   ', amount: 300), // 空白項目
            MaintenanceData(item: '煞車皮', amount: 2000),
          ],
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validEntries.length, 2);
        expect(recordType.validEntries[0].item, '機油');
        expect(recordType.validEntries[1].item, '煞車皮');
      });

      test('totalAmount 應該計算有效項目的總金額', () {
        final recordType = RecordTypeMaintenance(
          data: [
            MaintenanceData(item: '機油', amount: 1500),
            MaintenanceData(item: '', amount: 500), // 無效，不計入
            MaintenanceData(item: '煞車皮', amount: 2000),
          ],
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.totalAmount, 3500);
      });

      test('有有效項目時 validationError 應該為 null', () {
        final recordType = RecordTypeMaintenance(
          data: [MaintenanceData(item: '機油', amount: 1500)],
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, null);
      });

      test('沒有有效項目時應該有驗證錯誤', () {
        final recordType = RecordTypeMaintenance(
          data: [
            MaintenanceData(item: '', amount: 500),
            MaintenanceData(item: '   ', amount: 300),
          ],
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, '請至少輸入一個保養項目');
      });

      test('空資料列表應該有驗證錯誤', () {
        final recordType = RecordTypeMaintenance(
          data: [],
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, '請至少輸入一個保養項目');
      });
    });

    group('RecordTypeOther', () {
      test('應該有正確的屬性', () {
        final recordType = RecordTypeOther(
          data: OtherData(amount: 500, note: '停車費'),
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.label, '其他');
        expect(recordType.icon, Icons.receipt);
        expect(recordType.color, AppTheme.systemGray);
        expect(recordType.typeName, 'other');
      });

      test('validationError 應該永遠為 null', () {
        final recordType = RecordTypeOther(
          data: OtherData(),
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType.validationError, null);
      });
    });

    group('fromTypeName 工廠方法', () {
      test('應該正確建立 fuel 類型', () {
        final recordType = RecordType.fromTypeName(
          'fuel',
          recordDate: testDate,
          odometer: testOdometer,
          fuelData: FuelData(fuelAmount: 40),
        );

        expect(recordType, isA<RecordTypeFuel>());
        expect((recordType as RecordTypeFuel).data.fuelAmount, 40);
      });

      test('應該正確建立 maintenance 類型', () {
        final recordType = RecordType.fromTypeName(
          'maintenance',
          recordDate: testDate,
          odometer: testOdometer,
          maintenanceData: [MaintenanceData(item: '機油')],
        );

        expect(recordType, isA<RecordTypeMaintenance>());
        expect((recordType as RecordTypeMaintenance).data.length, 1);
      });

      test('應該正確建立 other 類型', () {
        final recordType = RecordType.fromTypeName(
          'other',
          recordDate: testDate,
          odometer: testOdometer,
          otherData: OtherData(note: '測試'),
        );

        expect(recordType, isA<RecordTypeOther>());
        expect((recordType as RecordTypeOther).data.note, '測試');
      });

      test('未知類型應該預設為 other', () {
        final recordType = RecordType.fromTypeName(
          'unknown',
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(recordType, isA<RecordTypeOther>());
      });

      test('缺少資料時應該使用預設值', () {
        final fuelType = RecordType.fromTypeName(
          'fuel',
          recordDate: testDate,
          odometer: testOdometer,
        );

        expect(fuelType, isA<RecordTypeFuel>());
        expect((fuelType as RecordTypeFuel).data.fuelAmount, 0);
      });
    });
  });

  group('VehicleRecord', () {
    final testDate = DateTime(2024, 1, 15);

    group('create 工廠方法', () {
      test('應該正確建立加油記錄', () {
        final fuelType = RecordTypeFuel(
          data: FuelData(
            fuelType: FuelType.octane95,
            fuelAmount: 40.0,
            pricePerLiter: 32.0,
          ),
          recordDate: testDate,
          odometer: 50000,
        );

        final record = VehicleRecord.create(
          type: fuelType,
          title: '加油',
          date: testDate,
          cost: 1280.0,
          km: 50000,
          notes: '中油直營站',
        );

        expect(record.recordId, isNotEmpty);
        expect(record.typeName, 'fuel');
        expect(record.title, '加油');
        expect(record.date, testDate);
        expect(record.cost, 1280.0);
        expect(record.km, 50000);
        expect(record.notes, '中油直營站');
        expect(record.fuelData, isNotNull);
        expect(record.fuelData?.fuelAmount, 40.0);
      });

      test('應該正確建立保養記錄', () {
        final maintenanceType = RecordTypeMaintenance(
          data: [
            MaintenanceData(item: '機油', amount: 1500),
            MaintenanceData(item: '機油濾芯', amount: 200),
          ],
          recordDate: testDate,
          odometer: 50000,
        );

        final record = VehicleRecord.create(
          type: maintenanceType,
          title: '定期保養',
          date: testDate,
          cost: 1700.0,
          km: 50000,
        );

        expect(record.typeName, 'maintenance');
        expect(record.maintenanceData, isNotNull);
        expect(record.maintenanceData?.length, 2);
      });

      test('應該正確建立其他記錄', () {
        final otherType = RecordTypeOther(
          data: OtherData(amount: 500, note: '停車費'),
          recordDate: testDate,
          odometer: 50000,
        );

        final record = VehicleRecord.create(
          type: otherType,
          title: '停車費',
          date: testDate,
          cost: 500.0,
          km: 50000,
        );

        expect(record.typeName, 'other');
        expect(record.otherData, isNotNull);
        expect(record.otherData?.note, '停車費');
      });

      test('提供 recordId 時應該使用該 ID', () {
        final otherType = RecordTypeOther(
          data: OtherData(),
          recordDate: testDate,
          odometer: 50000,
        );

        final record = VehicleRecord.create(
          recordId: 'CUSTOM_ID_123',
          type: otherType,
          title: '測試',
          date: testDate,
          cost: 100.0,
          km: 50000,
        );

        expect(record.recordId, 'CUSTOM_ID_123');
      });
    });

    group('type getter', () {
      test('應該正確還原 RecordType', () {
        final fuelData = FuelData(fuelAmount: 40.0, pricePerLiter: 32.0);
        final fuelType = RecordTypeFuel(
          data: fuelData,
          recordDate: testDate,
          odometer: 50000,
        );

        final record = VehicleRecord.create(
          type: fuelType,
          title: '加油',
          date: testDate,
          cost: 1280.0,
          km: 50000,
        );

        final restoredType = record.type;

        expect(restoredType, isA<RecordTypeFuel>());
        expect((restoredType as RecordTypeFuel).data.fuelAmount, 40.0);
      });
    });

    group('formattedCost', () {
      test('應該正確格式化金額', () {
        final record = VehicleRecord()
          ..cost = 1280.0;

        expect(record.formattedCost, '\$1,280');
      });

      test('應該正確處理大金額的千分位分隔', () {
        final record = VehicleRecord()
          ..cost = 12345678.0;

        expect(record.formattedCost, '\$12,345,678');
      });

      test('應該正確處理小金額', () {
        final record = VehicleRecord()
          ..cost = 50.0;

        expect(record.formattedCost, '\$50');
      });
    });

    group('formattedKm', () {
      test('應該正確格式化里程', () {
        final record = VehicleRecord()
          ..km = 50000;

        expect(record.formattedKm, '50,000 km');
      });

      test('應該正確處理大數值的千分位分隔', () {
        final record = VehicleRecord()
          ..km = 1234567;

        expect(record.formattedKm, '1,234,567 km');
      });

      test('應該正確處理小數值', () {
        final record = VehicleRecord()
          ..km = 100;

        expect(record.formattedKm, '100 km');
      });
    });
  });

  group('Pattern Matching with RecordType', () {
    final testDate = DateTime(2024, 1, 15);
    const testOdometer = 50000;

    test('應該可以使用 switch expression 匹配 RecordType', () {
      String getTypeDescription(RecordType type) {
        return switch (type) {
          RecordTypeFuel(:final data) => '加油 ${data.fuelAmount}L',
          RecordTypeMaintenance(:final data) => '保養 ${data.length} 項',
          RecordTypeOther(:final data) => '其他 ${data.note}',
        };
      }

      final fuel = RecordTypeFuel(
        data: FuelData(fuelAmount: 40),
        recordDate: testDate,
        odometer: testOdometer,
      );

      final maintenance = RecordTypeMaintenance(
        data: [MaintenanceData(item: '機油'), MaintenanceData(item: '濾芯')],
        recordDate: testDate,
        odometer: testOdometer,
      );

      final other = RecordTypeOther(
        data: OtherData(note: '停車費'),
        recordDate: testDate,
        odometer: testOdometer,
      );

      expect(getTypeDescription(fuel), '加油 40.0L');
      expect(getTypeDescription(maintenance), '保養 2 項');
      expect(getTypeDescription(other), '其他 停車費');
    });
  });
}
