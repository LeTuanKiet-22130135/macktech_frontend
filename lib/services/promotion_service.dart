import '../models/promotion.dart';
import 'dio_client.dart';

class PromotionService {
  static Future<List<Promotion>> fetchActivePromotions() async {
    final response = await DioClient.instance.get('/api/promotions');
    final data = response.data as List<dynamic>? ?? [];
    return data.map((json) => Promotion.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Admin APIs
  static Future<List<Promotion>> fetchAdminPromotions() async {
    final response = await DioClient.instance.get('/api/admin/promotions');
    final data = response.data as List<dynamic>? ?? [];
    return data.map((json) => Promotion.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<Promotion> createPromotion(Promotion promotion) async {
    final response = await DioClient.instance.post(
      '/api/admin/promotions',
      data: promotion.toJson(),
    );
    return Promotion.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<Promotion> updatePromotion(String id, Promotion promotion) async {
    final response = await DioClient.instance.put(
      '/api/admin/promotions/$id',
      data: promotion.toJson(),
    );
    return Promotion.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> deletePromotion(String id) async {
    await DioClient.instance.delete('/api/admin/promotions/$id');
  }
}
