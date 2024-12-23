// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name'],
  );
  return Category(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    image: json['image'] as String? ?? '',
    description: json['description'] as String? ?? '',
    parentId: (json['parent'] as num?)?.toInt() ?? 0,
    slug: json['slug'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'description': instance.description,
      'parent': instance.parentId,
      'slug': instance.slug,
      'count': instance.count,
    };
