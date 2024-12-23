import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final ProductVariation? variation;
  final int quantity;
  final Map<String, String> selectedAttributes;

  CartItem({
    required this.product,
    this.variation,
    required this.quantity,
    required this.selectedAttributes,
  });

  double get price {
    if (variation != null) {
      return double.tryParse(variation!.price) ?? 0.0;
    }
    if (product.onSale) {
      return double.tryParse(product.salePrice) ?? 0.0;
    }
    return double.tryParse(product.regularPrice) ?? 0.0;
  }

  double get total => price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.total;
    });
    return total;
  }

  bool isInCart(int productId) {
    return _items.values.any((item) => item.product.id == productId);
  }

  void addToCart(Product product) {
    addItem(
      product: product,
      variation: null,
      quantity: 1,
      selectedAttributes: {},
    );
  }

  void addItem({
    required Product product,
    ProductVariation? variation,
    required int quantity,
    required Map<String, String> selectedAttributes,
  }) {
    final key = _generateCartItemKey(product.id, variation?.id, selectedAttributes);

    if (_items.containsKey(key)) {
      // Update existing item
      _items.update(
        key,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          variation: existingCartItem.variation,
          quantity: existingCartItem.quantity + quantity,
          selectedAttributes: existingCartItem.selectedAttributes,
        ),
      );
    } else {
      // Add new item
      _items.putIfAbsent(
        key,
        () => CartItem(
          product: product,
          variation: variation,
          quantity: quantity,
          selectedAttributes: selectedAttributes,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String cartItemKey) {
    _items.remove(cartItemKey);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  String _generateCartItemKey(
    int productId,
    int? variationId,
    Map<String, String> selectedAttributes,
  ) {
    final attributesKey = selectedAttributes.entries
        .map((e) => '${e.key}:${e.value}')
        .join('_');
    return '$productId${variationId != null ? "_$variationId" : ""}${attributesKey.isNotEmpty ? "_$attributesKey" : ""}';
  }
}
