import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    tz.initializeTimeZones();
  }

  void onSelectNotification(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('Notification tapped with payload: $payload');
  }

  (String, String) getNotificationContent(int index) {
    final message = kRawNotificationMessages[index];
    return (message['title'] ?? '', message['body'] ?? '');
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required tz.TZDateTime time,
  }) async {
    // final now = tz.TZDateTime.now(tz.local);
    // final nextHour = now.add(Duration(hours: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      time,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '',
    );
  }

  Future<void> scheduleHourlyNotification({required Duration interval}) async {
    final (title, body) = getNotificationContent(Random().nextInt(10));

    await flutterLocalNotificationsPlugin.periodicallyShowWithDuration(
      100,
      title,
      body,
      interval,
      _notificationDetails(),
    );
  }

  Future<void> scheduleDailyNotification(DateTime selectedTime) async {
    if (selectedTime.isBefore(DateTime.now())) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      selectedTime,
      tz.local,
    );

    try {
      final (title, body) = getNotificationContent(Random().nextInt(10));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        101,
        title,
        body,
        scheduledTime,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

void onDidReceiveLocalNotification(
  int id,
  String? title,
  String? body,
  String? payload,
) {
  // For iOS <= 9 (older versions)
  debugPrint('iOS Local Notification Received: $title - $body');
}

final kRawNotificationMessages = [
  {
    "title": "Time to Reflect",
    "body": "Take a moment to jot down your thoughts and feelings.",
  },
  {
    "title": "How Are You Feeling?",
    "body": "How are you feeling today? Log your mood now.",
  },
  {
    "title": "Journaling Reminder",
    "body": "Pause and reflect—your journal awaits.",
  },
  {
    "title": "Capture Your Mood",
    "body": "Help yourself understand your day better. Write now!",
  },
  {
    "title": "Don't Forget to Write",
    "body": "Don’t miss your daily journaling session.",
  },
  {
    "title": "Your Thoughts Matter",
    "body": "Express your emotions and stay connected with yourself.",
  },
  {
    "title": "Morning Journaling Time",
    "body": "Start your day with a quick journal entry.",
  },
  {
    "title": "Evening Reflection",
    "body": "Wind down and record your evening thoughts.",
  },
  {
    "title": "Share Your Day",
    "body": "Your journey to self-awareness continues—write now!",
  },
  {
    "title": "Track Your Emotions",
    "body": "Moments matter—capture what you're experiencing today.",
  },
];
