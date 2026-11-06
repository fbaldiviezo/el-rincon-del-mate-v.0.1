import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/payment_qr.dart';
import '../services/api_service.dart';

class CatalogProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  PaymentQrConfig? _activeQr;

  bool _isLoading = true;
  bool _isLoadingProducts = false;
  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _errorMessage;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  PaymentQrConfig? get activeQr => _activeQr;

  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get errorMessage => _errorMessage;

  CatalogProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCategories(),
        _loadProducts(),
        fetchActiveQr(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _apiService.getCategories();
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      _products = await _apiService.getProducts(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        activeOnly: true,
      );
      if (_featuredProducts.isEmpty && _products.isNotEmpty) {
        _featuredProducts = _products.take(4).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveQr() async {
    try {
      _activeQr = await _apiService.getActivePaymentQr();
      notifyListeners();
    } catch (_) {}
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _loadProducts();
  }

  void setSelectedCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _loadProducts();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _loadProducts();
  }
}
