import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import 'locale_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  static bool _timeZonesInitialized = false;
  bool _permissionsRequested = false;
  bool _permissionsGranted = false;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int feedingReminderId = 2001;
  static const int diaperReminderId = 2002;
  static const int medicationReminderBaseId = 30000;

  static const String _feedingTitleKey = 'feeding_reminder_title';
  static const String _feedingBodyKey = 'feeding_reminder_body';
  static const String _diaperTitleKey = 'diaper_reminder_title';
  static const String _diaperBodyKey = 'diaper_reminder_body';

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
            AndroidFlutterLocalNotificationsPlugin
          >();
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
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
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

  Future<bool> requestPermission() => requestPermissions();

  /// Schedule a feeding reminder notification
  Future<void> scheduleFeedingReminder({
    required DateTime lastFeedingTime,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    await cancelFeedingReminder();
    final scheduledTime = lastFeedingTime.add(
      Duration(minutes: intervalMinutes),
    );
    if (scheduledTime.isBefore(DateTime.now())) return;

    final content = await _readFeedingReminderContent();
    await _scheduleReminder(
      id: feedingReminderId,
      title: content.title,
      body: content.body,
      scheduledAt: scheduledTime,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      androidChannelId: 'feeding_reminder_channel',
      androidChannelName: 'Beslenme Hat\u0131rlat\u0131c\u0131',
      androidChannelDescription:
          'Beslenme hat\u0131rlat\u0131c\u0131 bildirimleri',
    );
  }

  /// Schedule a diaper reminder notification
  Future<void> scheduleDiaperReminder({
    required DateTime lastDiaperTime,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    await cancelDiaperReminder();
    final scheduledTime = lastDiaperTime.add(
      Duration(minutes: intervalMinutes),
    );
    if (scheduledTime.isBefore(DateTime.now())) return;

    final content = await _readDiaperReminderContent();
    await _scheduleReminder(
      id: diaperReminderId,
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
      id: feedingReminderId,
      title: content.title,
      body: content.body,
      scheduledAt: scheduledAt,
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      androidChannelId: 'feeding_reminder_channel',
      androidChannelName: 'Beslenme Hat\u0131rlat\u0131c\u0131',
      androidChannelDescription:
          'Beslenme hat\u0131rlat\u0131c\u0131 bildirimleri',
    );
  }

  /// Schedule a diaper reminder notification at an exact time
  Future<void> scheduleDiaperReminderAt(DateTime scheduledAt) async {
    if (!_initialized) await initialize();

    await cancelDiaperReminder();
    if (scheduledAt.isBefore(DateTime.now())) return;

    final content = await _readDiaperReminderContent();
    await _scheduleReminder(
      id: diaperReminderId,
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
    final isFeeding = id == feedingReminderId;
    final actionSuffix = isFeeding ? 'FEEDING' : 'DIAPER';

    final androidDetails = AndroidNotificationDetails(
      androidChannelId,
      androidChannelName,
      channelDescription: androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'DONE_$actionSuffix',
          'Tamam',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'RESCHEDULE_$actionSuffix',
          'Tekrar Kur',
          showsUserInterface: true,
        ),
      ],
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
      categoryIdentifier: isFeeding
          ? 'FEEDING_REMINDER_CATEGORY'
          : 'DIAPER_REMINDER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _logNotificationDebug(
      operation: 'zonedSchedule',
      localeCode: await _savedLocaleCode(),
      title: title,
      body: body,
      details: iosDetails,
    );

    // One-shot: no matchDateTimeComponents -> fires once, never repeats
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
    final l10n = await _loadLocalization();

    final feedingTitle = _sanitizeReminderText(
      prefs.getString(_feedingTitleKey),
      l10n.notifFeedingTitle,
    );
    final feedingBody = _sanitizeReminderText(
      prefs.getString(_feedingBodyKey),
      l10n.notifFeedingBody,
    );
    final diaperTitle = _sanitizeReminderText(
      prefs.getString(_diaperTitleKey),
      l10n.notifDiaperTitle,
    );
    final diaperBody = _sanitizeReminderText(
      prefs.getString(_diaperBodyKey),
      l10n.notifDiaperBody,
    );

    // Persist normalized strings to keep storage clean and consistent.
    await prefs.setString(_feedingTitleKey, feedingTitle);
    await prefs.setString(_feedingBodyKey, feedingBody);
    await prefs.setString(_diaperTitleKey, diaperTitle);
    await prefs.setString(_diaperBodyKey, diaperBody);
  }

  Future<_ReminderContent> _readFeedingReminderContent() async {
    final prefs = await SharedPreferences.getInstance();
    final l10n = await _loadLocalization();
    return _ReminderContent(
      title: _sanitizeReminderText(
        prefs.getString(_feedingTitleKey),
        l10n.notifFeedingTitle,
      ),
      body: _sanitizeReminderText(
        prefs.getString(_feedingBodyKey),
        l10n.notifFeedingBody,
      ),
    );
  }

  Future<_ReminderContent> _readDiaperReminderContent() async {
    final prefs = await SharedPreferences.getInstance();
    final l10n = await _loadLocalization();
    return _ReminderContent(
      title: _sanitizeReminderText(
        prefs.getString(_diaperTitleKey),
        l10n.notifDiaperTitle,
      ),
      body: _sanitizeReminderText(
        prefs.getString(_diaperBodyKey),
        l10n.notifDiaperBody,
      ),
    );
  }

  String _sanitizeReminderText(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    if (value.contains('\uFFFD') || value.contains('�')) return fallback;
    return value;
  }

  /// Cancel feeding reminder
  Future<void> cancelFeedingReminder() async {
    await _notifications.cancel(feedingReminderId);
  }

  /// Cancel diaper reminder
  Future<void> cancelDiaperReminder() async {
    await _notifications.cancel(diaperReminderId);
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await cancelFeedingReminder();
    await cancelDiaperReminder();
  }

  Future<void> scheduleMedicationReminderDaily({
    required int id,
    required String medicationName,
    String? dosage,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.cancel(id);

    final androidDetails = AndroidNotificationDetails(
      'medication_reminder_channel',
      'Medication Reminders',
      channelDescription: 'Medication reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (first.isBefore(now)) first = first.add(const Duration(days: 1));

    final localeCode = await _savedLocaleCode();
    final medContent = await _buildMedicationNotificationContent(
      medicationName: medicationName,
      dosage: dosage,
    );
    _logNotificationDebug(
      operation: 'zonedSchedule',
      localeCode: localeCode,
      title: medContent.title,
      body: medContent.body,
      details: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      medContent.title,
      medContent.body,
      tz.TZDateTime.from(first, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMedicationReminderAt({
    required int id,
    required String medicationName,
    String? dosage,
    required DateTime scheduledAt,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.cancel(id);
    if (scheduledAt.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'medication_reminder_channel',
      'Medication Reminders',
      channelDescription: 'Medication reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final localeCode = await _savedLocaleCode();
    final medContent = await _buildMedicationNotificationContent(
      medicationName: medicationName,
      dosage: dosage,
    );
    _logNotificationDebug(
      operation: 'zonedSchedule',
      localeCode: localeCode,
      title: medContent.title,
      body: medContent.body,
      details: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      medContent.title,
      medContent.body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelMedicationReminder(int id) async {
    await _notifications.cancel(id);
  }

  static int medicationReminderId({
    required String medicationId,
    required String slotKey,
  }) {
    final seed = 'med_${medicationId}_$slotKey'.hashCode.abs();
    return medicationReminderBaseId + (seed % 60000);
  }

  List<int> medicationReminderIdsFor(Map<String, dynamic> med) {
    final medId = (med['id'] ?? '').toString();
    if (medId.isEmpty) return const <int>[];

    final ids = <int>{};
    final scheduleType = (med['scheduleType'] as String?) ?? 'prn';

    if (scheduleType == 'daily') {
      final raw = med['dailyTimes'];
      final times = raw is List
          ? raw
                .map((e) => e?.toString() ?? '')
                .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
                .toList()
          : const <String>[];
      for (int i = 0; i < times.length; i++) {
        ids.add(
          medicationReminderId(
            medicationId: medId,
            slotKey: 'daily_${times[i]}_$i',
          ),
        );
      }
    }

    if (scheduleType == 'vaccine_protocol') {
      final vaccineId = (med['vaccineId'] ?? '').toString();
      final offsets = (med['protocolOffsets'] as List?) ?? const [];
      for (int i = 0; i < offsets.length; i++) {
        final item = Map<String, dynamic>.from(offsets[i] as Map);
        final kind = (item['kind'] as String?) == 'before' ? 'before' : 'after';
        final minutes = (item['minutes'] as num?)?.toInt() ?? 0;
        ids.add(
          medicationReminderId(
            medicationId: medId,
            slotKey: 'protocol_${vaccineId}_${kind}_${minutes}_$i',
          ),
        );
      }
    }

    return ids.toList()..sort();
  }

  Future<void> cancelMedicationReminders(
    String medId, {
    List<String>? dailyTimes,
    List<Map<String, dynamic>>? protocolOffsets,
    String? vaccineId,
  }) async {
    if (!_initialized) await initialize();
    final ids = <int>{};

    final normalizedTimes = (dailyTimes ?? const <String>[])
        .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
        .toList();
    for (int i = 0; i < normalizedTimes.length; i++) {
      ids.add(
        medicationReminderId(
          medicationId: medId,
          slotKey: 'daily_${normalizedTimes[i]}_$i',
        ),
      );
    }

    final offsets = protocolOffsets ?? const <Map<String, dynamic>>[];
    final vid = vaccineId ?? '';
    for (int i = 0; i < offsets.length; i++) {
      final item = Map<String, dynamic>.from(offsets[i]);
      final kind = (item['kind'] as String?) == 'before' ? 'before' : 'after';
      final minutes = (item['minutes'] as num?)?.toInt() ?? 0;
      ids.add(
        medicationReminderId(
          medicationId: medId,
          slotKey: 'protocol_${vid}_${kind}_${minutes}_$i',
        ),
      );
    }

    for (final id in ids) {
      await _notifications.cancel(id);
    }
  }

  Future<void> scheduleMedicationReminders(
    Map<String, dynamic> med, {
    DateTime? vaccineDate,
  }) async {
    if (!_initialized) await initialize();

    final medId = (med['id'] ?? '').toString();
    if (medId.isEmpty) return;

    final medicationName = (med['name'] ?? '').toString();
    final dosage = med['dosage']?.toString();

    final scheduleType = (med['scheduleType'] as String?) ?? 'prn';
    if (scheduleType == 'daily') {
      final raw = med['dailyTimes'];
      final times = raw is List
          ? raw
                .map((e) => e?.toString() ?? '')
                .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
                .toList()
          : const <String>[];
      for (int i = 0; i < times.length; i++) {
        final parts = times[i].split(':');
        final id = medicationReminderId(
          medicationId: medId,
          slotKey: 'daily_${times[i]}_$i',
        );
        await scheduleMedicationReminderDaily(
          id: id,
          medicationName: medicationName,
          dosage: dosage,
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
      return;
    }

    if (scheduleType != 'vaccine_protocol' || vaccineDate == null) return;
    final vaccineId = (med['vaccineId'] ?? '').toString();
    final offsets = (med['protocolOffsets'] as List?) ?? const [];
    for (int i = 0; i < offsets.length; i++) {
      final offset = Map<String, dynamic>.from(offsets[i] as Map);
      final kind = (offset['kind'] as String?) == 'before' ? 'before' : 'after';
      final minutes = (offset['minutes'] as num?)?.toInt() ?? 0;
      final scheduledAt = kind == 'before'
          ? vaccineDate.subtract(Duration(minutes: minutes))
          : vaccineDate.add(Duration(minutes: minutes));
      final id = medicationReminderId(
        medicationId: medId,
        slotKey: 'protocol_${vaccineId}_${kind}_${minutes}_$i',
      );
      await scheduleMedicationReminderAt(
        id: id,
        medicationName: medicationName,
        dosage: dosage,
        scheduledAt: scheduledAt,
      );
    }
  }

  Future<String> _savedLocaleCode() async {
    return LocaleService.getSavedLocaleCode();
  }

  Future<AppLocalizations> _loadLocalization() async {
    final code = await _savedLocaleCode();
    final locale = LocaleService.toLocale(code);
    Intl.defaultLocale = _intlLocaleName(code);
    return AppLocalizations.delegate.load(locale);
  }

  Future<_ReminderContent> _buildMedicationNotificationContent({
    required String medicationName,
    String? dosage,
  }) async {
    final l10n = await _loadLocalization();
    final localeCode = await _savedLocaleCode();

    final normalizedDose = _formatDoseByLocale(dosage, localeCode);
    final body = normalizedDose.isNotEmpty
        ? l10n.notifMedBody(normalizedDose, l10n.mlAbbrev)
        : l10n.notifGenericBody;

    return _ReminderContent(
      title: l10n.notifMedTitle(medicationName),
      body: body,
    );
  }

  String _formatDoseByLocale(String? rawDose, String localeCode) {
    final input = rawDose?.trim() ?? '';
    if (input.isEmpty) return '';

    final match = RegExp(
      r'^([0-9]+(?:[.,][0-9]+)?)(?:\s*([A-Za-z]+))?$',
    ).firstMatch(input);
    if (match == null) return input;

    final parsed = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (parsed == null) return input;

    final formatted = NumberFormat.decimalPattern(
      _intlLocaleName(localeCode),
    ).format(parsed);
    return formatted;
  }

  String _intlLocaleName(String code) {
    return code == 'tr' ? 'tr_TR' : code;
  }

  void _logNotificationDebug({
    required String operation,
    required String localeCode,
    required String title,
    required String body,
    required DarwinNotificationDetails details,
  }) {
    debugPrint(
      '[ReminderService][$operation] platform=$defaultTargetPlatform '
      'locale=$localeCode title="$title" body="$body" '
      'ios.presentSound=${details.presentSound} ios.sound=${details.sound}',
    );
  }
}

class _ReminderContent {
  final String title;
  final String body;

  const _ReminderContent({required this.title, required this.body});
}
