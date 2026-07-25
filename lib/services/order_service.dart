import 'package:flutter/foundation.dart';
import 'dio_client.dart';

class OrderService {
  /// Create a new order. Returns a map with 'orderId' and optionally 'paymentUrl'.
  static Future<Map<String, dynamic>?> createOrder({
    required int addressId,
    required int toDistrictId,
    required String toWardCode,
    required String paymentMethod,
    required double finalCost,
    required List<String> itemNames,
    String? promoCode,
    int? paymentCardId,
  }) async {
    try {
      final response = await DioClient.instance.post(
        '/api/orders',
        data: {
          'addressId': addressId,
          'toDistrictId': toDistrictId,
          'toWardCode': toWardCode,
          'paymentMethod': paymentMethod.toUpperCase(),
          'finalCost': finalCost,
          'itemNames': itemNames,
          'promoCode': ?promoCode,
          'paymentCardId': ?paymentCardId,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  /// Get the authenticated user's order history.
  static Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await DioClient.instance.get('/api/orders');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  /// Get all orders in the system (Admin Only).
  static Future<List<dynamic>> getAllOrdersAdmin() async {
    try {
      final response = await DioClient.instance.get('/api/admin/orders');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching admin orders: $e');
      return [];
    }
  }

  /// Get details for a specific order.
  static Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final response = await DioClient.instance.get('/api/orders/$orderId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      return null;
    }
  }

  /// Cancel a pending order.
  static Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await DioClient.instance.post('/api/orders/$orderId/cancel');
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error canceling order: $e');
      return false;
    }
  }
}
