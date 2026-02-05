import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _feedingReminderId = 2001;
  static const int _diaperReminderId = 2002;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      // Request Android notification permissions (Android 13+)
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != true) return false;
      }

      // Request iOS permissions
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        );
        if (granted != true) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Schedule a feeding reminder notification
  Future<void> scheduleFeedingReminder({
    required DateTime lastFeedingTime,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    // Cancel any existing feeding reminder
    await cancelFeedingReminder();

    final scheduledTime = lastFeedingTime.add(Duration(minutes: intervalMinutes));

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'feeding_reminder_channel',
      'Beslenme Hatırlatıcı',
      channelDescription: 'Beslenme hatırlatıcı bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _feedingReminderId,
      '🍼 Beslenme Hatırlatıcı',
      'Bebeğinizi besleme zamanı geldi',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule a diaper reminder notification
  Future<void> scheduleDiaperReminder({
    required DateTime lastDiaperTime,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    // Cancel any existing diaper reminder
    await cancelDiaperReminder();

    final scheduledTime = lastDiaperTime.add(Duration(minutes: intervalMinutes));

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'diaper_reminder_channel',
      'Bez Hatırlatıcı',
      channelDescription: 'Bez değişimi hatırlatıcı bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _diaperReminderId,
      '👶 Bez Hatırlatıcı',
      'Bebeğinizin bezini kontrol etme zamanı',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel feeding reminder
  Future<void> cancelFeedingReminder() async {
    await _notifications.cancel(_feedingReminderId);
  }

  /// Cancel diaper reminder
  Future<void> cancelDiaperReminder() async {
    await _notifications.cancel(_diaperReminderId);
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await cancelFeedingReminder();
    await cancelDiaperReminder();
  }
}
