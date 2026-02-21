import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    _initialized = true;
  }

  Future<void> scheduleExpiryNotifications(Item item) async {
    await cancelNotifications(item.id);

    final now = DateTime.now();
    final expiryDate = DateTime(
      item.expiryDate.year,
      item.expiryDate.month,
      item.expiryDate.day,
      9, 0, // 9:00 AM
    );

    // 3-day warning
    final threeDayBefore = expiryDate.subtract(const Duration(days: 3));
    if (threeDayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _generateNotificationId(item.id, 3),
        title: '⏰ ${item.name} expires in 3 days!',
        body: 'Use it before ${_formatDate(item.expiryDate)}.',
        scheduledDate: threeDayBefore,
      );
    }

    // 1-day warning
    final oneDayBefore = expiryDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _generateNotificationId(item.id, 1),
        title: '🚨 ${item.name} expires tomorrow!',
        body: 'Use it today to avoid waste.',
        scheduledDate: oneDayBefore,
      );
    }

    // Expiry day
    if (expiryDate.isAfter(now)) {
      await _scheduleNotification(
        id: _generateNotificationId(item.id, 0),
        title: '❌ ${item.name} has expired!',
        body: 'Check if it\'s still usable.',
        scheduledDate: expiryDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Alerts',
      channelDescription: 'Notifications for expiring items',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    final tzScheduleDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduleDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelNotifications(String itemId) async {
    await _notifications.cancel(_generateNotificationId(itemId, 3));
    await _notifications.cancel(_generateNotificationId(itemId, 1));
    await _notifications.cancel(_generateNotificationId(itemId, 0));
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  int _generateNotificationId(String itemId, int daysBefore) {
    return '${itemId}_$daysBefore'.hashCode.abs() % 2147483647;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
