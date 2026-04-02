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


  String? _activeSort;
  String? _activeCategoryId;
  String? _activeQuery;
  double? _minPrice;
  double? _maxPrice;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get activeSort => _activeSort;
  String? get activeCategoryId => _activeCategoryId;
  String? get activeQuery => _activeQuery;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  bool get hasActiveFilters =>
      _activeCategoryId != null ||
      _minPrice != null ||
      _maxPrice != null;

  int get activeFilterCount {
    int count = 0;
    if (_activeCategoryId != null) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    return count;
  }

  Future<void> loadCategories() async {
    try {
      _categories = await ProductService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadProducts({String? query, String? sort}) async {
    // Use passed values or fall back to stored state
    if (query != null) _activeQuery = query.isEmpty ? null : query;
    if (sort != null) _activeSort = sort;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ProductService.getAllProducts(
        query: _activeQuery,
        sort: _activeSort,
        category: _activeCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSort(String? sort) {
    _activeSort = sort;
    loadProducts();
  }

  void setCategory(String? categoryId) {
    _activeCategoryId = categoryId;
    loadProducts();
  }

  void setPriceRange({double? min, double? max}) {
    _minPrice = min;
    _maxPrice = max;
    loadProducts();
  }

  void clearFilters() {
    _activeSort = null;
    _activeCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _activeQuery = null;
    loadProducts();
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
