import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _products.length;

  bool contains(String productId) =>
      _products.any((p) => p.id == productId);

  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await WishlistService.getWishlist();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String productId) async {
    if (contains(productId)) {
      await remove(productId);
    } else {
      await add(productId);
    }
  }

  Future<void> add(String productId) async {
    try {
      _products = await WishlistService.addToWishlist(productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String productId) async {
    try {
      _products = await WishlistService.removeFromWishlist(productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
