import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/dio_client.dart';
import '../services/recombee_tracking_service.dart';
import 'session_provider.dart';

class WishlistNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final session = await ref.watch(sessionProvider.future);
    if (!session.isLoggedIn || session.id == null) return [];

    try {
      final response = await DioClient.instance.get(
        '/api/wishlist',
        queryParameters: {'userId': session.id},
      );
      final data = response.data as List<dynamic>? ?? [];
      return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetching wishlist: $e");
      return [];
    }
  }

  Future<void> toggleWishlist(Product product) async {
    final session = await ref.watch(sessionProvider.future);
    if (!session.isLoggedIn || session.id == null) return;

    final currentList = state.value ?? [];
    final isWished = currentList.any((p) => p.id == product.id);
    
    // Optimistic UI update
    if (isWished) {
      state = AsyncData(currentList.where((p) => p.id != product.id).toList());
    } else {
      state = AsyncData([...currentList, product]);
    }

    try {
      final productIdInt = int.tryParse(product.id) ?? product.id;
      if (isWished) {
        await DioClient.instance.post(
          '/api/wishlist/remove',
          data: {
            'userId': session.id,
            'productId': productIdInt,
          },
        );
        RecombeeTrackingService.trackDeleteBookmark(product.id);
      } else {
        await DioClient.instance.post(
          '/api/wishlist/add',
          data: {
            'userId': session.id,
            'productId': productIdInt,
          },
        );
        RecombeeTrackingService.trackAddBookmark(product.id);
      }
    } catch (e) {
      print("Error toggling wishlist: $e");
      // Revert on error
      ref.invalidateSelf();
    }
  }

  bool isInWishlist(String productId) {
    return state.value?.any((p) => p.id == productId) ?? false;
  }
}

final wishlistProvider =
    AsyncNotifierProvider<WishlistNotifier, List<Product>>(
        WishlistNotifier.new);
