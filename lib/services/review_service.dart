import 'package:flutter/foundation.dart';
import '../models/review.dart';
import 'dio_client.dart';
import 'session_service.dart';

class ReviewService {
  /// Fetch all reviews for a specific product.
  static Future<List<Review>> getProductReviews(String productId) async {
    try {
      final response = await DioClient.instance.get('/api/products/$productId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting product reviews: $e');
      return [];
    }
  }

  /// Create a new review.
  static Future<Review?> createReview(String productId, double rating, String content) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.post(
        '/api/reviews',
        data: {
          'productId': int.tryParse(productId) ?? 0, // Backend expects productId as integer in this mock scenario
          'rating': rating,
          'content': content,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Review.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating review: $e');
      rethrow;
    }
  }

  /// Update an existing review.
  static Future<Review?> updateReview(String reviewId, double rating, String content) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.put(
        '/api/reviews/$reviewId',
        data: {
          'rating': rating,
          'content': content,
        },
      );
      if (response.statusCode == 200) {
        return Review.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  /// Delete a review.
  static Future<bool> deleteReview(String reviewId) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.delete('/api/reviews/$reviewId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }
}
