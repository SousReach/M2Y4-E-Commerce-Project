import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

class WishlistService {
  static Future<List<Product>> getWishlist() async {
    final data = await ApiService.get(ApiConfig.wishlist, auth: true);
    final products = (data['products'] as List?) ?? [];
    return products
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Product>> addToWishlist(String productId) async {
    final data = await ApiService.post(
      ApiConfig.wishlistAdd,
      {'productId': productId},
      auth: true,
    );
    final products = (data['products'] as List?) ?? [];
    return products
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Product>> removeFromWishlist(String productId) async {
    final data = await ApiService.delete(
      ApiConfig.wishlistRemove(productId),
      auth: true,
    );
    final products = (data['products'] as List?) ?? [];
    return products
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
