import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistent user session (JWT token, role, user info).
/// Stores data in SharedPreferences so the user stays logged in across restarts.
class SessionService {
  static const _keyToken = 'session_token';
  static const _keyRefreshToken = 'session_refresh_token';
  static const _keyUserId = 'session_user_id';
  static const _keyUserName = 'session_user_name';
  static const _keyUserEmail = 'session_user_email';
  static const _keyUserRole = 'session_user_role';

  /// Save a full session from the backend auth response.
  /// Expected keys in [data]: token, id, name, email, role
  static Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, data['token'] as String? ?? '');
    await prefs.setString(_keyRefreshToken, data['refreshToken'] as String? ?? '');
    await prefs.setString(_keyUserId, data['id'] as String? ?? '');
    await prefs.setString(_keyUserName, data['name'] as String? ?? '');
    await prefs.setString(_keyUserEmail, data['email'] as String? ?? '');
    await prefs.setString(_keyUserRole, data['role'] as String? ?? 'user');
  }

  /// Returns the stored JWT token, or null if no session exists.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Returns the stored refresh token, or null if no session exists.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyRefreshToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Returns the stored user role, or null if no session exists.
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  /// Returns all stored user info as a Map.
  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_keyToken),
      'refreshToken': prefs.getString(_keyRefreshToken),
      'id': prefs.getString(_keyUserId),
      'name': prefs.getString(_keyUserName),
      'email': prefs.getString(_keyUserEmail),
      'role': prefs.getString(_keyUserRole),
    };
  }

  /// Clear all session data (logout).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
  }

  /// Check if a valid session exists.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
