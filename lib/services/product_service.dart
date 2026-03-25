import '../config/api_config.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> getAllProducts({
    String? query,
    String? sort,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    String url = ApiConfig.products;
    final params = <String>[];
    if (query != null && query.isNotEmpty) params.add('q=$query');
    if (sort != null) params.add('sort=$sort');
    if (category != null) params.add('category=$category');
    if (minPrice != null) params.add('minPrice=${minPrice.toInt()}');
    if (maxPrice != null) params.add('maxPrice=${maxPrice.toInt()}');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final data = await ApiService.get(url);
    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  static Future<List<Product>> getFeaturedProducts() async {
    final data = await ApiService.get(ApiConfig.featuredProducts);
    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  static Future<List<Product>> getProductsByCategory(String categoryId) async {
    final data = await ApiService.get(ApiConfig.productsByCategory(categoryId));
    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  static Future<Product> getProductById(String id) async {
    final data = await ApiService.get(ApiConfig.productById(id));
    return Product.fromJson(data);
  }

  static Future<List<Category>> getCategories() async {
    final data = await ApiService.get(ApiConfig.categories);
    return (data as List).map((json) => Category.fromJson(json)).toList();
  }
}
