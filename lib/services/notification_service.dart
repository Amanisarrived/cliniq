import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message: ${message.messageId}');
}

@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) {
  debugPrint('Background tap: ${response.payload}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final String timezoneName = _getDeviceTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    await _requestPermission();
    await _initFcm();

    _initialized = true;
    debugPrint('NotificationService initialized ✅');
  }

  // ─── FCM Setup ────────────────────────────────
  Future<void> _initFcm() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground: ${message.notification?.title}');
      _showFcmNotification(message);
    });

    // ✅ Token save karo
    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
    if (token != null) await _saveFcmToken(token);

    // ✅ Token refresh pe bhi save karo
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _saveFcmToken(newToken);
    });
  }

  // ─── Save FCM Token to Firestore ──────────────
  Future<void> _saveFcmToken(String token) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': token});
      debugPrint('FCM Token saved to Firestore ✅');
    } catch (e) {
      debugPrint('FCM Token save error: $e');
    }
  }

  // ─── Show FCM as Local Notification ──────────
  Future<void> _showFcmNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: _buildNotificationDetails(),
      payload: message.data['payload'],
    );
  }

  // ─── Get FCM Token ────────────────────────────
  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  String _getDeviceTimezone() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours;
      if (hours == 5) return 'Asia/Kolkata';
      final tzMap = {
        0: 'UTC',
        1: 'Europe/London',
        2: 'Europe/Paris',
        3: 'Asia/Riyadh',
        4: 'Asia/Dubai',
        5: 'Asia/Karachi',
        6: 'Asia/Dhaka',
        7: 'Asia/Bangkok',
        8: 'Asia/Shanghai',
        9: 'Asia/Tokyo',
        10: 'Australia/Sydney',
        -5: 'America/New_York',
        -6: 'America/Chicago',
        -7: 'America/Denver',
        -8: 'America/Los_Angeles',
      };
      return tzMap[hours] ?? 'Asia/Kolkata';
    } catch (_) {
      return 'Asia/Kolkata';
    }
  }

  Future<void> _requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleReminder(ReminderModel reminder) async {
    if (!_initialized) await initialize();
    if (!reminder.isActive || !reminder.hasAnyTime) return;

    await cancelReminder(reminder.id!);

    final details = _buildNotificationDetails(
      imagePath: reminder.imagePath,
    );

    if (reminder.isMorning) {
      await _scheduleDailyNotification(
        id: _getNotificationId(reminder.id!, 0),
        title: '💊 Medicine Time',
        body: 'Time to take ${reminder.medicineName}',
        time: reminder.morningTime,
        reminder: reminder,
        details: details,
      );
    }

    if (reminder.isAfternoon) {
      await _scheduleDailyNotification(
        id: _getNotificationId(reminder.id!, 1),
        title: '💊 Medicine Time',
        body: 'Time to take ${reminder.medicineName}',
        time: reminder.afternoonTime,
        reminder: reminder,
        details: details,
      );
    }

    if (reminder.isNight) {
      await _scheduleDailyNotification(
        id: _getNotificationId(reminder.id!, 2),
        title: '💊 Medicine Time',
        body: 'Time to take ${reminder.medicineName}',
        time: reminder.nightTime,
        reminder: reminder,
        details: details,
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required String time,
    required ReminderModel reminder,
    required NotificationDetails details,
  }) async {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      if (reminder.endDate != null) {
        final endDate = tz.TZDateTime.from(reminder.endDate!, tz.local);
        if (scheduledDate.isAfter(endDate)) return;
      }

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: reminder.id.toString(),
      );

      debugPrint('Scheduled $id at $time ✅');
    } catch (e) {
      debugPrint('Schedule error: $e');
    }
  }

  Future<void> scheduleTestNotification({
    required int id,
    required String medicineName,
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 10));

    await _plugin.zonedSchedule(
      id: id,
      title: '💊 Medicine Time!',
      body: 'Time to take $medicineName',
      scheduledDate: scheduledDate,
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: id.toString(),
    );

    debugPrint('Test notification — 10 sec mein ✅');
  }

  Future<void> cancelReminder(int reminderId) async {
    await _plugin.cancel(id: _getNotificationId(reminderId, 0));
    await _plugin.cancel(id: _getNotificationId(reminderId, 1));
    await _plugin.cancel(id: _getNotificationId(reminderId, 2));
  }

  Future<void> cancelAll() async => _plugin.cancelAll();

  NotificationDetails _buildNotificationDetails({String? imagePath}) {
    AndroidNotificationDetails androidDetails;

    if (imagePath != null) {
      final bigPicture = FilePathAndroidBitmap(imagePath);
      androidDetails = AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Medicine reminder notifications',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        visibility: NotificationVisibility.public,
        styleInformation: BigPictureStyleInformation(
          bigPicture,
          largeIcon: bigPicture,
          contentTitle: '💊 Medicine Time',
          hideExpandedLargeIcon: false,
        ),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Medicine reminder notifications',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        visibility: NotificationVisibility.public,
      );
    }

    return NotificationDetails(android: androidDetails);
  }

  int _getNotificationId(int reminderId, int timeSlot) =>
      reminderId * 10 + timeSlot;

  Future<void> showInstantNotification() async {
    if (!_initialized) await initialize();

    await _plugin.show(
      id: 888,
      title: '💊 Test!',
      body: 'Cliniq notification test',
      notificationDetails: _buildNotificationDetails(),
    );

    debugPrint('Instant notification shown ✅');
  }

  Future<void> debugSchedule() async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    debugPrint('Local timezone: ${tz.local.name}');
    debugPrint('Current TZ time: $now');
    debugPrint('Current device time: ${DateTime.now()}');

    final scheduledDate = now.add(const Duration(seconds: 20));
    debugPrint('Scheduling at: $scheduledDate');

    await _plugin.zonedSchedule(
      id: 777,
      title: '🔔 Debug Test',
      body: 'Scheduled at: $scheduledDate',
      scheduledDate: scheduledDate,
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: 'debug',
    );

    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('Pending notifications: ${pending.length}');
    for (final p in pending) {
      debugPrint('Pending: id=${p.id} title=${p.title}');
    }
  }

  Future<void> scheduleDiaryReminder() async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      21,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 9999,
      title: '📋 Sehat Diary',
      body: 'Aaj ka check-in pending hai!',
      scheduledDate: scheduledDate,
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'diary',
    );
  }

  Future<void> cancelDiaryReminder() async {
    await _plugin.cancel(id: 9999);
  }
}
