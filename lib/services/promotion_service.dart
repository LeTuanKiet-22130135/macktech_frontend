import '../models/promotion.dart';
import 'dio_client.dart';

class PromotionService {
  static Future<List<Promotion>> fetchActivePromotions() async {
    final response = await DioClient.instance.get('/api/promotions');
    final data = response.data as List<dynamic>? ?? [];
    return data.map((json) => Promotion.fromJson(json as Map<String, dynamic>)).toList();
  }
}
