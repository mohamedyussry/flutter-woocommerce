import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  
  @JsonKey(name: 'slug', defaultValue: '')
  final String slug;
  
  @JsonKey(name: 'short_description', defaultValue: '')
  final String shortDescription;
  
  @JsonKey(name: 'regular_price', fromJson: _priceFromJson, defaultValue: '')
  final String regularPrice;
  
  @JsonKey(name: 'sale_price', fromJson: _priceFromJson, defaultValue: '')
  final String salePrice;
  
  @JsonKey(name: 'on_sale', defaultValue: false)
  final bool onSale;
  
  @JsonKey(name: 'featured', defaultValue: false)
  final bool featured;
  
  @JsonKey(name: 'stock_status', defaultValue: 'instock')
  final String stockStatus;
  
  @JsonKey(defaultValue: [])
  final List<ProductImage> images;
  
  @JsonKey(defaultValue: [])
  final List<ProductCategory> categories;
  
  @JsonKey(defaultValue: [])
  final List<ProductAttribute> attributes;
  
  @JsonKey(defaultValue: [])
  final List<ProductVariation> variations;
  
  @JsonKey(name: 'date_created', defaultValue: '')
  final String dateCreated;

  @JsonKey(name: 'average_rating', defaultValue: '0')
  final String averageRating;

  @JsonKey(name: 'rating_count', defaultValue: 0)
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    this.slug = '',
    this.shortDescription = '',
    this.regularPrice = '',
    this.salePrice = '',
    this.onSale = false,
    this.featured = false,
    this.stockStatus = 'instock',
    this.images = const [],
    this.categories = const [],
    this.attributes = const [],
    this.variations = const [],
    this.dateCreated = '',
    this.averageRating = '0',
    this.ratingCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  static String _priceFromJson(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    return '';
  }
}

@JsonSerializable()
class ProductImage {
  final int id;
  
  @JsonKey(name: 'src', fromJson: _srcFromJson)
  final String src;
  
  final String name;
  final String alt;

  ProductImage({
    required this.id,
    required this.src,
    required this.name,
    required this.alt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
  Map<String, dynamic> toJson() => _$ProductImageToJson(this);
      
  static String _srcFromJson(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    String url = value.toString();
    url = url.replaceAll(r'\\/', '/').replaceAll(r'\/', '/');
    if (url.startsWith('http')) {
      return url;
    }
    return '';
  }
}

@JsonSerializable()
class ProductCategory {
  final int id;
  final String name;
  final String slug;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);
}

@JsonSerializable()
class ProductAttribute {
  final int id;
  final String name;
  
  @JsonKey(name: 'position', fromJson: _positionFromJson)
  final int position;
  
  @JsonKey(name: 'visible')
  final bool visible;
  
  @JsonKey(name: 'variation')
  final bool variation;
  
  @JsonKey(name: 'options', fromJson: _optionsFromJson)
  final List<String> options;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.position,
    required this.visible,
    required this.variation,
    required this.options,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) =>
      _$ProductAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$ProductAttributeToJson(this);

  static int _positionFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _optionsFromJson(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

@JsonSerializable()
class ProductVariation {
  final int id;
  
  @JsonKey(name: 'regular_price', fromJson: _priceFromJson, defaultValue: '')
  final String regularPrice;
  
  @JsonKey(name: 'sale_price', fromJson: _priceFromJson, defaultValue: '')
  final String salePrice;
  
  @JsonKey(name: 'price', fromJson: _priceFromJson, defaultValue: '')
  final String price;
  
  @JsonKey(name: 'on_sale', defaultValue: false)
  final bool onSale;
  
  @JsonKey(name: 'stock_status', defaultValue: 'instock')
  final String stockStatus;
  
  @JsonKey(defaultValue: {})
  final Map<String, String> attributes;

  ProductVariation({
    required this.id,
    this.regularPrice = '',
    this.salePrice = '',
    this.price = '',
    this.onSale = false,
    this.stockStatus = 'instock',
    this.attributes = const {},
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) =>
      _$ProductVariationFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariationToJson(this);

  static String _priceFromJson(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    return '';
  }
}
