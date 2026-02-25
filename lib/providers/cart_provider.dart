import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.get(ApiConfig.cart, auth: true);
      _items = (data as List).map((json) => CartItem.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(
    String productId, {
    int quantity = 1,
    String size = '',
    String color = '',
  }) async {
    try {
      final data = await ApiService.post(ApiConfig.cartAdd, {
        'productId': productId,
        'quantity': quantity,
        'size': size,
        'color': color,
      }, auth: true);
      _items = (data as List).map((json) => CartItem.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(
    String productId,
    int quantity, {
    String size = '',
    String color = '',
  }) async {
    try {
      final data = await ApiService.put(ApiConfig.cartUpdate, {
        'productId': productId,
        'quantity': quantity,
        'size': size,
        'color': color,
      }, auth: true);
      _items = (data as List).map((json) => CartItem.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final data = await ApiService.delete(
        ApiConfig.cartRemove(itemId),
        auth: true,
      );
      _items = (data as List).map((json) => CartItem.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiService.delete(ApiConfig.cartClear, auth: true);
      _items = [];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
