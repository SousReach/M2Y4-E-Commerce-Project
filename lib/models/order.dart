class Order {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final ShippingAddress shippingAddress;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.shippingAddress,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String size;
  final String color;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.size = '',
    this.color = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }
}

class ShippingAddress {
  final String street;
  final String city;
  final String country;
  final String phone;

  ShippingAddress({
    this.street = '',
    this.city = '',
    this.country = '',
    this.phone = '',
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'street': street, 'city': city, 'country': country, 'phone': phone};
  }
}
