import '../models/product_detail.dart';
import '../models/product.dart';
import 'dio_client.dart';

/// Service to fetch individual product details from the backend.
class ProductService {
  /// Fetch full product details from GET /api/products/{id}.
  /// This is a public endpoint — no auth required.
  static Future<ProductDetail> fetchProductDetail(String productId) async {
    final response = await DioClient.instance.get('/api/products/$productId');
    return ProductDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch paginated products from GET /api/products.
  /// [page] is 0-indexed (backend default: 0). [size] is items per page (backend default: 10).
  static Future<({List<Product> products, int totalPages, int totalElements})> fetchAllProducts({int page = 0, int size = 20}) async {
    final response = await DioClient.instance.get(
      '/api/products',
      queryParameters: {'page': page, 'size': size},
    );
    final mapData = response.data as Map<String, dynamic>;
    final productsList = mapData['products'] as List<dynamic>? ?? [];
    
    final products = productsList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    final totalPages = mapData['totalPages'] as int? ?? 0;
    final totalElements = mapData['totalElements'] as int? ?? 0;
    
    return (products: products, totalPages: totalPages, totalElements: totalElements);
  }
  static Future<({
    List<Product> products,
    int totalPages,
    int totalElements,
    List<String> availableBrands,
    double minPrice,
    double maxPrice,
  })> searchProducts({
    String? query,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty) queryParams['sortOrder'] = sortOrder;

    final response = await DioClient.instance.get(
      '/api/products/search',
      queryParameters: queryParams,
    );
    
    final mapData = response.data as Map<String, dynamic>;
    final productsList = mapData['products'] as List<dynamic>? ?? [];
    
    final products = productsList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    final totalPages = mapData['totalPages'] as int? ?? 0;
    final totalElements = mapData['totalElements'] as int? ?? 0;
    final availableBrands = (mapData['availableBrands'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    final respMinPrice = (mapData['minPrice'] as num?)?.toDouble() ?? 0.0;
    final respMaxPrice = (mapData['maxPrice'] as num?)?.toDouble() ?? 0.0;
    
    return (
      products: products,
      totalPages: totalPages,
      totalElements: totalElements,
      availableBrands: availableBrands,
      minPrice: respMinPrice,
      maxPrice: respMaxPrice,
    );
  }

  /// Create a new product (Admin Only)
  static Future<ProductDetail> createProduct(Map<String, dynamic> productData) async {
    final response = await DioClient.instance.post(
      '/api/products',
      data: productData,
    );
    return ProductDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update an existing product (Admin Only)
  static Future<ProductDetail> updateProduct(String productId, Map<String, dynamic> productData) async {
    final response = await DioClient.instance.put(
      '/api/products/$productId',
      data: productData,
    );
    return ProductDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete a product (Admin Only)
  static Future<void> deleteProduct(String productId) async {
    await DioClient.instance.delete('/api/products/$productId');
  }
}
