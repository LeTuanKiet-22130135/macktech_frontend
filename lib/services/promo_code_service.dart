import 'dio_client.dart';
import '../models/promo_code.dart';

class PromoCodeService {
  /// Fetch all promo codes (Admin Only)
  static Future<List<PromoCode>> getAllPromoCodes() async {
    final response = await DioClient.instance.get('/api/admin/promo-codes');
    final data = response.data as List<dynamic>;
    return data.map((json) => PromoCode.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get promo code by ID (Admin Only)
  static Future<PromoCode> getPromoCodeById(String id) async {
    final response = await DioClient.instance.get('/api/admin/promo-codes/$id');
    return PromoCode.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create promo code (Admin Only)
  static Future<PromoCode> createPromoCode(Map<String, dynamic> data) async {
    final response = await DioClient.instance.post('/api/admin/promo-codes', data: data);
    return PromoCode.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update promo code (Admin Only)
  static Future<PromoCode> updatePromoCode(String id, Map<String, dynamic> data) async {
    final response = await DioClient.instance.put('/api/admin/promo-codes/$id', data: data);
    return PromoCode.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete promo code (Admin Only)
  static Future<void> deletePromoCode(String id) async {
    await DioClient.instance.delete('/api/admin/promo-codes/$id');
  }
}
