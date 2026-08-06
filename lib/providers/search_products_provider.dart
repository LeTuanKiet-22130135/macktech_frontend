import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

class SearchQuery {
  final String query;
  final String sortBy;
  final int page;
  final String? brand;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;

  SearchQuery({
    this.query = '',
    this.sortBy = 'relevance',
    this.page = 0,
    this.brand,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchQuery &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          sortBy == other.sortBy &&
          page == other.page &&
          brand == other.brand &&
          categoryId == other.categoryId &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice;

  @override
  int get hashCode => Object.hash(query, sortBy, page, brand, categoryId, minPrice, maxPrice);
}

/// Return type for the search provider, includes filter metadata.
typedef SearchResult = ({
  List<Product> products,
  int totalPages,
  int totalElements,
  List<String> availableBrands,
  List<Category> availableCategories,
  double minPrice,
  double maxPrice,
});

/// Fetches search results from the backend.
final searchProductsProvider = FutureProvider.family<SearchResult, SearchQuery>((ref, query) async {
  String? backendSortBy;
  String? backendSortOrder;

  switch (query.sortBy) {
    case 'price_low':
      backendSortBy = 'price';
      backendSortOrder = 'asc';
      break;
    case 'price_high':
      backendSortBy = 'price';
      backendSortOrder = 'desc';
      break;
    case 'name_az':
      backendSortBy = 'title';
      backendSortOrder = 'asc';
      break;
    case 'name_za':
      backendSortBy = 'title';
      backendSortOrder = 'desc';
      break;
    case 'relevance':
    default:
      break;
  }

  return ProductService.searchProducts(
    query: query.query,
    brand: query.brand,
    categoryId: query.categoryId,
    minPrice: query.minPrice,
    maxPrice: query.maxPrice,
    sortBy: backendSortBy,
    sortOrder: backendSortOrder,
    page: query.page,
    size: 20,
  );
});
