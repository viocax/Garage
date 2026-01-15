import 'package:equatable/equatable.dart';

import '../../../core/models/invoice_data.dart';

/// Invoice scanner events
sealed class InvoiceScannerEvent extends Equatable {
  const InvoiceScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Scanner started
class InvoiceScannerStarted extends InvoiceScannerEvent {
  const InvoiceScannerStarted();
}

/// Event: QR code detected from scanner
class InvoiceScannerQrDetected extends InvoiceScannerEvent {
  /// Raw QR code data string
  final String rawData;

  const InvoiceScannerQrDetected(this.rawData);

  @override
  List<Object?> get props => [rawData];
}

/// Event: User wants to retry scanning
class InvoiceScannerRetry extends InvoiceScannerEvent {
  const InvoiceScannerRetry();
}

/// Event: User confirmed the scanned result and wants to proceed
class InvoiceScannerConfirmed extends InvoiceScannerEvent {
  /// The confirmed invoice data
  final InvoiceData invoiceData;

  const InvoiceScannerConfirmed(this.invoiceData);

  @override
  List<Object?> get props => [invoiceData];
}

/// Event: User cancelled the scanner
class InvoiceScannerCancelled extends InvoiceScannerEvent {
  const InvoiceScannerCancelled();
}
