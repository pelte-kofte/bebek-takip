import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'locale_service.dart';
import 'reminder_service.dart';

/// Top-level background handler for when the app is killed.
/// Saves activity data directly to SharedPreferences and clears timer state.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) async {
  final actionId = response.actionId;
  if (actionId == null || actionId.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final notifications = FlutterLocalNotificationsPlugin();

  if (actionId == 'STOP_SLEEP_TIMER') {
    final timerBabyId = prefs.getString('active_uyku_baby_id');
    final uykuStr = prefs.getString('active_uyku_start_$timerBabyId');
    if (uykuStr != null && uykuStr.isNotEmpty && timerBabyId != null) {
      final baslangic = DateTime.parse(uykuStr);
      final bitis = DateTime.now();
      final sure = bitis.difference(baslangic);

      if (sure.inMinutes >= 1) {
        final existing = prefs.getString('uyku_kayitlari');
        List<dynamic> records = [];
        if (existing != null && existing.isNotEmpty) {
          try {
            records = jsonDecode(existing) as List;
          } catch (_) {}
        }
        records.insert(0, {
          'baslangic': baslangic.toIso8601String(),
          'bitis': bitis.toIso8601String(),
          'sure': sure.inMinutes,
          'babyId': timerBabyId,
        });
        await prefs.setString('uyku_kayitlari', jsonEncode(records));
      }
      await prefs.remove('active_uyku_start_$timerBabyId');
      await prefs.remove('active_uyku_baby_id');
    }
    await notifications.cancel(SleepNotificationService._sleepNotificationId);
  } else if (actionId == 'STOP_NURSING_TIMER') {
    final timerBabyId = prefs.getString('active_emzirme_baby_id');
    final startStr = prefs.getString('active_emzirme_ilk_start_$timerBabyId');
    if (startStr != null && startStr.isNotEmpty && timerBabyId != null) {
      final emzirmeStart = prefs.getString('active_emzirme_start_$timerBabyId');
      final taraf = prefs.getString('active_emzirme_taraf_$timerBabyId');
      int solSaniye =
          prefs.getInt('active_emzirme_sol_saniye_$timerBabyId') ?? 0;
      int sagSaniye =
          prefs.getInt('active_emzirme_sag_saniye_$timerBabyId') ?? 0;

      if (emzirmeStart != null) {
        final segmentStart = DateTime.parse(emzirmeStart);
        final segmentSeconds = DateTime.now()
            .difference(segmentStart)
            .inSeconds;
        if (taraf == 'sol') {
          solSaniye += segmentSeconds;
        } else if (taraf == 'sag') {
          sagSaniye += segmentSeconds;
        }
      }

      if (solSaniye > 0 || sagSaniye > 0) {
        final solDakika = (solSaniye / 60).ceil();
        final sagDakika = (sagSaniye / 60).ceil();

        final existing = prefs.getString('mama_kayitlari');
        List<dynamic> records = [];
        if (existing != null && existing.isNotEmpty) {
          try {
            records = jsonDecode(existing) as List;
          } catch (_) {}
        }
        records.insert(0, {
          'tarih': DateTime.parse(startStr).toIso8601String(),
          'tur': 'Anne Sütü',
          'solDakika': solDakika > 0 ? solDakika : (solSaniye > 0 ? 1 : 0),
          'sagDakika': sagDakika > 0 ? sagDakika : (sagSaniye > 0 ? 1 : 0),
          'miktar': 0,
          'kategori': 'Milk',
          'babyId': timerBabyId,
        });
        await prefs.setString('mama_kayitlari', jsonEncode(records));
      }
    }
    await prefs.remove('active_emzirme_start_$timerBabyId');
    await prefs.remove('active_emzirme_ilk_start_$timerBabyId');
    await prefs.remove('active_emzirme_tur_$timerBabyId');
    await prefs.remove('active_emzirme_taraf_$timerBabyId');
    await prefs.remove('active_emzirme_sol_saniye_$timerBabyId');
    await prefs.remove('active_emzirme_sag_saniye_$timerBabyId');
    await prefs.remove('active_emzirme_baby_id');
    await notifications.cancel(SleepNotificationService._nursingNotificationId);
  }

  // ── Reminder actions (background) ──

  if (actionId == 'DONE_FEEDING') {
    await prefs.setBool('feeding_reminder_enabled', false);
    await notifications.cancel(ReminderService.feedingReminderId);
  } else if (actionId == 'DONE_DIAPER') {
    await prefs.setBool('diaper_reminder_enabled', false);
    await notifications.cancel(ReminderService.diaperReminderId);
  } else if (actionId == 'RESCHEDULE_FEEDING') {
    await notifications.cancel(ReminderService.feedingReminderId);
    ReminderService.initializeTimeZonesOnce();
    final reminderService = ReminderService();
    await reminderService.initialize();
    final hour = prefs.getInt('feeding_reminder_time_h') ?? 14;
    final minute = prefs.getInt('feeding_reminder_time_m') ?? 0;
    final now = DateTime.now();
    var scheduledAt = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledAt.isBefore(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }
    await reminderService.scheduleFeedingReminderAt(scheduledAt);
  } else if (actionId == 'RESCHEDULE_DIAPER') {
    await notifications.cancel(ReminderService.diaperReminderId);
    ReminderService.initializeTimeZonesOnce();
    final reminderService = ReminderService();
    await reminderService.initialize();
    final hour = prefs.getInt('diaper_reminder_time_h') ?? 14;
    final minute = prefs.getInt('diaper_reminder_time_m') ?? 0;
    final now = DateTime.now();
    var scheduledAt = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledAt.isBefore(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }
    await reminderService.scheduleDiaperReminderAt(scheduledAt);
  }
}

