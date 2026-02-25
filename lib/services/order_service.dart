import '../config/api_config.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<Order> placeOrder({
    required List<OrderItem> items,
    required double totalPrice,
    required ShippingAddress shippingAddress,
  }) async {
    final data = await ApiService.post(ApiConfig.orders, {
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'shippingAddress': shippingAddress.toJson(),
    }, auth: true);
    return Order.fromJson(data);
  }

  static Future<List<Order>> getOrders() async {
    final data = await ApiService.get(ApiConfig.orders, auth: true);
    return (data as List).map((json) => Order.fromJson(json)).toList();
  }
}
