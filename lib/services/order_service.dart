import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart' as models;
import '../models/order.dart';
import 'auth_service.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final _orders = ValueNotifier<List<Order>>([]);
  ValueListenable<List<Order>> get orders => _orders;

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthService().currentUser.value?.id;
    if (userId == null) return;

    final ordersJson = prefs.getString('orders_$userId');
    if (ordersJson != null) {
      final List<dynamic> ordersList = json.decode(ordersJson);
      _orders.value = ordersList.map((json) => Order.fromJson(json)).toList();
    }
  }

  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthService().currentUser.value?.id;
    if (userId == null) return;

    final ordersJson = json.encode(_orders.value.map((order) => order.toJson()).toList());
    await prefs.setString('orders_$userId', ordersJson);
  }

  Future<Order> createOrder({
    required List<models.CartItem> items,
    required double total,
    required String shippingAddress,
  }) async {
    final userId = AuthService().currentUser.value?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: items,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      shippingAddress: shippingAddress,
    );

    _orders.value = [order, ..._orders.value];
    await saveOrders();
    return order;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final orderIndex = _orders.value.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return;

    final updatedOrder = Order(
      id: _orders.value[orderIndex].id,
      userId: _orders.value[orderIndex].userId,
      items: _orders.value[orderIndex].items,
      total: _orders.value[orderIndex].total,
      status: newStatus,
      createdAt: _orders.value[orderIndex].createdAt,
      trackingNumber: _orders.value[orderIndex].trackingNumber,
      shippingAddress: _orders.value[orderIndex].shippingAddress,
    );

    final newOrders = List<Order>.from(_orders.value);
    newOrders[orderIndex] = updatedOrder;
    _orders.value = newOrders;
    await saveOrders();
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }
}
