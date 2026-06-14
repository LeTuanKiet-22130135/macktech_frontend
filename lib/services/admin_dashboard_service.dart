import 'package:flutter/foundation.dart';
import 'dio_client.dart';

class AdminDashboardService {
  /// Get Key Metrics (Revenue, Orders, Products)
  static Future<Map<String, dynamic>?> getKeyMetrics() async {
    try {
      final response = await DioClient.instance.get('/api/admin/dashboard/metrics');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching key metrics: $e');
      return null;
    }
  }

  /// Get Revenue Chart Data based on timeframe
  static Future<Map<String, dynamic>?> getRevenueChartData(String timeframe) async {
    try {
      final response = await DioClient.instance.get(
        '/api/admin/dashboard/revenue-chart',
        queryParameters: {'timeframe': timeframe},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching revenue chart data: $e');
      return null;
    }
  }

  /// Get Top Selling Products
  static Future<List<dynamic>> getTopSellingProducts({int limit = 5}) async {
    try {
      final response = await DioClient.instance.get(
        '/api/admin/dashboard/top-products',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching top selling products: $e');
      return [];
    }
  }
}
