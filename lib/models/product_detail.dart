/// Full product detail returned by GET /api/products/{id}.
class ProductDetail {
  final String id;
  final String sku;
  final String title;
  final String brand;
  final String subText;
  final double price;
  final String description;
  final String keyFeatures;
  final int stockQuantity;
  final List<String> colors;
  final List<String> imageUrls;

  ProductDetail({
    required this.id,
    required this.sku,
    required this.title,
    required this.brand,
    this.subText = '',
    required this.price,
    this.description = '',
    this.keyFeatures = '',
    this.stockQuantity = 0,
    this.colors = const [],
    this.imageUrls = const [],
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'].toString(),
      sku: json['sku'] as String? ?? '',
      title: json['title'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      subText: json['subText'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      keyFeatures: json['keyFeatures'] as String? ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      colors: (json['colors'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((u) => u.toString())
              .toList() ??
          [],
    );
  }

  /// Whether the product is currently available.
  bool get inStock => stockQuantity > 0;
}
