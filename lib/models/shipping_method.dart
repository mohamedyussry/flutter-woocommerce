class ShippingMethod {
  final String id;
  final String title;
  final String description;
  final double cost;
  final bool enabled;

  ShippingMethod({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.enabled,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cost: double.tryParse((json['settings']?['cost']?['value'] as String? ?? '0').replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'cost': cost.toString(),
    'enabled': enabled,
  };
}
