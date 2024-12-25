class Product {
  final int id;
  final String name;
  final String description;
  final String shortDescription;
  final String type; // simple or variable
  final String status;
  final String price;
  final String regularPrice;
  final String salePrice;
  final List<String> images;
  final bool onSale;
  final bool inStock;
  final int stockQuantity;
  final List<ProductAttribute> attributes;
  final List<int> variations;
  final List<int> relatedIds;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.type,
    required this.status,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.images,
    required this.onSale,
    required this.inStock,
    required this.stockQuantity,
    required this.attributes,
    required this.variations,
    required this.relatedIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      type: json['type'] ?? 'simple',
      status: json['status'] ?? '',
      price: json['price'] ?? '0',
      regularPrice: json['regular_price'] ?? '0',
      salePrice: json['sale_price'] ?? '0',
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => image['src'].toString())
              .toList() ??
          [],
      onSale: json['on_sale'] ?? false,
      inStock: json['stock_status'] == 'instock',
      stockQuantity: json['stock_quantity'] ?? 0,
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((attr) => ProductAttribute.fromJson(attr))
              .toList() ??
          [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map((v) => v as int)
              .toList() ??
          [],
      relatedIds: (json['related_ids'] as List<dynamic>?)
              ?.map((id) => id as int)
              .toList() ??
          [],
    );
  }
}

class ProductAttribute {
  final int id;
  final String name;
  final List<String> options;
  final bool variation;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.options,
    required this.variation,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => option.toString())
              .toList() ??
          [],
      variation: json['variation'] ?? false,
    );
  }
}

class ProductVariation {
  final int id;
  final String price;
  final String regularPrice;
  final String salePrice;
  final bool onSale;
  final bool inStock;
  final int stockQuantity;
  final Map<String, String> attributes;
  final String? image;

  ProductVariation({
    required this.id,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.onSale,
    required this.inStock,
    required this.stockQuantity,
    required this.attributes,
    this.image,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'] ?? 0,
      price: json['price'] ?? '0',
      regularPrice: json['regular_price'] ?? '0',
      salePrice: json['sale_price'] ?? '0',
      onSale: json['on_sale'] ?? false,
      inStock: json['stock_status'] == 'instock',
      stockQuantity: json['stock_quantity'] ?? 0,
      attributes: Map<String, String>.from(
        (json['attributes'] as List<dynamic>).fold<Map<String, String>>(
          {},
          (map, attr) => map..putIfAbsent(attr['name'], () => attr['option']),
        ),
      ),
      image: json['image']?['src'],
    );
  }
}

class ProductReview {
  final int id;
  final String reviewer;
  final String review;
  final int rating;
  final DateTime dateCreated;

  ProductReview({
    required this.id,
    required this.reviewer,
    required this.review,
    required this.rating,
    required this.dateCreated,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? 0,
      reviewer: json['reviewer'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
      dateCreated: DateTime.parse(json['date_created'] ?? ''),
    );
  }
}
