import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_detail.dart';
import '../services/product_service.dart';

/// Fetches full product details by product ID.
/// Usage: ref.watch(productDetailProvider(productId))
final productDetailProvider =
    FutureProvider.family<ProductDetail, String>((ref, productId) async {
  return ProductService.fetchProductDetail(productId);
});
