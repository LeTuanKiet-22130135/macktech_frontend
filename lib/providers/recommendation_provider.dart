import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/recommendation_service.dart';

/// Fetches recommended products for a given page (0-indexed).
/// Returns recommId + products + pagination metadata for that page.
final recommendationsProvider = FutureProvider.family<({String? recommId, List<Product> products, int totalPages, int totalElements}), int>((ref, page) async {
  return RecommendationService.fetchRecommendations(page: page, size: 6);
});
