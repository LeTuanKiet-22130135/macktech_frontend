class Product {
  final String id;
  final String title;
  final String brand;
  final String subText;
  final double price;
  final String imageUrl;
  final List<String> colors;
  final List<String> specifications;

  Product({
    required this.id,
    required this.title,
    required this.brand,
    this.subText = "",
    required this.price,
    required this.imageUrl,
    this.colors = const [],
    this.specifications = const [],
  });

  /// Construct from API JSON response.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      subText: json['subText'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