class SleepNotificationService {
  static final SleepNotificationService _instance =
      SleepNotificationService._internal();
  factory SleepNotificationService() => _instance;
  SleepNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _sleepNotificationId = 1001;
  static const int _nursingNotificationId = 1002;
  static const bool _iosPresentAlert = true;
  static const bool _iosPresentBadge = true;
  static const bool _iosPresentSound = true;
  static const String _iosSound = 'default';
  static const InterruptionLevel _iosInterruptionLevel =
      InterruptionLevel.active;

  bool _initialized = false;

  /// Foreground action callback — set by TimerYonetici
  static Function(String actionId)? onActionReceived;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'SLEEP_TIMER_CATEGORY',
          actions: [
            DarwinNotificationAction.plain('STOP_SLEEP_TIMER', 'Durdur'),
          ],
        ),
        DarwinNotificationCategory(
          'NURSING_TIMER_CATEGORY',
          actions: [
            DarwinNotificationAction.plain('STOP_NURSING_TIMER', 'Durdur'),
          ],
        ),
        DarwinNotificationCategory(
          'FEEDING_REMINDER_CATEGORY',
          actions: [
            DarwinNotificationAction.plain('DONE_FEEDING', 'Tamam'),
            DarwinNotificationAction.plain('RESCHEDULE_FEEDING', 'Tekrar Kur'),
          ],
        ),
        DarwinNotificationCategory(
          'DIAPER_REMINDER_CATEGORY',
          actions: [
            DarwinNotificationAction.plain('DONE_DIAPER', 'Tamam'),
            DarwinNotificationAction.plain('RESCHEDULE_DIAPER', 'Tekrar Kur'),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onForegroundNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
  }

  static void _onForegroundNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;

    // Plain tap (no action button) — auto-cancel if it's a reminder
    if (actionId == null || actionId.isEmpty) {
      final id = response.id;
      if (id == ReminderService.feedingReminderId ||
          id == ReminderService.diaperReminderId) {
        _handleReminderDone(id!);
      }
      return;
    }

    // Reminder action buttons
    switch (actionId) {
      case 'DONE_FEEDING':
        _handleReminderDone(ReminderService.feedingReminderId);
        return;
      case 'DONE_DIAPER':
        _handleReminderDone(ReminderService.diaperReminderId);
        return;
      case 'RESCHEDULE_FEEDING':
        _handleReminderReschedule(ReminderService.feedingReminderId);
        return;
      case 'RESCHEDULE_DIAPER':
        _handleReminderReschedule(ReminderService.diaperReminderId);
        return;
    }

    // Timer action buttons (STOP_SLEEP_TIMER, STOP_NURSING_TIMER)
    onActionReceived?.call(actionId);
  }

  /// Cancel a fired reminder and disable the toggle in prefs.
  static void _handleReminderDone(int notificationId) async {
    final notifications = FlutterLocalNotificationsPlugin();
    final prefs = await SharedPreferences.getInstance();
    await notifications.cancel(notificationId);
    if (notificationId == ReminderService.feedingReminderId) {
      await prefs.setBool('feeding_reminder_enabled', false);
    } else if (notificationId == ReminderService.diaperReminderId) {
      await prefs.setBool('diaper_reminder_enabled', false);
    }
  }

  /// Reschedule a reminder using the saved time from prefs.
  static void _handleReminderReschedule(int notificationId) async {
    final notifications = FlutterLocalNotificationsPlugin();
    final prefs = await SharedPreferences.getInstance();
    await notifications.cancel(notificationId);

    ReminderService.initializeTimeZonesOnce();
    final reminderService = ReminderService();
    await reminderService.initialize();

    final now = DateTime.now();

    if (notificationId == ReminderService.feedingReminderId) {
      final hour = prefs.getInt('feeding_reminder_time_h') ?? 14;
      final minute = prefs.getInt('feeding_reminder_time_m') ?? 0;
      var scheduledAt = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledAt.isBefore(now)) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      }
      await reminderService.scheduleFeedingReminderAt(scheduledAt);
    } else if (notificationId == ReminderService.diaperReminderId) {
      final hour = prefs.getInt('diaper_reminder_time_h') ?? 14;
      final minute = prefs.getInt('diaper_reminder_time_m') ?? 0;
      var scheduledAt = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledAt.isBefore(now)) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      }
      await reminderService.scheduleDiaperReminderAt(scheduledAt);
    }
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final iosResult = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (kDebugMode) {
      debugPrint(
        '[SleepNotificationService] iOS permission request '
        'alert=true badge=true sound=true granted=$iosResult',
      );
    }
  }

  // ============ SLEEP NOTIFICATION ============

  Future<void> showSleepNotification(DateTime startTime) async {
    final localized = await _loadNotificationLocalization();

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
      actions: [
        AndroidNotificationAction(
          'STOP_SLEEP_TIMER',
          'Durdur',
          showsUserInterface: true,
        ),
      ],
    );

    final iosDetails = _buildIosNotificationDetails(
      categoryIdentifier: 'SLEEP_TIMER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _logNotificationDebug(
      operation: 'show',
      id: _sleepNotificationId,
      localeCode: localized.localeCode,
      title: localized.l10n.notifSleepTitle,
      body: localized.l10n.notifSleepBody,
      details: iosDetails,
    );

    await _notifications.show(
      _sleepNotificationId,
      localized.l10n.notifSleepTitle,
      localized.l10n.notifSleepBody,
      details,
    );
    if (kDebugMode) {
      debugPrint(
        '[SleepNotificationService] showSleepNotification fired id=$_sleepNotificationId',
      );
    }
  }

  Future<void> cancelSleepNotification() async {
    await _notifications.cancel(_sleepNotificationId);
  }

  // ============ NURSING NOTIFICATION ============

  Future<void> showNursingNotification(
    DateTime startTime,
    String? taraf,
  ) async {
    final localized = await _loadNotificationLocalization();
    final sideLabel = _localizedSideLabel(taraf, localized.l10n);
    final title = sideLabel == null
        ? localized.l10n.notifNursingTitle
        : localized.l10n.notifNursingTitleWithSide(sideLabel);

    const androidDetails = AndroidNotificationDetails(
      'nursing_timer_channel',
      'Emzirme Zamanlayıcı',
      channelDescription: 'Emzirme zamanlayıcı bildirimleri',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'STOP_NURSING_TIMER',
          'Durdur',
          showsUserInterface: true,
        ),
      ],
    );

    final iosDetails = _buildIosNotificationDetails(
      categoryIdentifier: 'NURSING_TIMER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _logNotificationDebug(
      operation: 'show',
      id: _nursingNotificationId,
      localeCode: localized.localeCode,
      title: title,
      body: localized.l10n.notifNursingBody,
      details: iosDetails,
    );

    await _notifications.show(
      _nursingNotificationId,
      title,
      localized.l10n.notifNursingBody,
      details,
    );
    if (kDebugMode) {
      debugPrint(
        '[SleepNotificationService] showNursingNotification fired id=$_nursingNotificationId',
      );
    }
  }

  Future<void> updateNursingSide(String? taraf) async {
    final localized = await _loadNotificationLocalization();
    final sideLabel = _localizedSideLabel(taraf, localized.l10n);
    final title = sideLabel == null
        ? localized.l10n.notifNursingTitle
        : localized.l10n.notifNursingTitleWithSide(sideLabel);

    const androidDetails = AndroidNotificationDetails(
      'nursing_timer_channel',
      'Emzirme Zamanlayıcı',
      channelDescription: 'Emzirme zamanlayıcı bildirimleri',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'STOP_NURSING_TIMER',
          'Durdur',
          showsUserInterface: true,
        ),
      ],
    );

    final iosDetails = _buildIosNotificationDetails(
      categoryIdentifier: 'NURSING_TIMER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _logNotificationDebug(
      operation: 'show',
      id: _nursingNotificationId,
      localeCode: localized.localeCode,
      title: title,
      body: localized.l10n.notifNursingBody,
      details: iosDetails,
    );

    await _notifications.show(
      _nursingNotificationId,
      title,
      localized.l10n.notifNursingBody,
      details,
    );
  }

  Future<void> cancelNursingNotification() async {
    await _notifications.cancel(_nursingNotificationId);
  }

  // ============ DISPOSE ============

  void dispose() {
    // Nothing to dispose
  }

  Future<_NotificationLocalization> _loadNotificationLocalization() async {
    final localeCode = await LocaleService.getSavedLocaleCode();
    final locale = LocaleService.toLocale(localeCode);
    Intl.defaultLocale = localeCode == 'tr' ? 'tr_TR' : localeCode;
    final l10n = await AppLocalizations.delegate.load(locale);
    return _NotificationLocalization(localeCode: localeCode, l10n: l10n);
  }

  String? _localizedSideLabel(String? taraf, AppLocalizations l10n) {
    if (taraf == null || taraf.isEmpty) return null;
    if (taraf == 'sol') return l10n.left;
    if (taraf == 'sag') return l10n.right;
    return taraf;
  }

  DarwinNotificationDetails _buildIosNotificationDetails({
    required String categoryIdentifier,
  }) {
    return DarwinNotificationDetails(
      presentAlert: _iosPresentAlert,
      presentBadge: _iosPresentBadge,
      presentSound: _iosPresentSound,
      sound: _iosSound,
      presentBanner: true,
      presentList: true,
      interruptionLevel: _iosInterruptionLevel,
      categoryIdentifier: categoryIdentifier,
    );
  }

  void _logNotificationDebug({
    required String operation,
    required int id,
    required String localeCode,
    required String title,
    required String body,
    required DarwinNotificationDetails details,
  }) {
    debugPrint(
      '[SleepNotificationService][$operation] platform=$defaultTargetPlatform '
      'id=$id locale=$localeCode title="$title" body="$body" '
      'ios.presentAlert=${details.presentAlert} '
      'ios.presentBadge=${details.presentBadge} '
      'ios.presentSound=${details.presentSound} ios.sound=${details.sound} '
      'ios.interruption=${details.interruptionLevel}',
    );
  }
}

class _NotificationLocalization {
  final String localeCode;
  final AppLocalizations l10n;

  const _NotificationLocalization({
    required this.localeCode,
    required this.l10n,
  });
}
