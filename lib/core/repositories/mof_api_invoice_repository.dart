import '../di/service_locator.dart';
import '../models/invoice_data.dart';
import '../service/services.dart';
import 'invoice_repository.dart';

/// 財政部電子發票 API Repository
///
/// 透過財政部電子發票整合服務平台 API 查詢發票明細。
///
/// ## 使用方式
///
/// ### 開發階段 (Stub 模式)
/// ```dart
/// final repo = MofApiInvoiceRepository(useStub: true);
/// ```
///
/// ### 正式環境 (API 模式)
/// ```dart
/// final repo = MofApiInvoiceRepository(
///   useStub: false,
///   appId: 'YOUR_APP_ID',
///   apiKey: 'YOUR_API_KEY',
/// );
/// ```
///
/// ## TODO
/// 待財政部 API 申請完成後：
/// 1. 將 [appId] 和 [apiKey] 替換為真實值
/// 2. 實作 [_fetchFromMofApi] 方法
/// 3. 將 [useStub] 預設值改為 false
class MofApiInvoiceRepository implements InvoiceRepository {
  /// 財政部 API 基礎 URL
  // ignore: unused_field - will be used when MOF API is implemented
  static const String _baseUrl = 'https://api.einvoice.nat.gov.tw';

  /// API 端點：發票明細查詢
  // ignore: unused_field - will be used when MOF API is implemented
  static const String _invoiceDetailEndpoint = '/PB2CAPIV1/invapp/InvApp';

  // ignore: unused_field - will be used when MOF API is implemented
  final HttpService _httpService;

  /// 是否使用 Stub 模式（開發/測試用）
  final bool useStub;

  /// 應用程式帳號 (財政部核發)
  final String? appId;

  /// 應用程式金鑰 (財政部核發，用於產生簽章)
  final String? apiKey;

  /// 建立 MofApiInvoiceRepository
  ///
  /// [httpService] HTTP 服務，預設使用 DI 容器中的實例
  /// [useStub] 是否使用 Stub 模式，預設為 true
  /// [appId] 財政部核發的 AppID
  /// [apiKey] 財政部核發的 APIKey
  MofApiInvoiceRepository({
    HttpService? httpService,
    this.useStub = true,
    this.appId,
    this.apiKey,
  }) : _httpService = httpService ?? getIt.service.network;

  @override
  Future<InvoiceData?> fetchInvoiceDetails({
    required String invoiceNumber,
    required DateTime date,
    required String randomCode,
  }) async {
    if (useStub) {
      return _stubResponse(invoiceNumber, date, randomCode);
    }

    // 檢查必要參數
    if (appId == null || apiKey == null) {
      throw StateError(
        'MofApiInvoiceRepository: appId and apiKey are required when useStub is false',
      );
    }

    return _fetchFromMofApi(invoiceNumber, date, randomCode);
  }

  /// Stub 回應 - 回傳模擬資料供開發使用
  ///
  /// 模擬成功查詢到加油發票的情境
  Future<InvoiceData?> _stubResponse(
    String invoiceNumber,
    DateTime date,
    String randomCode,
  ) async {
    // 模擬網路延遲
    await Future.delayed(const Duration(milliseconds: 500));

    // 模擬成功回應 - 加油站發票
    return InvoiceData(
      invoiceNumber: invoiceNumber,
      date: date,
      randomCode: randomCode,
      totalAmount: 1250.0,
      salesAmount: 1190.0,
      sellerTaxId: '03077208', // 台灣中油統編
      items: const [
        InvoiceItem(
          name: '95無鉛汽油',
          quantity: 38.46,
          unitPrice: 32.5,
          amount: 1250.0,
        ),
      ],
      source: InvoiceDataSource.mofApi,
    );
  }

  /// 真實 API 呼叫
  ///
  /// ## 實作步驟 (待 API 申請完成後實作)
  /// 1. 產生時間戳記
  /// 2. 組合待簽章字串
  /// 3. 使用 HMAC-SHA1 產生簽章
  /// 4. 組合 API 請求參數
  /// 5. 發送 POST 請求
  /// 6. 解析 JSON 回應
  Future<InvoiceData?> _fetchFromMofApi(
    String invoiceNumber,
    DateTime date,
    String randomCode,
  ) async {
    // TODO: 實作以下步驟：
    //
    // 1. 產生時間戳記
    // final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    //
    // 2. 組合待簽章字串
    // final signData = 'version=0.5&type=QRCode&invNum=$invoiceNumber'
    //     '&action=qryInvDetail&generation=V2&invTerm=${_formatInvTerm(date)}'
    //     '&invDate=${_formatInvDate(date)}&encrypt=$randomCode'
    //     '&sellerID=&UUID=${_generateUuid()}&randomNumber=$randomCode'
    //     '&appID=$appId';
    //
    // 3. 使用 HMAC-SHA1 產生簽章
    // final signature = _generateHmacSha1Signature(signData, apiKey!);
    //
    // 4. 發送 POST 請求
    // final response = await _httpService.post(
    //   '$_baseUrl$_invoiceDetailEndpoint',
    //   data: {
    //     'version': '0.5',
    //     'type': 'QRCode',
    //     'invNum': invoiceNumber,
    //     'action': 'qryInvDetail',
    //     'generation': 'V2',
    //     'invTerm': _formatInvTerm(date),
    //     'invDate': _formatInvDate(date),
    //     'encrypt': randomCode,
    //     'sellerID': '',
    //     'UUID': _generateUuid(),
    //     'randomNumber': randomCode,
    //     'appID': appId,
    //     'signature': signature,
    //   },
    // );
    //
    // 5. 解析 JSON 回應
    // return _parseApiResponse(response.data);

    throw UnimplementedError(
      'MofApiInvoiceRepository: _fetchFromMofApi not implemented. '
      'Please complete MOF API registration first.',
    );
  }

  // === 以下為輔助方法，待 API 實作時使用 ===

  // /// 格式化發票期別 (YYYMM，民國曆)
  // String _formatInvTerm(DateTime date) {
  //   final rocYear = date.year - 1911;
  //   final month = date.month.toString().padLeft(2, '0');
  //   return '$rocYear$month';
  // }

  // /// 格式化發票日期 (YYYY/MM/DD)
  // String _formatInvDate(DateTime date) {
  //   final year = date.year.toString();
  //   final month = date.month.toString().padLeft(2, '0');
  //   final day = date.day.toString().padLeft(2, '0');
  //   return '$year/$month/$day';
  // }

  // /// 產生 UUID
  // String _generateUuid() {
  //   return const Uuid().v4();
  // }

  // /// 產生 HMAC-SHA1 簽章
  // String _generateHmacSha1Signature(String data, String key) {
  //   final keyBytes = utf8.encode(key);
  //   final dataBytes = utf8.encode(data);
  //   final hmac = Hmac(sha1, keyBytes);
  //   final digest = hmac.convert(dataBytes);
  //   return base64.encode(digest.bytes);
  // }

  // /// 解析 API 回應
  // InvoiceData? _parseApiResponse(Map<String, dynamic> response) {
  //   if (response['code'] != '200') {
  //     return null;
  //   }
  //   // ... 解析邏輯
  // }
}
