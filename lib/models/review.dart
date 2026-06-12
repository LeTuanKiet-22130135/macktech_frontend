class Review {
  final String id;
  final String productId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String content;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      productId: json['productId']?.toString() ?? '',
      userName: json['userName'] as String? ?? 'Anonymous',
      userAvatar: json['userAvatar'] as String? ?? 'assets/images/Placeholder_01.jpg',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
