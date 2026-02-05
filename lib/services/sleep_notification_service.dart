import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SleepNotificationService {
  static final SleepNotificationService _instance =
      SleepNotificationService._internal();
  factory SleepNotificationService() => _instance;
  SleepNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _sleepNotificationId = 1001;
  Timer? _updateTimer;
  DateTime? _sleepStartTime;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    // Request Android notification permissions (Android 13+)
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);
  }

  Future<void> showSleepNotification(DateTime startTime) async {
    _sleepStartTime = startTime;

    // Show initial notification
    await _updateNotification();

    // Update notification every second
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNotification();
    });
  }

  Future<void> _updateNotification() async {
    if (_sleepStartTime == null) return;

    final elapsed = DateTime.now().difference(_sleepStartTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    const androidDetails = AndroidNotificationDetails(
      'sleep_timer_channel',
      'Uyku Zamanlayıcı',
      channelDescription: 'Uyku zamanlayıcı bildirimleri',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _sleepNotificationId,
      '💤 Uyku devam ediyor',
      'Geçen süre: $timeString',
      details,
    );
  }

  Future<void> cancelSleepNotification() async {
    _updateTimer?.cancel();
    _updateTimer = null;
    _sleepStartTime = null;
    await _notifications.cancel(_sleepNotificationId);
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}
