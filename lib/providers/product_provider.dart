import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _categories = await ProductService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadProducts({String? query, String? sort}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ProductService.getAllProducts(query: query, sort: sort);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await ProductService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ProductService.getProductsByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await ProductService.getProductById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
