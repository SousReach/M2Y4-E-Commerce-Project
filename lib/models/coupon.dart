class CouponResult {
  final String code;
  final double discount;
  final int discountPercent;

  CouponResult({
    required this.code,
    required this.discount,
    required this.discountPercent,
  });

  factory CouponResult.fromJson(Map<String, dynamic> json) {
    return CouponResult(
      code: json['code'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      discountPercent: json['discountPercent'] ?? 0,
    );
  }
}
