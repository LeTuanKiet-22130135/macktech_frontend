import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api/user_api.dart';

class UserService {
  static final UserApi _api = UserApi(DioClient.instance);

  /// Fetch the current user's profile data.
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final result = await _api.fetchProfile();
      return result as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e) ?? 'Failed to fetch profile.';
      throw Exception(errorMessage);
    }
  }

  /// Helper to extract error message from response.
  static String? _extractErrorMessage(DioException e) {
    if (e.response != null && e.response!.data != null) {
      if (e.response!.data is Map && e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      } else if (e.response!.data is String) {
        return e.response!.data.toString();
      }
    }
    return e.message;
  }

  /// Update the current user's avatar URL.
  static Future<void> updateAvatar(String avatarUrl) async {
    try {
      await _api.updateAvatar({'avatarUrl': avatarUrl});
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to update avatar.');
    }
  }

  /// Update the current user's profile info (name, phone, email).
  static Future<void> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      await _api.updateProfile({
        'name': name,
        'phone': phone,
        'email': email,
      });
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e) ?? 'Failed to update profile.';
      throw Exception(errorMessage);
    }
  }

  /// Change Password (Admin/Agent Only).
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _api.changePassword({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to change password.');
    }
  }
}
