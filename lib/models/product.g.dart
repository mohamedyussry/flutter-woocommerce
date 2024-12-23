// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      regularPrice: json['regular_price'] == null
          ? ''
          : Product._priceFromJson(json['regular_price']),
      salePrice: json['sale_price'] == null
          ? ''
          : Product._priceFromJson(json['sale_price']),
      onSale: json['on_sale'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      stockStatus: json['stock_status'] as String? ?? 'instock',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => ProductVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dateCreated: json['date_created'] as String? ?? '',
      averageRating: json['average_rating'] as String? ?? '0',
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'short_description': instance.shortDescription,
      'regular_price': instance.regularPrice,
      'sale_price': instance.salePrice,
      'on_sale': instance.onSale,
      'featured': instance.featured,
      'stock_status': instance.stockStatus,
      'images': instance.images,
      'categories': instance.categories,
      'attributes': instance.attributes,
      'variations': instance.variations,
      'date_created': instance.dateCreated,
      'average_rating': instance.averageRating,
      'rating_count': instance.ratingCount,
    };

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
      id: (json['id'] as num).toInt(),
      src: ProductImage._srcFromJson(json['src']),
      name: json['name'] as String,
      alt: json['alt'] as String,
    );

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'src': instance.src,
      'name': instance.name,
      'alt': instance.alt,
    };

ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) =>
    ProductCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$ProductCategoryToJson(ProductCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

ProductAttribute _$ProductAttributeFromJson(Map<String, dynamic> json) =>
    ProductAttribute(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      position: ProductAttribute._positionFromJson(json['position']),
      visible: json['visible'] as bool,
      variation: json['variation'] as bool,
      options: ProductAttribute._optionsFromJson(json['options']),
    );

Map<String, dynamic> _$ProductAttributeToJson(ProductAttribute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'position': instance.position,
      'visible': instance.visible,
      'variation': instance.variation,
      'options': instance.options,
    };

ProductVariation _$ProductVariationFromJson(Map<String, dynamic> json) =>
    ProductVariation(
      id: (json['id'] as num).toInt(),
      regularPrice: json['regular_price'] == null
          ? ''
          : ProductVariation._priceFromJson(json['regular_price']),
      salePrice: json['sale_price'] == null
          ? ''
          : ProductVariation._priceFromJson(json['sale_price']),
      price: json['price'] == null
          ? ''
          : ProductVariation._priceFromJson(json['price']),
      onSale: json['on_sale'] as bool? ?? false,
      stockStatus: json['stock_status'] as String? ?? 'instock',
      attributes: (json['attributes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          {},
    );

Map<String, dynamic> _$ProductVariationToJson(ProductVariation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'regular_price': instance.regularPrice,
      'sale_price': instance.salePrice,
      'price': instance.price,
      'on_sale': instance.onSale,
      'stock_status': instance.stockStatus,
      'attributes': instance.attributes,
    };
