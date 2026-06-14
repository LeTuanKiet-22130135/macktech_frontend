import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import 'dio_client.dart';

class CategoryService {
  /// Fetch a list of all product categories.
  static Future<List<Category>> getAllCategories() async {
    try {
      final response = await DioClient.instance.get('/api/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }
}
