import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/invoice_data.dart';
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/utils/invoice_qr_parser.dart';
import 'invoice_scanner_event.dart';
import 'invoice_scanner_state.dart';

/// BLoC for invoice QR code scanner
///
/// Handles the scanning flow:
/// 1. Start scanning
/// 2. Detect QR code
/// 3. Try Option B (MOF API) first
/// 4. Fallback to Option A (QR parsing) if API fails
/// 5. Return parsed invoice data
class InvoiceScannerBloc
    extends Bloc<InvoiceScannerEvent, InvoiceScannerState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceScannerBloc({required InvoiceRepository invoiceRepository})
    : _invoiceRepository = invoiceRepository,
      super(const InvoiceScannerInitial()) {
    on<InvoiceScannerStarted>(_onStarted);
    on<InvoiceScannerQrDetected>(_onQrDetected);
    on<InvoiceScannerRetry>(_onRetry);
    on<InvoiceScannerConfirmed>(_onConfirmed);
    on<InvoiceScannerCancelled>(_onCancelled);
  }

  /// Handle scanner started event
  void _onStarted(
    InvoiceScannerStarted event,
    Emitter<InvoiceScannerState> emit,
  ) {
    emit(const InvoiceScannerScanning());
  }

  /// Handle QR code detected event
  ///
  /// Flow:
  /// 1. Parse QR code to extract basic info
  /// 2. Try API call (Option B)
  /// 3. If API fails, use parsed data (Option A)
  Future<void> _onQrDetected(
    InvoiceScannerQrDetected event,
    Emitter<InvoiceScannerState> emit,
  ) async {
    emit(InvoiceScannerProcessing(event.rawData));

    // Step 1: Parse QR code to get basic info (Option A)
    final parsedData = InvoiceQrParser.parseLeftQrCode(event.rawData);

    if (parsedData == null) {
      emit(
        InvoiceScannerError(
          message: 'QR Code 格式無效，請確認是否為台灣電子發票',
          rawData: event.rawData,
        ),
      );
      return;
    }

    // Step 2: Try API call (Option B)
    InvoiceData? apiData;
    try {
      apiData = await _invoiceRepository.fetchInvoiceDetails(
        invoiceNumber: parsedData.invoiceNumber,
        date: parsedData.date,
        randomCode: parsedData.randomCode,
      );
    } catch (e) {
      // API failed, will fallback to Option A
      apiData = null;
    }

    // Step 3: Use API data if available, otherwise use parsed data
    final finalData = apiData ?? parsedData;

    emit(InvoiceScannerSuccess(finalData));
  }

  /// Handle retry event - go back to scanning state
  void _onRetry(InvoiceScannerRetry event, Emitter<InvoiceScannerState> emit) {
    emit(const InvoiceScannerScanning());
  }

  /// Handle confirmed event - user accepted the scanned result
  void _onConfirmed(
    InvoiceScannerConfirmed event,
    Emitter<InvoiceScannerState> emit,
  ) {
    // The page will handle navigation with the confirmed data
    // No state change needed here
  }

  /// Handle cancelled event - user wants to exit
  void _onCancelled(
    InvoiceScannerCancelled event,
    Emitter<InvoiceScannerState> emit,
  ) {
    // The page will handle navigation
    // Reset to initial state
    emit(const InvoiceScannerInitial());
  }
}
