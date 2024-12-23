class User {
  final String id;
  final String name;
  final String email;
  final String address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
