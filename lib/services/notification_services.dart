import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> requestPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'codealert_test',
      'CodeAlert Test',
      channelDescription: 'Test notifications for CodeAlert',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1,
      'CodeAlert',
      'Notification system is working!',
      details,
    );
  }

  static int notificationId(String reminderId) {
    return reminderId.hashCode & 0x7fffffff;
  }

  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> requestExactAlarmsPermission() async {
    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleReminder({
    required int id,
    required String contestName,
    required DateTime reminderTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      reminderTime,
      tz.local,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'contest_reminders',
        'Contest Reminders',
        channelDescription: 'Notifications for upcoming coding contests',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      'Contest Reminder',
      '$contestName is starting soon!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}