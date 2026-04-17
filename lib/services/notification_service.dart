import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import 'order_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _statusKey = 'order_status_cache';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'order_updates',
      'Order Updates',
      channelDescription: 'Notifications for order status changes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  /// Called on app resume — fetches fresh orders and fires a notification
  /// for each order whose status changed since the last check.
  static Future<void> checkOrderStatusChanges() async {
    try {
      final orders = await OrderService.getOrders();
      final prefs = await SharedPreferences.getInstance();

      // Load cached statuses
      final rawCache = prefs.getString(_statusKey);
      final Map<String, String> cache = rawCache != null
          ? Map<String, String>.from(jsonDecode(rawCache))
          : {};

      final Map<String, String> updatedCache = {};
      int notifId = 100; // start ID for order notifications

      for (final order in orders) {
        final shortId = order.id.substring(order.id.length - 6);
        final prevStatus = cache[order.id];
        final newStatus = order.status;

        updatedCache[order.id] = newStatus;

        if (prevStatus != null && prevStatus != newStatus) {
          final message = _statusMessage(newStatus, shortId);
          if (message != null) {
            await _show(
              id: notifId++,
              title: 'Order #$shortId Updated',
              body: message,
            );
          }
        }
      }

      await prefs.setString(_statusKey, jsonEncode(updatedCache));
    } catch (_) {
      // Silent — don't disrupt the user experience if this fails
    }
  }

  static String? _statusMessage(String status, String shortId) {
    switch (status) {
      case 'confirmed':
        return 'Your order #$shortId has been confirmed!';
      case 'shipped':
        return 'Your order #$shortId is on its way!';
      case 'delivered':
        return 'Your order #$shortId has been delivered. Enjoy!';
      case 'cancelled':
        return 'Your order #$shortId was cancelled.';
      default:
        return null;
    }
  }

  /// Seed the cache so first-run doesn't fire notifications for existing orders.
  static Future<void> seedCache(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_statusKey)) return;
    final map = {for (final o in orders) o.id: o.status};
    await prefs.setString(_statusKey, jsonEncode(map));
  }
}
