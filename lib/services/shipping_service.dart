import 'package:flutter/foundation.dart';
import 'dio_client.dart';

class ShippingService {
  /// Fetch province ID from GHN by province name.
  static Future<int?> getProvinceId(String provinceName) async {
    if (provinceName.isEmpty) return null;

    try {
      final response = await DioClient.instance.get(
        '/api/shipping/provinces',
        data: {'province': provinceName},
      );

      final List<dynamic> ids = response.data;
      if (ids.isNotEmpty) {
        return ids.first as int;
      }
    } catch (e) {
      debugPrint('Error fetching province ID: $e');
    }
    return null;
  }

  /// Fetch district ID.
  /// Resolves the province ID dynamically from [provinceName].
  static Future<int?> getDistrictId(String districtName, String provinceName) async {
    if (districtName.isEmpty) return null;

    final provinceId = await getProvinceId(provinceName);
    if (provinceId == null) {
      debugPrint('Could not resolve province ID for "$provinceName"');
      return null;
    }

    try {
      final response = await DioClient.instance.get(
        '/api/shipping/districts',
        data: {'provinceId': provinceId, 'district': districtName},
      );

      final List<dynamic> ids = response.data;
      if (ids.isNotEmpty) {
        return ids.first as int;
      }
    } catch (e) {
      debugPrint('Error fetching district ID: $e');
    }
    return null;
  }

  /// Fetch ward code.
  static Future<String?> getWardCode(int districtId, String wardName) async {
    if (wardName.isEmpty) return null;

    try {
      final response = await DioClient.instance.get(
        '/api/shipping/wards',
        data: {'districtId': districtId, 'ward': wardName},
      );

      final List<dynamic> codes = response.data;
      if (codes.isNotEmpty) {
        return codes.first.toString();
      }
    } catch (e) {
      debugPrint('Error fetching ward code: $e');
    }
    return null;
  }

  /// Calculate shipping fee
  static Future<double> calculateFee(int districtId, String wardCode, String paymentMethod) async {
    try {
      final response = await DioClient.instance.post(
        '/api/shipping/fee',
        data: {
          'toDistrictId': districtId,
          'toWardCode': wardCode,
          'serviceId': 53320,
          'insuranceValue': null,
          'paymentMethod': paymentMethod,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return (data['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error calculating shipping fee: $e');
      return 0.0;
    }
  }
}
