import '../models/invoice_data.dart';

/// 台灣電子發票 QR Code 解析工具
///
/// 台灣電子發票左側 QR Code 格式說明：
/// - 位置 0-9 (10碼): 發票號碼
/// - 位置 10-16 (7碼): 發票日期 (民國曆 YYYMMDD)
/// - 位置 17-20 (4碼): 隨機碼
/// - 位置 21-28 (8碼): 銷售額 (16進位)
/// - 位置 29-36 (8碼): 總計金額 (16進位)
/// - 位置 37 (1碼): 買方統編記號
/// - 位置 38-45 (8碼): 賣方統編
/// - 位置 46-53 (8碼): 買方統編 (若無則為 "00000000")
/// - 後續為加密驗證碼等資訊
class InvoiceQrParser {
  /// 發票號碼正規表示式 (2個英文字母 + 8個數字)
  static final RegExp _invoiceNumberPattern = RegExp(r'^[A-Z]{2}\d{8}$');

  /// 解析左側 QR Code 字串
  ///
  /// [rawData] 掃描取得的原始字串
  /// Returns [InvoiceData] if successful, null if parsing failed
  static InvoiceData? parseLeftQrCode(String rawData) {
    // 最小長度檢查 (至少要有到總金額的部分)
    if (rawData.length < 37) {
      return null;
    }

    try {
      // 解析發票號碼
      final invoiceNumber = rawData.substring(0, 10).toUpperCase();
      if (!_invoiceNumberPattern.hasMatch(invoiceNumber)) {
        return null;
      }

      // 解析日期 (民國曆 YYYMMDD)
      final dateStr = rawData.substring(10, 17);
      final date = _parseRocDate(dateStr);
      if (date == null) {
        return null;
      }

      // 解析隨機碼
      final randomCode = rawData.substring(17, 21);

      // 解析銷售額 (16進位轉10進位)
      final salesAmountHex = rawData.substring(21, 29);
      final salesAmount = int.tryParse(salesAmountHex, radix: 16)?.toDouble();
      if (salesAmount == null) {
        return null;
      }

      // 解析總金額 (16進位轉10進位)
      final totalAmountHex = rawData.substring(29, 37);
      final totalAmount = int.tryParse(totalAmountHex, radix: 16)?.toDouble();
      if (totalAmount == null) {
        return null;
      }

      // 解析賣方統編 (如果有的話)
      String? sellerTaxId;
      if (rawData.length >= 46) {
        sellerTaxId = rawData.substring(38, 46);
        if (sellerTaxId == '00000000') {
          sellerTaxId = null;
        }
      }

      // 解析買方統編 (如果有的話)
      String? buyerTaxId;
      if (rawData.length >= 54) {
        buyerTaxId = rawData.substring(46, 54);
        if (buyerTaxId == '00000000') {
          buyerTaxId = null;
        }
      }

      return InvoiceData(
        invoiceNumber: invoiceNumber,
        date: date,
        randomCode: randomCode,
        salesAmount: salesAmount,
        totalAmount: totalAmount,
        sellerTaxId: sellerTaxId,
        buyerTaxId: buyerTaxId,
        source: InvoiceDataSource.qrCodeParse,
      );
    } catch (e) {
      return null;
    }
  }

  /// 解析民國曆日期字串
  ///
  /// [dateStr] 格式為 YYYMMDD (民國曆)
  /// Returns DateTime or null if invalid
  static DateTime? _parseRocDate(String dateStr) {
    if (dateStr.length != 7) {
      return null;
    }

    try {
      final rocYear = int.parse(dateStr.substring(0, 3));
      final month = int.parse(dateStr.substring(3, 5));
      final day = int.parse(dateStr.substring(5, 7));

      // 驗證月份和日期範圍
      if (month < 1 || month > 12 || day < 1 || day > 31) {
        return null;
      }

      // 民國曆轉西元曆 (民國年 + 1911 = 西元年)
      final year = rocYear + 1911;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// 驗證發票號碼格式
  ///
  /// [invoiceNumber] 發票號碼
  /// Returns true if valid format
  static bool isValidInvoiceNumber(String invoiceNumber) {
    return _invoiceNumberPattern.hasMatch(invoiceNumber.toUpperCase());
  }

  /// 從 QR Code 資料中提取用於 API 查詢的關鍵資訊
  ///
  /// Returns a record containing (invoiceNumber, date, randomCode)
  /// or null if parsing failed
  static ({String invoiceNumber, DateTime date, String randomCode})?
  extractApiQueryParams(String rawData) {
    final parsed = parseLeftQrCode(rawData);
    if (parsed == null) {
      return null;
    }

    return (
      invoiceNumber: parsed.invoiceNumber,
      date: parsed.date,
      randomCode: parsed.randomCode,
    );
  }
}
