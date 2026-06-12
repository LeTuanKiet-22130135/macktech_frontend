class ShippingAddress {
  final int? id;
  final String addressLabel;
  final bool isDefault;
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String ward;
  final String district;
  final String cityProvince;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShippingAddress({
    this.id,
    required this.addressLabel,
    required this.isDefault,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.ward,
    required this.district,
    required this.cityProvince,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as int?,
      addressLabel: json['addressLabel'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      recipientName: json['recipientName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      streetAddress: json['streetAddress'] as String? ?? '',
      ward: json['ward'] as String? ?? '',
      district: json['district'] as String? ?? '',
      cityProvince: json['cityProvince'] as String? ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'addressLabel': addressLabel,
      'isDefault': isDefault,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'ward': ward,
      'district': district,
      'cityProvince': cityProvince,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  ShippingAddress copyWith({
    int? id,
    String? addressLabel,
    bool? isDefault,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? ward,
    String? district,
    String? cityProvince,
    double? latitude,
    double? longitude,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      addressLabel: addressLabel ?? this.addressLabel,
      isDefault: isDefault ?? this.isDefault,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      cityProvince: cityProvince ?? this.cityProvince,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get fullAddress {
    return [streetAddress, ward, district, cityProvince]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
  }
}
