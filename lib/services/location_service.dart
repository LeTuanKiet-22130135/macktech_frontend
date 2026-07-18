import 'dio_client.dart';

class LocationService {
  static Future<Map<String, String>?> reverseGeocode(
    double lat,
    double lng,
  ) async {
    try {
      final response = await DioClient.instance.get(
        '/api/location/reverse',
        queryParameters: {'lat': lat, 'lon': lng},
      );

      final data = response.data;
      if (data != null) {
        final street = data['streetAddress'] as String? ?? '';
        final ward = data['ward'] as String? ?? '';
        final district = data['district'] as String? ?? '';
        final city = data['provinceCity'] as String? ?? '';

        final fullParts = [
          street,
          ward,
          district,
          city,
        ].where((s) => s.isNotEmpty).join(', ');

        return {
          'street': street,
          'ward': ward,
          'district': district,
          'city': city,
          'full': fullParts,
        };
      }
    } catch (e) {
      // Failed to geocode
    }
    return null;
  }
}
