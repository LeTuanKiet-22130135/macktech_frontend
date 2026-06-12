import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxService {
  static final Dio _dio = Dio();

  static Future<Map<String, String>?> reverseGeocode(double lat, double lng) async {
    final apiKey = dotenv.env['MAPBOX_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_key_here') {
      return null;
    }

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/search/geocode/v6/reverse',
        queryParameters: {
          'longitude': lng,
          'latitude': lat,
          'access_token': apiKey,
        },
      );

      final data = response.data;
      if (data != null && data['features'] != null && (data['features'] as List).isNotEmpty) {
        final feature = data['features'][0];
        final properties = feature['properties'] ?? {};
        final context = properties['context'] ?? {};

        String? street = _extractContextName(context, 'street');
        final addressNum = _extractContextName(context, 'address');
        if (street != null && addressNum != null) {
          street = '$addressNum $street';
        } else if (street == null) {
          street = properties['name'] as String?;
        }

        final ward = _extractContextName(context, 'neighborhood') ?? _extractContextName(context, 'locality') ?? '';
        final district = _extractContextName(context, 'district') ?? _extractContextName(context, 'place') ?? '';
        final city = _extractContextName(context, 'region') ?? _extractContextName(context, 'place') ?? '';

        return {
          'street': street ?? '',
          'ward': ward,
          'district': district,
          'city': city,
          'full': properties['full_address'] as String? ?? '',
        };
      }
    } catch (e) {
      // Failed to geocode
    }
    return null;
  }

  static String? _extractContextName(Map<String, dynamic> context, String key) {
    if (context.containsKey(key) && context[key] != null) {
      return context[key]['name'] as String?;
    }
    return null;
  }
}
