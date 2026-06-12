import '../models/product.dart';
import 'dio_client.dart';
import 'session_service.dart';

/// Service to fetch product recommendations from the backend.
class RecommendationService {
  /// Fetch recommended products from GET /api/user/recommendations.
  /// Requires user token and id in the request body.
  /// [page] is 0-indexed (backend default: 0). [size] is items per page (backend default: 16).
  static Future<({String? recommId, List<Product> products, int totalPages, int totalElements})> fetchRecommendations({int page = 0, int size = 6}) async {
    final user = await SessionService.getUser();
    final response = await DioClient.instance.get(
      '/api/user/recommendations',
      queryParameters: {'page': page, 'size': size},
      data: {
        'token': user['token'] ?? '',
        'userId': user['id'] ?? '',
      },
    );
    
    final mapData = response.data as Map<String, dynamic>;
    final recommId = mapData['recommId'] as String?;
    final productsList = mapData['products'] as List<dynamic>? ?? [];
    
    final products = productsList
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
        
    final totalPages = mapData['totalPages'] as int? ?? 0;
    final totalElements = mapData['totalElements'] as int? ?? 0;
        
    return (recommId: recommId, products: products, totalPages: totalPages, totalElements: totalElements);
  }
}
