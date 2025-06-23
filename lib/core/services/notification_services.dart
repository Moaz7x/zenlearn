import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> cancilAllNotifications() async {
    await notificationPlugin.cancelAll();
  }
  
  Future<void> cancilAllNotification(int id) async {
    await notificationPlugin.cancel(id);
  }

  // init
  Future<void> initNotification() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    const initializeAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializeIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettengs = InitializationSettings(
      android: initializeAndroid,
      iOS: initializeIOS,
    );
    await notificationPlugin.initialize(initSettengs);
  }

  // setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('reminder_channel', 'Reminders',
            importance: Importance.max,
            priority: Priority.high,
            colorized: true,
            subText: 'subText',
            tag: 'tag',
            // ticker: 'ticker',
            // ledColor: Color.fromARGB(0, 48, 151, 216),

            color: Color.fromARGB(0, 48, 151, 216)));
  }

  //show
  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    notificationPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> showScheduledNotification({
  int id = 1,
  required String title,
  required String body,
  required int hour,
  required int minute,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
    0,0,0

  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  await notificationPlugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    notificationDetails(),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}


  // on tap
}
