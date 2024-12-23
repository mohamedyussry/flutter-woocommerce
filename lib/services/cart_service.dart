import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart' as models;
import '../models/product.dart';
import 'auth_service.dart';
import 'order_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final _items = ValueNotifier<List<models.CartItem>>([]);
  ValueListenable<List<models.CartItem>> get items => _items;

  final _itemCount = ValueNotifier<int>(0);
  ValueListenable<int> get cartItemCount => _itemCount;

  final _totalAmount = ValueNotifier<double>(0.0);
  ValueListenable<double> get total => _totalAmount;

  void _updateCountAndTotal() {
    _itemCount.value = _items.value.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    _totalAmount.value = _items.value.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.product.price) ?? 0.0) * item.quantity,
    );
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthService().currentUser.value?.id;
    if (userId == null) return;

    final cartJson = prefs.getString('cart_$userId');
    if (cartJson != null) {
      final List<dynamic> cartList = json.decode(cartJson);
      _items.value = cartList.map((json) => models.CartItem.fromJson(json)).toList();
      _updateCountAndTotal();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthService().currentUser.value?.id;
    if (userId == null) return;

    final cartJson = json.encode(_items.value.map((item) => item.toJson()).toList());
    await prefs.setString('cart_$userId', cartJson);
  }

  void addItem(Product product, [int quantity = 1]) {
    final existingIndex = _items.value.indexWhere(
      (item) => item.product.id.toString() == product.id.toString(),
    );

    if (existingIndex != -1) {
      final newItems = List<models.CartItem>.from(_items.value);
      newItems[existingIndex] = models.CartItem(
        product: product,
        quantity: newItems[existingIndex].quantity + quantity,
      );
      _items.value = newItems;
    } else {
      _items.value = [
        ..._items.value,
        models.CartItem(product: product, quantity: quantity),
      ];
    }

    _updateCountAndTotal();
    saveCart();
  }

  void removeItem(String productId) {
    _items.value = _items.value
        .where((item) => item.product.id.toString() != productId)
        .toList();
    _updateCountAndTotal();
    saveCart();
  }

  void updateQuantity(String productId, int quantity) {
    final existingIndex = _items.value.indexWhere(
      (item) => item.product.id.toString() == productId,
    );

    if (existingIndex != -1) {
      final newItems = List<models.CartItem>.from(_items.value);
      if (quantity > 0) {
        newItems[existingIndex] = models.CartItem(
          product: newItems[existingIndex].product,
          quantity: quantity,
        );
        _items.value = newItems;
      } else {
        newItems.removeAt(existingIndex);
        _items.value = newItems;
      }
      _updateCountAndTotal();
      saveCart();
    }
  }

  void clearCart() {
    _items.value = [];
    _updateCountAndTotal();
    saveCart();
  }

  Future<void> checkout(String shippingAddress) async {
    if (_items.value.isEmpty) {
      throw Exception('السلة فارغة');
    }

    final orderService = OrderService();
    await orderService.createOrder(
      items: List.from(_items.value),
      total: _totalAmount.value,
      shippingAddress: shippingAddress,
    );

    clearCart();
  }
}
