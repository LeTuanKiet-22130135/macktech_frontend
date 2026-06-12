import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Manages notification enabled state and notification-related network requests.
class NotificationNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      return await NotificationService.isNotificationEnabled();
    } catch (e) {
      debugPrint('NotificationNotifier.build error: $e');
      return false;
    }
  }

  /// Toggle notification preference and update the backend.
  Future<void> toggle(bool enabled) async {
    state = AsyncData(enabled);
    try {
      await NotificationService.setNotificationPreferences(enabled);
    } catch (e) {
      debugPrint('NotificationNotifier.toggle error: $e');
      // Revert on failure
      state = AsyncData(!enabled);
    }
  }

  /// Send order confirmation notification via POST /api/notifications/send.
  Future<void> sendOrderNotification() async {
    await NotificationService.sendOrderNotification();
  }

  /// Refresh the enabled state from the server.
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final enabled = await NotificationService.isNotificationEnabled();
      state = AsyncData(enabled);
    } catch (e) {
      debugPrint('NotificationNotifier.refresh error: $e');
      state = const AsyncData(false);
    }
  }
}

final notificationEnabledProvider =
    AsyncNotifierProvider<NotificationNotifier, bool>(NotificationNotifier.new);
