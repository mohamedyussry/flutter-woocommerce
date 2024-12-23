import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/woocommerce_service.dart';

class ProductsProvider with ChangeNotifier {
  final WooCommerceService _wooCommerceService;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _perPage = 10;
  int? _currentCategoryId;

  ProductsProvider() : _wooCommerceService = WooCommerceService();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int? get currentCategoryId => _currentCategoryId;

  void setError(String message) {
    _error = message;
    debugPrint('❌ Error message set: $_error');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchProducts({bool refresh = false, int? categoryId}) async {
    try {
      if (refresh || categoryId != _currentCategoryId) {
        _currentPage = 1;
        _hasMore = true;
        _products = [];
        _currentCategoryId = categoryId;
      }

      if (!_hasMore || _isLoading) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🔄 Fetching products - Page: $_currentPage, Category: $_currentCategoryId');

      final newProducts = await _wooCommerceService.getProducts(
        page: _currentPage,
        perPage: _perPage,
        categoryId: _currentCategoryId,
      );

      if (newProducts.isEmpty) {
        _hasMore = false;
        debugPrint('📦 No more products to load');
      } else {
        _products.addAll(newProducts);
        _currentPage++;
        debugPrint('✅ Loaded ${newProducts.length} products. Total: ${_products.length}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('❌ Error fetching products: $e');
      debugPrint('📋 Stack trace: $stack');
      _isLoading = false;
      setError('فشل في تحميل المنتجات. الرجاء المحاولة مرة أخرى.');
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts(refresh: true, categoryId: _currentCategoryId);
  }

  void loadMore() {
    if (!_isLoading && _hasMore) {
      fetchProducts(categoryId: _currentCategoryId);
    }
  }

  void resetState() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _error = null;
    _currentCategoryId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _wooCommerceService.dispose();
    super.dispose();
  }
}
