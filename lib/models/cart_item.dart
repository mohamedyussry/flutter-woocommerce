import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final ProductVariation? variation;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.variation,
    required this.quantity,
  });

  CartItem copyWith({
    String? id,
    Product? product,
    ProductVariation? variation,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      variation: variation ?? this.variation,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      variation: json['variation'] != null 
          ? ProductVariation.fromJson(json['variation'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'variation': variation?.toJson(),
      'quantity': quantity,
    };
  }

  String get displayName {
    if (variation != null && variation!.attributes.isNotEmpty) {
      final attributesText = variation!.attributes.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', ');
      return '${product.name} ($attributesText)';
    }
    return product.name;
  }

  String get price {
    if (variation != null) {
      return variation!.price;
    }
    return product.price;
  }

  bool get isInStock {
    if (variation != null) {
      return variation!.stockStatus == 'instock';
    }
    return product.stockStatus == 'instock';
  }
}
