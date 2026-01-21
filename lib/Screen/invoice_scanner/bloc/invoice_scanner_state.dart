import 'package:equatable/equatable.dart';

import '../../../core/models/invoice_data.dart';

/// Invoice scanner states
sealed class InvoiceScannerState extends Equatable {
  const InvoiceScannerState();

  @override
  List<Object?> get props => [];
}

/// State: Initial state, scanner not yet started
class InvoiceScannerInitial extends InvoiceScannerState {
  const InvoiceScannerInitial();
}

/// State: Actively scanning for QR codes
class InvoiceScannerScanning extends InvoiceScannerState {
  const InvoiceScannerScanning();
}

/// State: Processing detected QR code (calling API or parsing)
class InvoiceScannerProcessing extends InvoiceScannerState {
  /// The raw QR code data being processed
  final String rawData;

  const InvoiceScannerProcessing(this.rawData);

  @override
  List<Object?> get props => [rawData];
}

/// State: Successfully retrieved invoice data
class InvoiceScannerSuccess extends InvoiceScannerState {
  /// The parsed invoice data
  final InvoiceData invoiceData;

  /// Whether the data came from API (true) or QR parsing fallback (false)
  bool get isFromApi => invoiceData.isFromApi;

  const InvoiceScannerSuccess(this.invoiceData);

  @override
  List<Object?> get props => [invoiceData];
}

/// State: Error occurred during scanning or processing
class InvoiceScannerError extends InvoiceScannerState {
  /// Error message
  final String message;

  /// The raw QR code data that caused the error (if available)
  final String? rawData;

  const InvoiceScannerError({required this.message, this.rawData});

  @override
  List<Object?> get props => [message, rawData];
}
