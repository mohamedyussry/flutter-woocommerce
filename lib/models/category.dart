import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable(explicitToJson: true)
class Category {
  @JsonKey(required: true)
  final int id;
  
  @JsonKey(required: true)
  final String name;
  
  @JsonKey(defaultValue: '')
  final String image;
  
  @JsonKey(defaultValue: '')
  final String description;
  
  @JsonKey(name: 'parent', defaultValue: 0)
  final int parentId;
  
  @JsonKey(defaultValue: '')
  final String slug;
  
  @JsonKey(defaultValue: 0)
  final int count;

  Category({
    required this.id,
    required this.name,
    this.image = '',
    this.description = '',
    this.parentId = 0,
    this.slug = '',
    this.count = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
