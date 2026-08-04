class Promotion {
  final String? id;
  final String title;
  final String bannerImageUrl;
  final String? sku;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime? createdAt;

  Promotion({
    this.id,
    required this.title,
    required this.bannerImageUrl,
    this.sku,
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
      sku: json['sku']?.toString(),
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
      'sku': sku,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
