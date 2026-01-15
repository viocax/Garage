import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/di/service_locator.dart';
import '../../core/models/invoice_data.dart';
import '../../theme/app_theme.dart';
import 'bloc/invoice_scanner_bloc.dart';
import 'bloc/invoice_scanner_event.dart';
import 'bloc/invoice_scanner_state.dart';

/// Invoice QR Code Scanner Page
///
/// Scans Taiwan e-invoice QR codes and extracts invoice data.
class InvoiceScannerPage extends StatelessWidget {
  const InvoiceScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InvoiceScannerBloc(invoiceRepository: getIt.repo.invoice)
            ..add(const InvoiceScannerStarted()),
      child: const _InvoiceScannerView(),
    );
  }
}

class _InvoiceScannerView extends StatefulWidget {
  const _InvoiceScannerView();

  @override
  State<_InvoiceScannerView> createState() => _InvoiceScannerViewState();
}

class _InvoiceScannerViewState extends State<_InvoiceScannerView> {
  late MobileScannerController _scannerController;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    // Prevent multiple detections
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue != null && rawValue.isNotEmpty) {
      _hasScanned = true;
      _scannerController.stop();
      context.read<InvoiceScannerBloc>().add(
        InvoiceScannerQrDetected(rawValue),
      );
    }
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
    });
    _scannerController.start();
    context.read<InvoiceScannerBloc>().add(const InvoiceScannerRetry());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('invoiceScanner.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<InvoiceScannerBloc, InvoiceScannerState>(
        listener: (context, state) {
          if (state is InvoiceScannerSuccess) {
            // Show result bottom sheet
            _showResultSheet(context, state.invoiceData);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Camera preview
              if (state is InvoiceScannerScanning ||
                  state is InvoiceScannerInitial)
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),

              // Processing overlay
              if (state is InvoiceScannerProcessing) _buildProcessingOverlay(),

              // Error overlay
              if (state is InvoiceScannerError) _buildErrorOverlay(state),

              // Scan guide overlay
              if (state is InvoiceScannerScanning ||
                  state is InvoiceScannerInitial)
                _buildScanGuideOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanGuideOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'invoiceScanner.hint'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'invoiceScanner.processing'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(InvoiceScannerError state) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              Text(
                state.message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.refresh),
                label: Text('invoiceScanner.retry'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultSheet(BuildContext context, InvoiceData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (sheetContext) => _InvoiceResultSheet(
        invoiceData: data,
        onConfirm: () {
          Navigator.pop(sheetContext);
          // Return the invoice data to the calling page
          context.pop(data);
        },
        onRetry: () {
          Navigator.pop(sheetContext);
          _resetScanner();
        },
      ),
    );
  }
}

/// Bottom sheet showing scanned invoice result
class _InvoiceResultSheet extends StatelessWidget {
  final InvoiceData invoiceData;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _InvoiceResultSheet({
    required this.invoiceData,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'invoiceScanner.result.title'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Data source badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: invoiceData.isFromApi
                        ? AppTheme.primaryColor.withAlpha(26)
                        : Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    invoiceData.isFromApi
                        ? 'invoiceScanner.result.fromApi'.tr()
                        : 'invoiceScanner.result.fromQr'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: invoiceData.isFromApi
                          ? AppTheme.primaryColor
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Invoice info
            _buildInfoRow(
              'invoiceScanner.result.number'.tr(),
              invoiceData.invoiceNumber,
            ),
            _buildInfoRow(
              'invoiceScanner.result.date'.tr(),
              DateFormat('yyyy/MM/dd').format(invoiceData.date),
            ),
            _buildInfoRow(
              'invoiceScanner.result.amount'.tr(),
              '\$${invoiceData.totalAmount.toStringAsFixed(0)}',
              isHighlighted: true,
            ),

            // Show items if available
            if (invoiceData.hasDetails) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'invoiceScanner.result.items'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...invoiceData.items!.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '\$${item.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: Text('invoiceScanner.result.rescan'.tr()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('invoiceScanner.result.use'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: isHighlighted ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
