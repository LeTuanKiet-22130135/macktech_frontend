class Promotion {
  final String title;
  final String bannerImageUrl;
  final int? linkedProductId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Promotion({
    required this.title,
    required this.bannerImageUrl,
    this.linkedProductId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'] as String? ?? '',
      bannerImageUrl: json['bannerImageUrl'] as String? ?? '',
      linkedProductId: json['linkedProductId'] as int?,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
