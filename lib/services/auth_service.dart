import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api/auth_api.dart';

class AuthService {
  static final AuthApi _api = AuthApi(DioClient.instance);

  /// Unified Login via Firebase ID token.
  /// Handles Email/Password, Google, and Facebook Auth.
  static Future<Map<String, dynamic>> login({
    required String idToken,
    required String provider,
  }) async {
    try {
      final result = await _api.loginUser({
        'firebaseToken': idToken,
        'provider': provider,
      });
      return result as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e) ?? 'Login failed.';
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

  /// Register a new user in the backend.
  static Future<void> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _api.registerUser({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e) ?? 'Registration failed.';
      throw Exception(errorMessage);
    }
  }

  /// Admin Login via email and password.
  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _api.adminLogin({
        'email': email,
        'password': password,
      });
      return result as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e) ?? 'Admin login failed.';
      throw Exception(errorMessage);
    }
  }

  /// Check if a phone number is registered in Firebase.
  static Future<bool> checkPhoneExists(String phone) async {
    try {
      final result = await _api.checkPhone(phone);
      final data = result as Map<String, dynamic>;
      return data['exists'] == true;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to check phone.');
    }
  }

  /// Send OTP for password recovery.
  static Future<void> sendPasswordRecoveryOtp(String email) async {
    try {
      await _api.sendOtp({'email': email});
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to send OTP.');
    }
  }

  /// Verify OTP for password recovery.
  static Future<String> verifyPasswordRecoveryOtp(String email, String otp) async {
    try {
      final result = await _api.verifyOtp({'email': email, 'otp': otp});
      final data = result as Map<String, dynamic>;
      return data['resetToken'] as String;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Invalid or expired OTP');
    }
  }

  /// Reset password using resetToken.
  static Future<void> resetPassword(String email, String resetToken, String newPassword) async {
    try {
      await _api.resetPassword({
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to reset password.');
    }
  }

  /// Delete user account via Firebase ID token.
  static Future<void> deleteAccount(String firebaseToken) async {
    try {
      await _api.deleteAccount({'firebaseToken': firebaseToken});
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to delete account.');
    }
  }
}
