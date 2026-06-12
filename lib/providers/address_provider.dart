import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shipping_address.dart';
import '../services/address_service.dart';

class AddressNotifier extends AsyncNotifier<List<ShippingAddress>> {
  @override
  Future<List<ShippingAddress>> build() async {
    return AddressService.getAddresses();
  }

  Future<void> addAddress(ShippingAddress address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AddressService.addAddress(address);
      return AddressService.getAddresses();
    });
  }

  Future<void> updateAddress(int id, ShippingAddress address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AddressService.updateAddress(id, address);
      return AddressService.getAddresses();
    });
  }

  Future<void> deleteAddress(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AddressService.deleteAddress(id);
      return AddressService.getAddresses();
    });
  }

  Future<void> setDefaultAddress(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AddressService.setDefaultAddress(id);
      return AddressService.getAddresses();
    });
  }
}

final addressProvider = AsyncNotifierProvider<AddressNotifier, List<ShippingAddress>>(() {
  return AddressNotifier();
});
