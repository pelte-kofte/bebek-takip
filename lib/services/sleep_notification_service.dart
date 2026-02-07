import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level background handler for when the app is killed.
/// Saves activity data directly to SharedPreferences and clears timer state.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) async {
  final actionId = response.actionId;
  if (actionId == null || actionId.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final activeBabyId = prefs.getString('active_baby_id') ?? '';
  final notifications = FlutterLocalNotificationsPlugin();

  if (actionId == 'STOP_SLEEP_TIMER') {
    final uykuStr = prefs.getString('active_uyku_start');
    if (uykuStr != null && uykuStr.isNotEmpty) {
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
          'babyId': activeBabyId,
        });
        await prefs.setString('uyku_kayitlari', jsonEncode(records));
      }
      await prefs.remove('active_uyku_start');
    }
    await notifications.cancel(SleepNotificationService._sleepNotificationId);
  } else if (actionId == 'STOP_NURSING_TIMER') {
    final startStr = prefs.getString('active_emzirme_ilk_start');
    if (startStr != null && startStr.isNotEmpty) {
      final emzirmeStart = prefs.getString('active_emzirme_start');
      final taraf = prefs.getString('active_emzirme_taraf');
      int solSaniye = prefs.getInt('active_emzirme_sol_saniye') ?? 0;
      int sagSaniye = prefs.getInt('active_emzirme_sag_saniye') ?? 0;

      if (emzirmeStart != null) {
        final segmentStart = DateTime.parse(emzirmeStart);
        final segmentSeconds =
            DateTime.now().difference(segmentStart).inSeconds;
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
          'babyId': activeBabyId,
        });
        await prefs.setString('mama_kayitlari', jsonEncode(records));
      }
    }
    await prefs.remove('active_emzirme_start');
    await prefs.remove('active_emzirme_ilk_start');
    await prefs.remove('active_emzirme_tur');
    await prefs.remove('active_emzirme_taraf');
    await prefs.remove('active_emzirme_sol_saniye');
    await prefs.remove('active_emzirme_sag_saniye');
    await notifications.cancel(SleepNotificationService._nursingNotificationId);
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

  Timer? _sleepUpdateTimer;
  DateTime? _sleepStartTime;

  Timer? _nursingUpdateTimer;
  DateTime? _nursingStartTime;
  String? _nursingTaraf;

  /// Foreground action callback — set by TimerYonetici
  static Function(String actionId)? onActionReceived;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
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
    if (actionId == null || actionId.isEmpty) return;
    onActionReceived?.call(actionId);
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);
  }

  // ============ SLEEP NOTIFICATION ============

  Future<void> showSleepNotification(DateTime startTime) async {
    _sleepStartTime = startTime;
    await _updateSleepNotification();
    _sleepUpdateTimer?.cancel();
    _sleepUpdateTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _updateSleepNotification();
    });
  }

  Future<void> _updateSleepNotification() async {
    if (_sleepStartTime == null) return;

    final elapsed = DateTime.now().difference(_sleepStartTime!);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final timeString = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}'
        : '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    final androidDetails = AndroidNotificationDetails(
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
      actions: const [
        AndroidNotificationAction(
          'STOP_SLEEP_TIMER',
          'Durdur',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'SLEEP_TIMER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _sleepNotificationId,
      'Uyku devam ediyor',
      'Geçen süre: $timeString',
      details,
    );
  }

  Future<void> cancelSleepNotification() async {
    _sleepUpdateTimer?.cancel();
    _sleepUpdateTimer = null;
    _sleepStartTime = null;
    await _notifications.cancel(_sleepNotificationId);
  }

  // ============ NURSING NOTIFICATION ============

  Future<void> showNursingNotification(DateTime startTime, String? taraf) async {
    _nursingStartTime = startTime;
    _nursingTaraf = taraf;
    await _updateNursingNotification();
    _nursingUpdateTimer?.cancel();
    _nursingUpdateTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _updateNursingNotification();
    });
  }

  Future<void> updateNursingSide(String? taraf) async {
    _nursingTaraf = taraf;
    await _updateNursingNotification();
  }

  Future<void> _updateNursingNotification() async {
    if (_nursingStartTime == null) return;

    final elapsed = DateTime.now().difference(_nursingStartTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final sideText = _nursingTaraf != null
        ? ' (${_nursingTaraf == 'sol' ? 'Sol' : 'Sağ'})'
        : '';

    final androidDetails = AndroidNotificationDetails(
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
      actions: const [
        AndroidNotificationAction(
          'STOP_NURSING_TIMER',
          'Durdur',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'NURSING_TIMER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _nursingNotificationId,
      'Emzirme devam ediyor$sideText',
      'Geçen süre: $timeString',
      details,
    );
  }

  Future<void> cancelNursingNotification() async {
    _nursingUpdateTimer?.cancel();
    _nursingUpdateTimer = null;
    _nursingStartTime = null;
    _nursingTaraf = null;
    await _notifications.cancel(_nursingNotificationId);
  }

  // ============ DISPOSE ============

  void dispose() {
    _sleepUpdateTimer?.cancel();
    _nursingUpdateTimer?.cancel();
  }
}
