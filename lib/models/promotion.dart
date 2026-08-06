class PromotionProduct {
  final String sku;
  final String? productTitle;
  final double? discountPercentage;

  PromotionProduct({
    required this.sku,
    this.productTitle,
    this.discountPercentage,
  });

  factory PromotionProduct.fromJson(Map<String, dynamic> json) {
    return PromotionProduct(
      sku: json['sku']?.toString() ?? '',
      productTitle: json['productTitle']?.toString(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      if (productTitle != null) 'productTitle': productTitle,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
    };
  }
}

class Promotion {
  final String? id;
  final String title;
  final String bannerImageUrl;
  final List<PromotionProduct> products;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime? createdAt;

  Promotion({
    this.id,
    required this.title,
    required this.bannerImageUrl,
    this.products = const [],
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      bannerImageUrl: json['bannerImageUrl'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => PromotionProduct.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'bannerImageUrl': bannerImageUrl,
      'products': products.map((p) => p.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
