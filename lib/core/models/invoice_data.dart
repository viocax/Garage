import 'package:equatable/equatable.dart';

/// 發票明細項目
class InvoiceItem extends Equatable {
  /// 品名
  final String name;

  /// 數量
  final double quantity;

  /// 單價
  final double unitPrice;

  /// 金額
  final double amount;

  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  @override
  List<Object?> get props => [name, quantity, unitPrice, amount];

  @override
  String toString() =>
      'InvoiceItem(name: $name, quantity: $quantity, unitPrice: $unitPrice, amount: $amount)';
}

/// 資料來源
enum InvoiceDataSource {
  /// 財政部 API (Option B)
  mofApi,

  /// QR Code 解析 (Option A)
  qrCodeParse,
}

/// 發票資料模型
class InvoiceData extends Equatable {
  /// 發票號碼 (e.g., "AB12345678")
  final String invoiceNumber;

  /// 交易日期
  final DateTime date;

  /// 隨機碼 (4碼)
  final String randomCode;

  /// 總金額
  final double totalAmount;

  /// 銷售額（稅前）
  final double? salesAmount;

  /// 賣方統編
  final String? sellerTaxId;

  /// 買方統編
  final String? buyerTaxId;

  /// 明細 (Option B 才有)
  final List<InvoiceItem>? items;

  /// 資料來源
  final InvoiceDataSource source;

  const InvoiceData({
    required this.invoiceNumber,
    required this.date,
    required this.randomCode,
    required this.totalAmount,
    required this.source,
    this.salesAmount,
    this.sellerTaxId,
    this.buyerTaxId,
    this.items,
  });

  /// 是否有完整明細
  bool get hasDetails => items != null && items!.isNotEmpty;

  /// 是否來自 API
  bool get isFromApi => source == InvoiceDataSource.mofApi;

  @override
  List<Object?> get props => [
    invoiceNumber,
    date,
    randomCode,
    totalAmount,
    salesAmount,
    sellerTaxId,
    buyerTaxId,
    items,
    source,
  ];

  @override
  String toString() =>
      'InvoiceData(invoiceNumber: $invoiceNumber, date: $date, totalAmount: $totalAmount, source: $source)';

  InvoiceData copyWith({
    String? invoiceNumber,
    DateTime? date,
    String? randomCode,
    double? totalAmount,
    double? salesAmount,
    String? sellerTaxId,
    String? buyerTaxId,
    List<InvoiceItem>? items,
    InvoiceDataSource? source,
  }) {
    return InvoiceData(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      randomCode: randomCode ?? this.randomCode,
      totalAmount: totalAmount ?? this.totalAmount,
      salesAmount: salesAmount ?? this.salesAmount,
      sellerTaxId: sellerTaxId ?? this.sellerTaxId,
      buyerTaxId: buyerTaxId ?? this.buyerTaxId,
      items: items ?? this.items,
      source: source ?? this.source,
    );
  }
}
