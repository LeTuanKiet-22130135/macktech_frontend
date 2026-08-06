import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

/// Fetches products for a given page (0-indexed), 20 items per page.
final allProductsProvider = FutureProvider.family<({
  List<Product> products, 
  int totalPages, 
  int totalElements,
  List<String> availableBrands,
  List<Category> availableCategories,
  double minPrice,
  double maxPrice,
}), int>((ref, page) async {
  return ProductService.fetchAllProducts(page: page, size: 20);
});
