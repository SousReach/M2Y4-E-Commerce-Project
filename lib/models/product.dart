class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.images = const [],
    this.categoryId = '',
    this.categoryName = '',
    this.sizes = const [],
    this.colors = const [],
    this.stock = 0,
    this.isFeatured = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['category'] is Map
          ? json['category']['_id'] ?? ''
          : json['category'] ?? '',
      categoryName: json['category'] is Map
          ? json['category']['name'] ?? ''
          : '',
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      stock: json['stock'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}
