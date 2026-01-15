import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/invoice_data.dart';
import 'package:garage/core/utils/invoice_qr_parser.dart';

void main() {
  group('InvoiceQrParser', () {
    group('parseLeftQrCode', () {
      test('should parse valid QR code with full data', () {
        // QR code format (minimum 37 chars for basic info, 54+ for tax IDs):
        // 發票號碼(10) + 日期(7,民國曆) + 隨機碼(4) + 銷售額(8,hex) + 總金額(8,hex) + 買方標記(1) + 賣方統編(8) + 買方統編(8)
        // 0x000004E2 = 1250
        const rawData =
            'AB123456781140115ABCD000004E2000004E20030772080000000012345678';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNotNull);
        expect(result!.invoiceNumber, equals('AB12345678'));
        expect(result.date, equals(DateTime(2025, 1, 15))); // 民國114年1月15日
        expect(result.randomCode, equals('ABCD'));
        expect(result.salesAmount, equals(1250.0));
        expect(result.totalAmount, equals(1250.0));
        expect(result.sellerTaxId, equals('03077208'));
        expect(result.buyerTaxId, isNull); // 00000000 should be null
        expect(result.source, equals(InvoiceDataSource.qrCodeParse));
      });

      test('should parse QR code with minimum required length (37 chars)', () {
        // Only up to total amount (37 chars) - no tax IDs
        // Format: 發票號碼(10) + 日期(7) + 隨機碼(4) + 銷售額(8) + 總金額(8) = 37 chars
        // 0x000001F4 = 500
        // ZZ98765432 (10) + 1131010 (7, 民國113年10月10日) + WXYZ (4) + 000001F4 (8) + 000001F4 (8) = 37
        const rawData = 'ZZ987654321131010WXYZ000001F4000001F4';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNotNull);
        expect(result!.invoiceNumber, equals('ZZ98765432'));
        expect(result.date, equals(DateTime(2024, 10, 10))); // 民國113年10月10日
        expect(result.randomCode, equals('WXYZ'));
        expect(result.salesAmount, equals(500.0)); // 0x1F4 = 500
        expect(result.totalAmount, equals(500.0));
        expect(result.sellerTaxId, isNull);
        expect(result.buyerTaxId, isNull);
      });

      test('should return null for too short data', () {
        const rawData = 'AB1234567811401151234';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNull);
      });

      test('should return null for invalid invoice number format', () {
        // Invoice number should be 2 letters + 8 digits
        const rawData = '1234567890114011512340000000100000001';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNull);
      });

      test('should return null for invalid date', () {
        // Month 13 is invalid
        const rawData = 'AB12345678114130112340000000100000001';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNull);
      });

      test('should handle lowercase invoice number', () {
        // 0x000004E2 = 1250
        const rawData = 'ab123456781140115ABCD000004E2000004E20';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNotNull);
        expect(result!.invoiceNumber, equals('AB12345678'));
      });

      test('should correctly parse hex amounts', () {
        // 0x00002710 = 10000
        const rawData = 'AB12345678114010112340000271000002710';

        final result = InvoiceQrParser.parseLeftQrCode(rawData);

        expect(result, isNotNull);
        expect(result!.salesAmount, equals(10000.0));
        expect(result.totalAmount, equals(10000.0));
      });
    });

    group('isValidInvoiceNumber', () {
      test('should return true for valid format', () {
        expect(InvoiceQrParser.isValidInvoiceNumber('AB12345678'), isTrue);
        expect(InvoiceQrParser.isValidInvoiceNumber('ZZ00000000'), isTrue);
        expect(InvoiceQrParser.isValidInvoiceNumber('aa12345678'), isTrue);
      });

      test('should return false for invalid format', () {
        expect(InvoiceQrParser.isValidInvoiceNumber('A123456789'), isFalse);
        expect(InvoiceQrParser.isValidInvoiceNumber('ABC1234567'), isFalse);
        expect(InvoiceQrParser.isValidInvoiceNumber('AB1234567'), isFalse);
        expect(InvoiceQrParser.isValidInvoiceNumber('12345678AB'), isFalse);
        expect(InvoiceQrParser.isValidInvoiceNumber(''), isFalse);
      });
    });

    group('extractApiQueryParams', () {
      test('should extract parameters from valid QR code', () {
        const rawData = 'AB12345678114011512340000271000002710';

        final result = InvoiceQrParser.extractApiQueryParams(rawData);

        expect(result, isNotNull);
        expect(result!.invoiceNumber, equals('AB12345678'));
        expect(result.date, equals(DateTime(2025, 1, 15)));
        expect(result.randomCode, equals('1234'));
      });

      test('should return null for invalid QR code', () {
        const rawData = 'invalid';

        final result = InvoiceQrParser.extractApiQueryParams(rawData);

        expect(result, isNull);
      });
    });
  });
}
