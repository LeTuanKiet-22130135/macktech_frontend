import '../models/shipping_address.dart';
import 'dio_client.dart';

class AddressService {
  static Future<List<ShippingAddress>> getAddresses() async {
    final response = await DioClient.instance.get('/api/user/addresses');
    final data = response.data as List<dynamic>;
    return data.map((json) => ShippingAddress.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<ShippingAddress> addAddress(ShippingAddress address) async {
    final response = await DioClient.instance.post(
      '/api/user/addresses',
      data: address.toJson(),
    );
    return ShippingAddress.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<ShippingAddress> updateAddress(int id, ShippingAddress address) async {
    final response = await DioClient.instance.put(
      '/api/user/addresses/$id',
      data: address.toJson(),
    );
    return ShippingAddress.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> deleteAddress(int id) async {
    await DioClient.instance.delete('/api/user/addresses/$id');
  }

  static Future<ShippingAddress> setDefaultAddress(int id) async {
    final response = await DioClient.instance.post('/api/user/addresses/$id/default');
    return ShippingAddress.fromJson(response.data as Map<String, dynamic>);
  }
}
