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

  Future<void> addItem(Product product, int quantity, {ProductVariation? variation}) async {
    final items = _items.value;
    final String itemId = variation != null ? '${product.id}-${variation.id}' : product.id.toString();
    
    final existingItemIndex = items.indexWhere((item) => item.id == itemId);
    
    if (existingItemIndex != -1) {
      // Update existing item quantity
      final updatedItems = List<models.CartItem>.from(items);
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
        quantity: updatedItems[existingItemIndex].quantity + quantity
      );
      _items.value = updatedItems;
    } else {
      // Add new item
      final newItem = models.CartItem(
        id: itemId,
        product: product,
        variation: variation,
        quantity: quantity,
      );
      _items.value = [...items, newItem];
    }
    
    _updateCountAndTotal();
    await saveCart();
  }

  Future<void> removeItem(String itemId) async {
    _items.value = _items.value.where((item) => item.id != itemId).toList();
    _updateCountAndTotal();
    await saveCart();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final existingIndex = _items.value.indexWhere((item) => item.id == itemId);

    if (existingIndex != -1) {
      final newItems = List<models.CartItem>.from(_items.value);
      if (quantity > 0) {
        newItems[existingIndex] = newItems[existingIndex].copyWith(quantity: quantity);
        _items.value = newItems;
      } else {
        newItems.removeAt(existingIndex);
        _items.value = newItems;
      }
      _updateCountAndTotal();
      await saveCart();
    }
  }

  Future<void> clearCart() async {
    _items.value = [];
    _updateCountAndTotal();
    await saveCart();
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

    await clearCart();
  }
}
