import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart' as models;

enum OrderStatus {
  pending,    // قيد الانتظار
  processing, // قيد المعالجة
  shipped,    // تم الشحن
  delivered,  // تم التوصيل
  cancelled,  // ملغي
}

class Order {
  final String id;
  final String userId;
  final List<models.CartItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingNumber;
  final String shippingAddress;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.trackingNumber,
    required this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List).map((item) => models.CartItem.fromJson(item)).toList(),
      total: json['total'] as double,
      status: OrderStatus.values[json['status'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      trackingNumber: json['trackingNumber'] as String?,
      shippingAddress: json['shippingAddress'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'trackingNumber': trackingNumber,
      'shippingAddress': shippingAddress,
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.processing:
        return 'قيد المعالجة';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
