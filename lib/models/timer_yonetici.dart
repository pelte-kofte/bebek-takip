import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sleep_notification_service.dart';
import '../services/reminder_service.dart';
import '../services/live_activity_service.dart';
import 'veri_yonetici.dart';

/// Singleton class for managing baby-scoped timers.
/// Each baby has completely independent timer state.
class TimerYonetici {
  static final TimerYonetici _instance = TimerYonetici._internal();
  factory TimerYonetici() => _instance;
  TimerYonetici._internal();

  final SleepNotificationService _notificationService =
      SleepNotificationService();
  final LiveActivityService _liveActivityService = LiveActivityService();

  SharedPreferences? _prefs;

  // ── Per-baby timer state maps ──
  final Map<String, DateTime> _emzirmeStartByBaby = {};
  final Map<String, DateTime> _emzirmeIlkStartByBaby = {};
  final Map<String, String> _emzirmeTurByBaby = {};
  final Map<String, String> _emzirmeTarafByBaby = {};
  final Map<String, int> _solToplamByBaby = {};
  final Map<String, int> _sagToplamByBaby = {};

  final Map<String, DateTime> _uykuStartByBaby = {};

  // ── Per-baby stream controllers ──
  final Map<String, StreamController<Duration?>> _emzirmeControllers = {};
  final Map<String, StreamController<Duration?>> _uykuControllers = {};

  // ── Per-baby periodic timers ──
  final Map<String, Timer> _emzirmeUpdateTimers = {};
  final Map<String, Timer> _uykuUpdateTimers = {};

  // ── Stream accessors ──
  Stream<Duration?> emzirmeStreamFor(String babyId) =>
      _getEmzirmeController(babyId).stream;

  Stream<Duration?> uykuStreamFor(String babyId) =>
      _getUykuController(babyId).stream;

  StreamController<Duration?> _getEmzirmeController(String babyId) {
    if (!_emzirmeControllers.containsKey(babyId) ||
        _emzirmeControllers[babyId]!.isClosed) {
      _emzirmeControllers[babyId] = StreamController<Duration?>.broadcast();
    }
    return _emzirmeControllers[babyId]!;
  }

  StreamController<Duration?> _getUykuController(String babyId) {
    if (!_uykuControllers.containsKey(babyId) ||
        _uykuControllers[babyId]!.isClosed) {
      _uykuControllers[babyId] = StreamController<Duration?>.broadcast();
    }
    return _uykuControllers[babyId]!;
  }

  // ═══════════════════════════════════════════════════════
  //  INIT
  // ═══════════════════════════════════════════════════════

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    await _notificationService.initialize();
    await _notificationService.requestPermissions();

    SleepNotificationService.onActionReceived = _handleNotificationAction;

