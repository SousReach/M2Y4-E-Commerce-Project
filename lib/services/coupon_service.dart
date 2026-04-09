import '../config/api_config.dart';
import '../models/coupon.dart';
import 'api_service.dart';

class CouponService {
  static Future<CouponResult> validateCoupon({
    required String code,
    required double cartTotal,
  }) async {
    final data = await ApiService.post(
      ApiConfig.couponValidate,
      {'code': code, 'cartTotal': cartTotal},
      auth: true,
    );
    return CouponResult.fromJson(data);
  }
}
