import '../models/invoice_data.dart';

/// 發票查詢 Repository 介面
///
/// 定義發票資料查詢的抽象介面，支援不同的實作方式：
/// - [MofApiInvoiceRepository]: 透過財政部 API 查詢完整明細
/// - 未來可擴充其他資料來源
abstract class InvoiceRepository {
  /// 透過發票資訊查詢完整明細
  ///
  /// [invoiceNumber] 發票號碼 (e.g., "AB12345678")
  /// [date] 發票日期
  /// [randomCode] 隨機碼 (4碼)
  ///
  /// Returns [InvoiceData] if successful, null if failed or not found
  Future<InvoiceData?> fetchInvoiceDetails({
    required String invoiceNumber,
    required DateTime date,
    required String randomCode,
  });
}
