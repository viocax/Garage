import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/invoice_data.dart';
import 'package:garage/core/repositories/invoice_repository.dart';
import 'package:garage/screen/invoice_scanner/bloc/invoice_scanner_bloc.dart';
import 'package:garage/screen/invoice_scanner/bloc/invoice_scanner_event.dart';
import 'package:garage/screen/invoice_scanner/bloc/invoice_scanner_state.dart';
import 'package:mocktail/mocktail.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  late MockInvoiceRepository mockRepository;

  setUp(() {
    mockRepository = MockInvoiceRepository();
  });

  group('InvoiceScannerBloc', () {
    test('initial state is InvoiceScannerInitial', () {
      final bloc = InvoiceScannerBloc(invoiceRepository: mockRepository);
      expect(bloc.state, isA<InvoiceScannerInitial>());
      bloc.close();
    });

    blocTest<InvoiceScannerBloc, InvoiceScannerState>(
      'emits [InvoiceScannerScanning] when InvoiceScannerStarted is added',
      build: () => InvoiceScannerBloc(invoiceRepository: mockRepository),
      act: (bloc) => bloc.add(const InvoiceScannerStarted()),
      expect: () => [isA<InvoiceScannerScanning>()],
    );

    group('InvoiceScannerQrDetected', () {
      // Valid QR format: 發票號碼(10) + 日期(7) + 隨機碼(4) + 銷售額(8,hex) + 總金額(8,hex) = 37 chars
      // 0x000004E2 = 1250
      const validQrData = 'AB123456781140115ABCD000004E2000004E2';
      final expectedDate = DateTime(2025, 1, 15);

      blocTest<InvoiceScannerBloc, InvoiceScannerState>(
        'emits [Processing, Success] with API data when API succeeds',
        build: () {
          when(
            () => mockRepository.fetchInvoiceDetails(
              invoiceNumber: 'AB12345678',
              date: expectedDate,
              randomCode: 'ABCD',
            ),
          ).thenAnswer(
            (_) async => InvoiceData(
              invoiceNumber: 'AB12345678',
              date: expectedDate,
              randomCode: 'ABCD',
              totalAmount: 1250.0,
              salesAmount: 1190.0,
              items: const [
                InvoiceItem(
                  name: '95無鉛汽油',
                  quantity: 38.46,
                  unitPrice: 32.5,
                  amount: 1250.0,
                ),
              ],
              source: InvoiceDataSource.mofApi,
            ),
          );
          return InvoiceScannerBloc(invoiceRepository: mockRepository);
        },
        act: (bloc) => bloc.add(const InvoiceScannerQrDetected(validQrData)),
        expect: () => [
          isA<InvoiceScannerProcessing>(),
          isA<InvoiceScannerSuccess>().having(
            (s) => s.invoiceData.isFromApi,
            'isFromApi',
            true,
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.fetchInvoiceDetails(
              invoiceNumber: 'AB12345678',
              date: expectedDate,
              randomCode: 'ABCD',
            ),
          ).called(1);
        },
      );

      blocTest<InvoiceScannerBloc, InvoiceScannerState>(
        'emits [Processing, Success] with QR data when API fails (fallback)',
        build: () {
          when(
            () => mockRepository.fetchInvoiceDetails(
              invoiceNumber: any(named: 'invoiceNumber'),
              date: any(named: 'date'),
              randomCode: any(named: 'randomCode'),
            ),
          ).thenThrow(Exception('API Error'));
          return InvoiceScannerBloc(invoiceRepository: mockRepository);
        },
        act: (bloc) => bloc.add(const InvoiceScannerQrDetected(validQrData)),
        expect: () => [
          isA<InvoiceScannerProcessing>(),
          isA<InvoiceScannerSuccess>().having(
            (s) => s.invoiceData.isFromApi,
            'isFromApi',
            false,
          ),
        ],
      );

      blocTest<InvoiceScannerBloc, InvoiceScannerState>(
        'emits [Processing, Success] with QR data when API returns null',
        build: () {
          when(
            () => mockRepository.fetchInvoiceDetails(
              invoiceNumber: any(named: 'invoiceNumber'),
              date: any(named: 'date'),
              randomCode: any(named: 'randomCode'),
            ),
          ).thenAnswer((_) async => null);
          return InvoiceScannerBloc(invoiceRepository: mockRepository);
        },
        act: (bloc) => bloc.add(const InvoiceScannerQrDetected(validQrData)),
        expect: () => [
          isA<InvoiceScannerProcessing>(),
          isA<InvoiceScannerSuccess>().having(
            (s) => s.invoiceData.source,
            'source',
            InvoiceDataSource.qrCodeParse,
          ),
        ],
      );

      blocTest<InvoiceScannerBloc, InvoiceScannerState>(
        'emits [Processing, Error] when QR code is invalid',
        build: () => InvoiceScannerBloc(invoiceRepository: mockRepository),
        act: (bloc) =>
            bloc.add(const InvoiceScannerQrDetected('invalid_qr_code')),
        expect: () => [
          isA<InvoiceScannerProcessing>(),
          isA<InvoiceScannerError>().having(
            (s) => s.rawData,
            'rawData',
            'invalid_qr_code',
          ),
        ],
      );
    });

    blocTest<InvoiceScannerBloc, InvoiceScannerState>(
      'emits [InvoiceScannerScanning] when InvoiceScannerRetry is added',
      build: () => InvoiceScannerBloc(invoiceRepository: mockRepository),
      act: (bloc) => bloc.add(const InvoiceScannerRetry()),
      expect: () => [isA<InvoiceScannerScanning>()],
    );

    blocTest<InvoiceScannerBloc, InvoiceScannerState>(
      'emits [InvoiceScannerInitial] when InvoiceScannerCancelled is added',
      build: () => InvoiceScannerBloc(invoiceRepository: mockRepository),
      act: (bloc) => bloc.add(const InvoiceScannerCancelled()),
      expect: () => [isA<InvoiceScannerInitial>()],
    );
  });
}
