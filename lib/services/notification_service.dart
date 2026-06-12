import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_service.dart';
import 'dio_client.dart';
import 'api/notification_api.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles Firebase Cloud Messaging (FCM) integration.
/// Manages permissions, token registration, and sending notifications.
class NotificationService {
  static const String _prefKeyFcmToken = 'fcm_token';
  static final NotificationApi _api = NotificationApi(DioClient.instance);
  
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM: request permissions, check token, and set up listeners.
  /// Call this once in main() after Firebase.initializeApp().
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _localNotifications.initialize(settings: initializationSettings);

    // Request notification permissions
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // On app startup, compare current FCM token with saved one
    final currentToken = await messaging.getToken();
    if (currentToken != null) {
      final savedToken = await getSavedToken();
      if (savedToken != currentToken) {
        await _saveTokenLocally(currentToken);
        // Backend update will happen on next registerToken() call after login
      }
    }

    // Listen for token refresh while the app is running
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _saveTokenLocally(newToken);
      // If user is logged in, update the backend immediately
      registerToken();
    });

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
      );
    });
  }

  /// Show a local push notification (heads-up)
  static Future<void> showLocalNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  /// Get the current FCM device token.
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Get the locally saved FCM token from SharedPreferences.
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyFcmToken);
  }

  /// Save the FCM token locally to SharedPreferences.
  static Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyFcmToken, token);
  }

  /// Register or update the FCM token with the backend via POST /api/notifications/token.
  /// Only sends the token if it differs from the locally saved one.
  /// Requires a valid JWT session.
  static Future<void> registerToken({bool force = false}) async {
    try {
      final jwt = await SessionService.getToken();
      if (jwt == null) return;

      final fcmToken = await getToken();
      if (fcmToken == null) return;

      if (!force) {
        // Check if the token has changed since last registration
        final savedToken = await getSavedToken();
        if (savedToken == fcmToken) return; // No change, skip backend call
      }

      // Get a simple device name
      final deviceName = Platform.isAndroid ? 'Android Device' : 'iOS Device';

      await _api.registerToken({
        'token': fcmToken,
        'deviceName': deviceName,
      });

      // Save locally only after successful backend registration
      await _saveTokenLocally(fcmToken);
    } catch (_) {
      // Silently fail — notification token registration is non-critical
    }
  }

  /// Check if notifications are enabled for the current user.
  static Future<bool> isNotificationEnabled() async {
    try {
      final jwt = await SessionService.getToken();
      if (jwt == null) return false;

      final result = await _api.isEnabled();
      final data = result as Map<String, dynamic>;
      return data['enabled'] == true;
    } catch (e) {
      debugPrint("isNotificationEnabled error: $e");
      return false;
    }
  }

  /// Update notification preferences for the current user.
  static Future<void> setNotificationPreferences(bool enabled) async {
    try {
      final jwt = await SessionService.getToken();
      if (jwt == null) return;

      await _api.setPreferences({'enabled': enabled});
    } catch (e) {
      debugPrint("setNotificationPreferences error: $e");
    }
  }

  /// Send an order confirmation notification to the current user's devices.
  /// Uses targetEmail to send to all registered devices for the user.
  static Future<void> sendOrderNotification() async {
    try {
      final jwt = await SessionService.getToken();
      if (jwt == null) return;

      final user = await SessionService.getUser();
      final email = user['email'];
      if (email == null || email.isEmpty) return;

      await _api.sendNotification({
        'targetEmail': email,
        'title': 'Order Confirmed',
        'body': 'Your order has been placed successfully! Thank you for choosing Macktech Mobiles.',
      });
    } catch (e) {
      debugPrint("sendOrderNotification failed: $e");
      rethrow;
    }
  }
}
