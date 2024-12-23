import 'package:flutter/foundation.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  final Map<int, Product> _items = {};

  Map<int, Product> get items => {..._items};

  int get itemCount => _items.length;

  bool isInWishlist(int productId) {
    return _items.containsKey(productId);
  }

  void addToWishlist(Product product) {
    if (!_items.containsKey(product.id)) {
      _items[product.id] = product;
      notifyListeners();
    }
  }

  void removeFromWishlist(int productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
