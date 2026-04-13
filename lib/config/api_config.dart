class ApiConfig {
  // For Chrome (web): use localhost
  // For Android emulator: use 10.0.2.2
  // For physical device: use your computer's IP (e.g., 192.168.x.x)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profile = '$baseUrl/auth/me';

  // Products
  static const String products = '$baseUrl/products';
  static const String featuredProducts = '$baseUrl/products/featured';
  static String productsByCategory(String categoryId) =>
      '$baseUrl/products/category/$categoryId';
  static String productById(String id) => '$baseUrl/products/$id';
  static String searchProducts(String query) => '$baseUrl/products?q=$query';

  // Categories
  static const String categories = '$baseUrl/categories';

  // Cart
  static const String cart = '$baseUrl/cart';
  static const String cartAdd = '$baseUrl/cart/add';
  static const String cartUpdate = '$baseUrl/cart/update';
  static String cartRemove(String itemId) => '$baseUrl/cart/remove/$itemId';
  static const String cartClear = '$baseUrl/cart/clear';

  // Orders
  static const String orders = '$baseUrl/orders';
  static String orderById(String id) => '$baseUrl/orders/$id';
  static String orderCancel(String id) => '$baseUrl/orders/$id/cancel';

  // Payment (ABA PayWay KHQR)
  static const String paymentGenerateQr = '$baseUrl/payment/generate-qr';
  static const String paymentCheckStatus = '$baseUrl/payment/check-status';

  // Wishlist
  static const String wishlist = '$baseUrl/wishlists';
  static const String wishlistAdd = '$baseUrl/wishlists/add';
  static String wishlistRemove(String productId) =>
      '$baseUrl/wishlists/remove/$productId';

  // Coupons
  static const String couponValidate = '$baseUrl/coupons/validate';

  // Addresses
  static const String addresses = '$baseUrl/addresses';
}
