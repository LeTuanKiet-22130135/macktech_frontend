import 'package:flutter/foundation.dart';
import 'dio_client.dart';
import '../models/user.dart';

class AdminUserService {
  /// Get All Users
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await DioClient.instance.get('/api/admin/users');
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      return [];
    }
  }

  /// Get User by ID
  static Future<User?> getUserById(String id) async {
    try {
      final response = await DioClient.instance.get('/api/admin/users/$id');
      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      return null;
    }
  }

  /// Update User Profile
  static Future<User?> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await DioClient.instance.put('/api/admin/users/$id', data: data);
      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return null;
    }
  }

  /// Change User Password
  static Future<bool> changeUserPassword(String id, String newPassword) async {
    try {
      final response = await DioClient.instance.put(
        '/api/admin/users/$id/password',
        data: {'newPassword': newPassword},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error changing user password: $e');
      return false;
    }
  }

  /// Delete User Account
  static Future<bool> deleteUser(String id) async {
    try {
      final response = await DioClient.instance.delete('/api/admin/users/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
}
