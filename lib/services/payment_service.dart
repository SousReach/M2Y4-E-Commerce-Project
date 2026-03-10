import '../config/api_config.dart';
import 'api_service.dart';

class PaymentService {
  /// Calls backend to generate an ABA KHQR QR code for this order.
  /// Returns `{'qr_string': '...', 'tran_id': '...'}` on success.
  static Future<Map<String, dynamic>> generateQr({
    required String orderId,
    required double amount,
    String firstname = 'Customer',
    String lastname = 'User',
    String email = 'test@example.com',
    String phone = '093630466',
  }) async {
    final data = await ApiService.post(ApiConfig.paymentGenerateQr, {
      'orderId': orderId,
      'amount': amount,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
    });
    return Map<String, dynamic>.from(data);
  }

  /// Checks transaction payment status with ABA.
  /// Backend auto-marks the order as 'paid' if ABA confirms.
  static Future<Map<String, dynamic>> checkStatus(String tranId) async {
    final data = await ApiService.post(ApiConfig.paymentCheckStatus, {
      'tran_id': tranId,
    });
    return Map<String, dynamic>.from(data);
  }
}
