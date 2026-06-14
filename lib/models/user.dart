class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final bool notificationsEnabled;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.address,
    this.avatarUrl,
    this.notificationsEnabled = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      role: json['role']?.toString() ?? 'USER',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
