import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    tz_data.initializeTimeZones();
    
    String timeZoneName = 'UTC';
    try {
      final dynamic timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = timeZoneInfo.toString();
      // Handle different platform implementations returning complex objects
      if (timeZoneName.startsWith('TimezoneInfo(')) {
        timeZoneName = timeZoneName.split(',')[0].replaceAll('TimezoneInfo(', '').trim();
      }
    } catch (e) {
      debugPrint("Error getting timezone: $e");
    }
    
    try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint("📍 Local Timezone Set: $timeZoneName");
    } catch (e) {
        debugPrint("Error setting location '$timeZoneName': $e");
        tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS Initialization (darwin)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint("Local Notification Tapped: ${response.payload}");
        _handleNotificationTap(response.payload);
      },
    );

    // Request Permissions
    await requestPermissions();

    // Initialize Firebase
    await _initializeFirebaseMessaging();
    
    // Setup Interacted Messages (FCM)
    await _setupInteractedMessage();
  }

  void _handleNotificationTap(String? payload) {
    // Navigate to specific screen if needed
  }

  Future<void> _setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
     debugPrint("Remote Notification Tapped: ${message.messageId}");
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Subscribe to general topic
      await messaging.subscribeToTopic('all_plumbers'); // Plumbers = Ben 10 Fans
      
      if (kDebugMode) {
        String? token = await messaging.getToken();
        print("🔥 FCM TOKEN: $token");
      }
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          _showRemoteNotification(message);
        }
      });
    }
  }

  Future<void> _showRemoteNotification(RemoteMessage message) async {
     const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ben10_remote', 
      'News & Updates', 
      channelDescription: 'Notifications from the Plumber Headquarters',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }


  Future<void> scheduleDailyReminders() async {
    await _scheduleDaily(100, "It's Hero Time! ⌚", "The universe needs saving! Start your training now. 🚀", 8, 0);
    await _scheduleDaily(101, "Omnitrix Recharged! 🔋", "Your battery is full. Come test your alien knowledge! 🧠", 13, 0);
    await _scheduleDaily(102, "Vilgax is Approaching! 🦑", "Don't let the villains win. Claim your daily rewards! 🔥", 18, 0);
    await _scheduleDaily(103, "Night Patrol 🌙", "One last mission before bed? Keep your knowledge sharp! 💤", 21, 0);

    // Verify scheduling (Added back for verification)
    final pending = await _localNotifications.pendingNotificationRequests();
    debugPrint("📅 Total Pending Notifications: ${pending.length}");
    for (var p in pending) {
      debugPrint("   ✅ Scheduled: #${p.id} '${p.title}'");
    }
  }

  // Exposed for testing if needed
  Future<void> showInstantNotification({String title = 'Test Notification 🔔', String body = 'If you see this, the Omnitrix is functioning perfectly! 🚀'}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ben10_test',
      'Test Channel',
      channelDescription: 'For testing notifications',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'test_payload',
    );
  }

  Future<void> _scheduleDaily(int id, String title, String body, int hour, int minute) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);
    debugPrint("⏰ Scheduling '$title' for: $scheduledTime (Local)");

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ben10_daily',
          'Daily Reminders',
          channelDescription: 'Reminds you to play Ben 10 Trivia',
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
