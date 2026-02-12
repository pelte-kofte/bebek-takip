import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  static bool _timeZonesInitialized = false;
  bool _permissionsRequested = false;
  bool _permissionsGranted = false;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _feedingReminderId = 2001;
  static const int _diaperReminderId = 2002;

  static const String _feedingTitleKey = 'feeding_reminder_title';
  static const String _feedingBodyKey = 'feeding_reminder_body';
  static const String _diaperTitleKey = 'diaper_reminder_title';
  static const String _diaperBodyKey = 'diaper_reminder_body';

  static const String _defaultFeedingTitle =
      '\u{1F37C} Beslenme Hat\u0131rlat\u0131c\u0131';
  static const String _defaultFeedingBody =
      'Bebe\u011Finizi besleme zaman\u0131 geldi';
  static const String _defaultDiaperTitle =
      '\u{1F476} Bez Hat\u0131rlat\u0131c\u0131';
  static const String _defaultDiaperBody =
      'Bebe\u011Finizin bezini kontrol etme zaman\u0131';

  bool _initialized = false;

  static void initializeTimeZonesOnce() {
    if (_timeZonesInitialized) return;
    tz_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    initializeTimeZonesOnce();
    await _ensureReminderStringsUtf8();
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (_permissionsRequested) return _permissionsGranted;
    _permissionsRequested = true;
    try {
      // Request Android notification permissions (Android 13+)
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != true) {
          _permissionsGranted = false;
          return false;
        }
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
        if (granted != true) {
          _permissionsGranted = false;
          return false;
        }
      }

      _permissionsGranted = true;
      return true;
    } catch (_) {
      _permissionsGranted = false;
      return false;
    }
  }

  /// Schedule a feeding reminder notification
  Future<void> scheduleFeedingReminder({
    required DateTime lastFeedingTime,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    await cancelFeedingReminder();
    final scheduledTime = lastFeedingTime.add(Duration(minutes: intervalMinutes));
    if (scheduledTime.isBefore(DateTime.now())) return;

    final content = await _readFeedingReminderContent();
    await _scheduleReminder(
      id: _feedingReminderId,
      title: content.title,
      body: content.body,
      scheduledAt: scheduledTime,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      androidChannelId: 'feeding_reminder_channel',
      androidChannelName: 'Beslenme Hat\u0131rlat\u0131c\u0131',
      androidChannelDescription: 'Beslenme hat\u0131rlat\u0131c\u0131 bildirimleri',
    );
  }

  /// Schedule a diaper reminder notification
  Future<void> scheduleDiaperReminder({
    required DateTime lastDiaperTime,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    await cancelDiaperReminder();
    final scheduledTime = lastDiaperTime.add(Duration(minutes: intervalMinutes));
    if (scheduledTime.isBefore(DateTime.now())) return;

    final content = await _readDiaperReminderContent();
    await _scheduleReminder(
      id: _diaperReminderId,
      title: content.title,
      body: content.body,
      scheduledAt: scheduledTime,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      androidChannelId: 'diaper_reminder_channel',
      androidChannelName: 'Bez Hat\u0131rlat\u0131c\u0131',
      androidChannelDescription:
          'Bez de\u011Fi\u015Fimi hat\u0131rlat\u0131c\u0131 bildirimleri',
    );
  }

  /// Schedule a feeding reminder notification at an exact time
  Future<void> scheduleFeedingReminderAt(DateTime scheduledAt) async {
    if (!_initialized) await initialize();

    await cancelFeedingReminder();
    if (scheduledAt.isBefore(DateTime.now())) return;

    final content = await _readFeedingReminderContent();
    await _scheduleReminder(
      id: _feedingReminderId,
      title: content.title,
      body: content.body,
      scheduledAt: scheduledAt,
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      androidChannelId: 'feeding_reminder_channel',
      androidChannelName: 'Beslenme Hat\u0131rlat\u0131c\u0131',
      androidChannelDescription: 'Beslenme hat\u0131rlat\u0131c\u0131 bildirimleri',
    );
  }

  /// Schedule a diaper reminder notification at an exact time
  Future<void> scheduleDiaperReminderAt(DateTime scheduledAt) async {
    if (!_initialized) await initialize();

    await cancelDiaperReminder();
    if (scheduledAt.isBefore(DateTime.now())) return;

    final content = await _readDiaperReminderContent();
    await _scheduleReminder(
      id: _diaperReminderId,
      title: content.title,
      body: content.body,
      scheduledAt: scheduledAt,
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      androidChannelId: 'diaper_reminder_channel',
      androidChannelName: 'Bez Hat\u0131rlat\u0131c\u0131',
      androidChannelDescription:
          'Bez de\u011Fi\u015Fimi hat\u0131rlat\u0131c\u0131 bildirimleri',
    );
  }

  Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required AndroidScheduleMode scheduleMode,
    required String androidChannelId,
    required String androidChannelName,
    required String androidChannelDescription,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      androidChannelId,
      androidChannelName,
      channelDescription: androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _ensureReminderStringsUtf8() async {
    final prefs = await SharedPreferences.getInstance();

    final feedingTitle =
        _sanitizeReminderText(prefs.getString(_feedingTitleKey), _defaultFeedingTitle);
    final feedingBody =
        _sanitizeReminderText(prefs.getString(_feedingBodyKey), _defaultFeedingBody);
    final diaperTitle =
        _sanitizeReminderText(prefs.getString(_diaperTitleKey), _defaultDiaperTitle);
    final diaperBody =
        _sanitizeReminderText(prefs.getString(_diaperBodyKey), _defaultDiaperBody);

    // Persist normalized strings to keep storage clean and consistent.
    await prefs.setString(_feedingTitleKey, feedingTitle);
    await prefs.setString(_feedingBodyKey, feedingBody);
    await prefs.setString(_diaperTitleKey, diaperTitle);
    await prefs.setString(_diaperBodyKey, diaperBody);
  }

  Future<_ReminderContent> _readFeedingReminderContent() async {
    final prefs = await SharedPreferences.getInstance();
    return _ReminderContent(
      title:
          _sanitizeReminderText(prefs.getString(_feedingTitleKey), _defaultFeedingTitle),
      body: _sanitizeReminderText(prefs.getString(_feedingBodyKey), _defaultFeedingBody),
    );
  }

  Future<_ReminderContent> _readDiaperReminderContent() async {
    final prefs = await SharedPreferences.getInstance();
    return _ReminderContent(
      title: _sanitizeReminderText(prefs.getString(_diaperTitleKey), _defaultDiaperTitle),
      body: _sanitizeReminderText(prefs.getString(_diaperBodyKey), _defaultDiaperBody),
    );
  }

  String _sanitizeReminderText(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    if (value.contains('\uFFFD') || value.contains('�')) return fallback;
    return value;
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

class _ReminderContent {
  final String title;
  final String body;

  const _ReminderContent({
    required this.title,
    required this.body,
  });
}
