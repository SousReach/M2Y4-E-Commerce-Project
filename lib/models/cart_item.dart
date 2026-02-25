import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String size;
  final String color;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.size = '',
    this.color = '',
  });

  double get totalPrice => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? '',
      color: json['color'] ?? '',
    );
  }
}