    // Load persisted timers for ALL babies that have active timers
    await _loadAllPersistedTimers();
  }

  /// Scan prefs for any active timers and load them into memory.
  Future<void> _loadAllPersistedTimers() async {
    final keys = _prefs?.getKeys() ?? {};

    // Find all babies with active uyku timers
    for (final key in keys) {
      if (key.startsWith('active_uyku_start_')) {
        final babyId = key.substring('active_uyku_start_'.length);
        final uykuStr = _prefs?.getString(key);
        if (uykuStr != null && uykuStr.isNotEmpty) {
          try {
            _uykuStartByBaby[babyId] = DateTime.parse(uykuStr);
            _startUykuUpdateTimer(babyId);
          } catch (_) {}
        }
      }
    }

    // Find all babies with active emzirme timers
    for (final key in keys) {
      if (key.startsWith('active_emzirme_start_')) {
        final babyId = key.substring('active_emzirme_start_'.length);
        final emzirmeStr = _prefs?.getString(key);
        if (emzirmeStr != null && emzirmeStr.isNotEmpty) {
          try {
            _emzirmeStartByBaby[babyId] = DateTime.parse(emzirmeStr);

            final ilkStr =
                _prefs?.getString('active_emzirme_ilk_start_$babyId');
            _emzirmeIlkStartByBaby[babyId] = ilkStr != null
                ? DateTime.parse(ilkStr)
                : _emzirmeStartByBaby[babyId]!;

            final tur = _prefs?.getString('active_emzirme_tur_$babyId');
            if (tur != null) _emzirmeTurByBaby[babyId] = tur;

            final taraf = _prefs?.getString('active_emzirme_taraf_$babyId');
            if (taraf != null) _emzirmeTarafByBaby[babyId] = taraf;

            _solToplamByBaby[babyId] =
                _prefs?.getInt('active_emzirme_sol_saniye_$babyId') ?? 0;
            _sagToplamByBaby[babyId] =
                _prefs?.getInt('active_emzirme_sag_saniye_$babyId') ?? 0;

            _startEmzirmeUpdateTimer(babyId);
          } catch (_) {}
        }
      }
    }

    // Show notification for the currently selected baby if they have active timers
    final currentBabyId = _prefs?.getString('active_baby_id') ?? '';
    if (_uykuStartByBaby.containsKey(currentBabyId)) {
      await _notificationService
          .showSleepNotification(_uykuStartByBaby[currentBabyId]!);
    }
    if (_emzirmeStartByBaby.containsKey(currentBabyId)) {
      await _notificationService.showNursingNotification(
        _emzirmeStartByBaby[currentBabyId]!,
        _emzirmeTarafByBaby[currentBabyId],
      );
    }

    // Restore live activities for all persisted timers
    for (final entry in _uykuStartByBaby.entries) {
      await _liveActivityService.startSleepActivity(
        babyId: entry.key,
        startTime: entry.value,
      );
    }
    for (final entry in _emzirmeStartByBaby.entries) {
      final ilkStart = _emzirmeIlkStartByBaby[entry.key] ?? entry.value;
      await _liveActivityService.startNursingActivity(
        babyId: entry.key,
        startTime: ilkStart,
        side: _emzirmeTarafByBaby[entry.key] ?? 'sol',
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  //  NOTIFICATION ACTION HANDLER
  // ═══════════════════════════════════════════════════════

  void _handleNotificationAction(String actionId) {
    // Notification actions apply to the currently selected baby
    final babyId = _prefs?.getString('active_baby_id') ?? '';
    if (babyId.isEmpty) return;

    if (actionId == 'STOP_SLEEP_TIMER') {
      _stopAndSaveUykuFromNotification(babyId);
    } else if (actionId == 'STOP_NURSING_TIMER') {
      _stopAndSaveEmzirmeFromNotification(babyId);
    }
  }

  Future<void> _stopAndSaveUykuFromNotification(String babyId) async {
    final start = _uykuStartByBaby[babyId];
    if (start == null) return;

    final bitis = DateTime.now();
    final duration = bitis.difference(start);

    // Clear state
    _uykuStartByBaby.remove(babyId);
    await _prefs?.remove('active_uyku_start_$babyId');
    await _notificationService.cancelSleepNotification();
    await _liveActivityService.stopSleepActivity(babyId: babyId);

    _uykuUpdateTimers[babyId]?.cancel();
    _uykuUpdateTimers.remove(babyId);
    _getUykuController(babyId).add(null);

    if (duration.inMinutes < 1) return;

    final allRecords = _prefs?.getString('uyku_kayitlari');
    List<dynamic> records = [];
    if (allRecords != null && allRecords.isNotEmpty) {
      try {
        records = jsonDecode(allRecords) as List;
      } catch (_) {}
    }
    records.insert(0, {
      'baslangic': start.toIso8601String(),
      'bitis': bitis.toIso8601String(),
      'sure': duration.inMinutes,
      'babyId': babyId,
    });
    await _prefs?.setString('uyku_kayitlari', jsonEncode(records));
  }

  Future<void> _stopAndSaveEmzirmeFromNotification(String babyId) async {
    final emzirmeStart = _emzirmeStartByBaby[babyId];
    if (emzirmeStart == null) return;

    final taraf = _emzirmeTarafByBaby[babyId];
    int solSaniye = _solToplamByBaby[babyId] ?? 0;
    int sagSaniye = _sagToplamByBaby[babyId] ?? 0;

    final currentDuration = DateTime.now().difference(emzirmeStart);
    if (taraf == 'sol') {
      solSaniye += currentDuration.inSeconds;
    } else if (taraf == 'sag') {
      sagSaniye += currentDuration.inSeconds;
    }

    final tarih = _emzirmeIlkStartByBaby[babyId] ?? DateTime.now();

    // Clear state
    _emzirmeStartByBaby.remove(babyId);
    _emzirmeIlkStartByBaby.remove(babyId);
    _emzirmeTurByBaby.remove(babyId);
    _emzirmeTarafByBaby.remove(babyId);
    _solToplamByBaby.remove(babyId);
    _sagToplamByBaby.remove(babyId);

    await _prefs?.remove('active_emzirme_start_$babyId');
    await _prefs?.remove('active_emzirme_ilk_start_$babyId');
    await _prefs?.remove('active_emzirme_tur_$babyId');
    await _prefs?.remove('active_emzirme_taraf_$babyId');
    await _prefs?.remove('active_emzirme_sol_saniye_$babyId');
    await _prefs?.remove('active_emzirme_sag_saniye_$babyId');
    await _notificationService.cancelNursingNotification();
    await _liveActivityService.stopNursingActivity(babyId: babyId);

    _emzirmeUpdateTimers[babyId]?.cancel();
    _emzirmeUpdateTimers.remove(babyId);
    _getEmzirmeController(babyId).add(null);

    if (solSaniye == 0 && sagSaniye == 0) return;

    final solDakika = (solSaniye / 60).ceil();
    final sagDakika = (sagSaniye / 60).ceil();

    final allRecords = _prefs?.getString('mama_kayitlari');
    List<dynamic> records = [];
    if (allRecords != null && allRecords.isNotEmpty) {
      try {
        records = jsonDecode(allRecords) as List;
      } catch (_) {}
    }
    records.insert(0, {
      'tarih': tarih.toIso8601String(),
      'tur': 'Anne Sütü',
      'solDakika': solDakika > 0 ? solDakika : (solSaniye > 0 ? 1 : 0),
      'sagDakika': sagDakika > 0 ? sagDakika : (sagSaniye > 0 ? 1 : 0),
      'miktar': 0,
      'kategori': 'Milk',
      'babyId': babyId,
    });
    await _prefs?.setString('mama_kayitlari', jsonEncode(records));

    if (VeriYonetici.isFeedingReminderEnabled()) {
      final reminderService = ReminderService();
      await reminderService.initialize();
      final now = DateTime.now();
      var scheduledAt = DateTime(
        now.year,
        now.month,
        now.day,
        VeriYonetici.getFeedingReminderHour(),
        VeriYonetici.getFeedingReminderMinute(),
      );
      if (scheduledAt.isBefore(now)) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      }
      await reminderService.scheduleFeedingReminderAt(scheduledAt);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  BABY SWITCH — update notifications only
  // ═══════════════════════════════════════════════════════

  /// Called when user switches babies. Does NOT stop any timers.
  /// Only updates notifications to show the new baby's timer status.
  Future<void> onActiveBabyChanged(String babyId) async {
    // Cancel old notifications, show new baby's if active
    if (_uykuStartByBaby.containsKey(babyId)) {
      await _notificationService
          .showSleepNotification(_uykuStartByBaby[babyId]!);
    } else {
      await _notificationService.cancelSleepNotification();
    }

    if (_emzirmeStartByBaby.containsKey(babyId)) {
      await _notificationService.showNursingNotification(
        _emzirmeStartByBaby[babyId]!,
        _emzirmeTarafByBaby[babyId],
      );
    } else {
      await _notificationService.cancelNursingNotification();
    }
  }

  // ═══════════════════════════════════════════════════════
  //  EMZİRME (NURSING) — baby-scoped
  // ═══════════════════════════════════════════════════════

  Future<void> startEmzirme(String babyId,
      {String tur = 'anne', String? taraf}) async {
    if (babyId.isEmpty) return;
    if (_emzirmeStartByBaby.containsKey(babyId)) return; // Already running

    final now = DateTime.now();
    _emzirmeStartByBaby[babyId] = now;
    _emzirmeIlkStartByBaby[babyId] = now;
    _emzirmeTurByBaby[babyId] = tur;
    if (taraf != null) {
      _emzirmeTarafByBaby[babyId] = taraf;
    }
    _solToplamByBaby[babyId] = 0;
    _sagToplamByBaby[babyId] = 0;

    await _prefs?.setString(
        'active_emzirme_start_$babyId', now.toIso8601String());
    await _prefs?.setString(
        'active_emzirme_ilk_start_$babyId', now.toIso8601String());
    await _prefs?.setString('active_emzirme_tur_$babyId', tur);
    if (taraf != null) {
      await _prefs?.setString('active_emzirme_taraf_$babyId', taraf);
    } else {
      await _prefs?.remove('active_emzirme_taraf_$babyId');
    }

    _startEmzirmeUpdateTimer(babyId);
    await _notificationService.showNursingNotification(now, taraf);
    await _liveActivityService.startNursingActivity(
      babyId: babyId,
      startTime: now,
      side: taraf ?? 'sol',
    );
  }

  Future<void> switchEmzirmeSide(String babyId, String newTaraf) async {
    if (babyId.isEmpty) return;

    if (!_emzirmeStartByBaby.containsKey(babyId)) {
      // Not running, start new
      await startEmzirme(babyId,
          tur: _emzirmeTurByBaby[babyId] ?? 'anne', taraf: newTaraf);
      return;
    }

    // Save current side's time
    final currentStart = _emzirmeStartByBaby[babyId]!;
    final currentDuration = DateTime.now().difference(currentStart);
    final currentTaraf = _emzirmeTarafByBaby[babyId];
    if (currentTaraf == 'sol') {
      _solToplamByBaby[babyId] =
          (_solToplamByBaby[babyId] ?? 0) + currentDuration.inSeconds;
    } else if (currentTaraf == 'sag') {
      _sagToplamByBaby[babyId] =
          (_sagToplamByBaby[babyId] ?? 0) + currentDuration.inSeconds;
    }

    // Start new side
    final now = DateTime.now();
    _emzirmeStartByBaby[babyId] = now;
    _emzirmeTarafByBaby[babyId] = newTaraf;

    await _prefs?.setString(
        'active_emzirme_start_$babyId', now.toIso8601String());
    await _prefs?.setString('active_emzirme_taraf_$babyId', newTaraf);
    await _prefs?.setInt(
        'active_emzirme_sol_saniye_$babyId', _solToplamByBaby[babyId] ?? 0);
    await _prefs?.setInt(
        'active_emzirme_sag_saniye_$babyId', _sagToplamByBaby[babyId] ?? 0);

    _startEmzirmeUpdateTimer(babyId);
    await _notificationService.updateNursingSide(newTaraf);
    await _liveActivityService.updateNursingSide(babyId: babyId, side: newTaraf);
  }

  Future<Map<String, dynamic>?> stopEmzirme(String babyId) async {
    if (babyId.isEmpty) return null;

    final start = _emzirmeStartByBaby[babyId];
    final solTotal = _solToplamByBaby[babyId] ?? 0;
    final sagTotal = _sagToplamByBaby[babyId] ?? 0;

    if (start == null && solTotal == 0 && sagTotal == 0) return null;

    int solSaniye = solTotal;
    int sagSaniye = sagTotal;

    if (start != null) {
      final currentDuration = DateTime.now().difference(start);
      final taraf = _emzirmeTarafByBaby[babyId];
      if (taraf == 'sol') {
        solSaniye += currentDuration.inSeconds;
      } else if (taraf == 'sag') {
        sagSaniye += currentDuration.inSeconds;
      }
    }

    final data = {
      'tarih': _emzirmeIlkStartByBaby[babyId] ?? DateTime.now(),
      'bitis': DateTime.now(),
      'tur': _emzirmeTurByBaby[babyId] ?? 'anne',
      'solSaniye': solSaniye,
      'sagSaniye': sagSaniye,
    };

    await _clearEmzirme(babyId);
    return data;
  }

  Future<void> _clearEmzirme(String babyId) async {
    _emzirmeStartByBaby.remove(babyId);
    _emzirmeIlkStartByBaby.remove(babyId);
    _emzirmeTurByBaby.remove(babyId);
    _emzirmeTarafByBaby.remove(babyId);
    _solToplamByBaby.remove(babyId);
    _sagToplamByBaby.remove(babyId);

    await _prefs?.remove('active_emzirme_start_$babyId');
    await _prefs?.remove('active_emzirme_ilk_start_$babyId');
    await _prefs?.remove('active_emzirme_tur_$babyId');
    await _prefs?.remove('active_emzirme_taraf_$babyId');
    await _prefs?.remove('active_emzirme_sol_saniye_$babyId');
    await _prefs?.remove('active_emzirme_sag_saniye_$babyId');

    _emzirmeUpdateTimers[babyId]?.cancel();
    _emzirmeUpdateTimers.remove(babyId);
    _getEmzirmeController(babyId).add(null);

    await _notificationService.cancelNursingNotification();
    await _liveActivityService.stopNursingActivity(babyId: babyId);
  }

  // ═══════════════════════════════════════════════════════
  //  UYKU (SLEEP) — baby-scoped
  // ═══════════════════════════════════════════════════════

  Future<void> startUyku(String babyId) async {
    if (babyId.isEmpty) return;
    if (_uykuStartByBaby.containsKey(babyId)) return; // Already running

    final now = DateTime.now();
    _uykuStartByBaby[babyId] = now;

    await _prefs?.setString(
        'active_uyku_start_$babyId', now.toIso8601String());

    _startUykuUpdateTimer(babyId);
    await _notificationService.showSleepNotification(now);
    await _liveActivityService.startSleepActivity(babyId: babyId, startTime: now);
  }

  Future<Map<String, dynamic>?> stopUyku(String babyId) async {
    if (babyId.isEmpty) return null;

    final start = _uykuStartByBaby[babyId];
    if (start == null) return null;

    final bitis = DateTime.now();
    final sure = bitis.difference(start);

    final data = {
      'baslangic': start,
      'bitis': bitis,
      'sure': sure,
    };

    await _clearUyku(babyId);
    return data;
  }

  Future<void> _clearUyku(String babyId) async {
    _uykuStartByBaby.remove(babyId);

    await _prefs?.remove('active_uyku_start_$babyId');

    _uykuUpdateTimers[babyId]?.cancel();
    _uykuUpdateTimers.remove(babyId);
    _getUykuController(babyId).add(null);

    await _notificationService.cancelSleepNotification();
    await _liveActivityService.stopSleepActivity(babyId: babyId);
  }

  // ═══════════════════════════════════════════════════════
  //  PERIODIC UPDATE TIMERS
  // ═══════════════════════════════════════════════════════

  void _startEmzirmeUpdateTimer(String babyId) {
    _emzirmeUpdateTimers[babyId]?.cancel();
    _emzirmeUpdateTimers[babyId] =
        Timer.periodic(const Duration(seconds: 1), (_) {
      final start = _emzirmeStartByBaby[babyId];
      if (start != null) {
        _getEmzirmeController(babyId)
            .add(DateTime.now().difference(start));
      }
    });
    // Initial emit
    final start = _emzirmeStartByBaby[babyId];
    if (start != null) {
      _getEmzirmeController(babyId)
          .add(DateTime.now().difference(start));
    }
  }

  void _startUykuUpdateTimer(String babyId) {
    _uykuUpdateTimers[babyId]?.cancel();
    _uykuUpdateTimers[babyId] =
        Timer.periodic(const Duration(seconds: 1), (_) {
      final start = _uykuStartByBaby[babyId];
      if (start != null) {
        _getUykuController(babyId)
            .add(DateTime.now().difference(start));
      }
    });
    // Initial emit
    final start = _uykuStartByBaby[babyId];
    if (start != null) {
      _getUykuController(babyId)
          .add(DateTime.now().difference(start));
    }
  }

  // ═══════════════════════════════════════════════════════
  //  PUBLIC GETTERS — baby-scoped
  // ═══════════════════════════════════════════════════════

  bool isEmzirmeActiveFor(String babyId) =>
      _emzirmeStartByBaby.containsKey(babyId);

  bool isUykuActiveFor(String babyId) =>
      _uykuStartByBaby.containsKey(babyId);

  Duration? emzirmeElapsedFor(String babyId) {
    final start = _emzirmeStartByBaby[babyId];
    if (start == null) return null;
    return DateTime.now().difference(start);
  }

  Duration? uykuElapsedFor(String babyId) {
    final start = _uykuStartByBaby[babyId];
    if (start == null) return null;
    return DateTime.now().difference(start);
  }

  DateTime? emzirmeBaslangicFor(String babyId) =>
      _emzirmeStartByBaby[babyId];

  DateTime? uykuBaslangicFor(String babyId) =>
      _uykuStartByBaby[babyId];

  String? emzirmeTurFor(String babyId) => _emzirmeTurByBaby[babyId];

  String? emzirmeTarafFor(String babyId) => _emzirmeTarafByBaby[babyId];

  int solToplamSaniyeFor(String babyId) {
    int total = _solToplamByBaby[babyId] ?? 0;
    final start = _emzirmeStartByBaby[babyId];
    if (start != null && _emzirmeTarafByBaby[babyId] == 'sol') {
      total += DateTime.now().difference(start).inSeconds;
    }
    return total;
  }

  int sagToplamSaniyeFor(String babyId) {
    int total = _sagToplamByBaby[babyId] ?? 0;
    final start = _emzirmeStartByBaby[babyId];
    if (start != null && _emzirmeTarafByBaby[babyId] == 'sag') {
      total += DateTime.now().difference(start).inSeconds;
    }
    return total;
  }

  // ═══════════════════════════════════════════════════════
  //  BACKWARD-COMPAT GETTERS (use active baby)
  // ═══════════════════════════════════════════════════════

  String get _currentBabyId =>
      _prefs?.getString('active_baby_id') ?? '';

  bool get isEmzirmeActive => isEmzirmeActiveFor(_currentBabyId);
  bool get isUykuActive => isUykuActiveFor(_currentBabyId);
  Duration? get emzirmeElapsed => emzirmeElapsedFor(_currentBabyId);
  Duration? get uykuElapsed => uykuElapsedFor(_currentBabyId);
  DateTime? get emzirmeBaslangic => emzirmeBaslangicFor(_currentBabyId);
  DateTime? get uykuBaslangic => uykuBaslangicFor(_currentBabyId);
  String? get aktifEmzirmeTuru => emzirmeTurFor(_currentBabyId);
  String? get emzirmeTaraf => emzirmeTarafFor(_currentBabyId);
  int get solToplamSaniye => solToplamSaniyeFor(_currentBabyId);
  int get sagToplamSaniye => sagToplamSaniyeFor(_currentBabyId);
  Stream<Duration?> get emzirmeStream => emzirmeStreamFor(_currentBabyId);
  Stream<Duration?> get uykuStream => uykuStreamFor(_currentBabyId);

  // ═══════════════════════════════════════════════════════
  //  DISPOSE
  // ═══════════════════════════════════════════════════════

  void dispose() {
    for (final t in _emzirmeUpdateTimers.values) {
      t.cancel();
    }
    for (final t in _uykuUpdateTimers.values) {
      t.cancel();
    }
    for (final c in _emzirmeControllers.values) {
      c.close();
    }
    for (final c in _uykuControllers.values) {
      c.close();
    }
    _notificationService.dispose();
  }
}
