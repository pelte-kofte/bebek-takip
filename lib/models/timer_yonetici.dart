import 'dart:async';
import 'package:flutter/foundation.dart';
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
  final Map<String, DateTime> _lastStartTapByKey = {};
  final Map<String, DateTime> _lastStopTapByKey = {};
  final Set<String> _startBusyKeys = <String>{};
  final Set<String> _stopBusyKeys = <String>{};
  static const Duration _sameActionCooldown = Duration(milliseconds: 300);

  // ── Live Activity localized labels (injected by UI layer) ──
  String _liveSleepTitle = 'Sleep';
  String _liveSleepSubtitle = '';
  String _liveNursingTitle = 'Nursing';
  String _liveLeftLabel = 'Left';
  String _liveRightLabel = 'Right';
  String _liveLeftSubtitle = 'Left side';
  String _liveRightSubtitle = 'Right side';

  String _nursingSubtitleForSide(String side) {
    return side == 'sol' ? _liveLeftSubtitle : _liveRightSubtitle;
  }

  String _babyNameFor(String babyId) {
    final fallbackName = VeriYonetici.getBabyName();
    for (final baby in VeriYonetici.getBabies()) {
      if (baby.id == babyId) return baby.name;
    }
    return fallbackName;
  }

  void _logTransition(String message) {
    if (kDebugMode) {
      debugPrint('[TimerYonetici] $message');
    }
  }

  String _actionKey({
    required String action,
    required String timerType,
    required String babyId,
  }) {
    return '$action:$timerType:$babyId';
  }

  bool _shouldRejectSameAction({
    required String action,
    required String timerType,
    required String babyId,
  }) {
    final key = _actionKey(
      action: action,
      timerType: timerType,
      babyId: babyId,
    );
    final now = DateTime.now();
    final lastTapByKey = action == 'start'
        ? _lastStartTapByKey
        : _lastStopTapByKey;
    final busyKeys = action == 'start' ? _startBusyKeys : _stopBusyKeys;
    final lastTap = lastTapByKey[key];

    if (busyKeys.contains(key)) {
      return true;
    }
    if (lastTap != null && now.difference(lastTap) < _sameActionCooldown) {
      return true;
    }

    lastTapByKey[key] = now;
    busyKeys.add(key);
    return false;
  }

  void _clearActionBusy({
    required String action,
    required String timerType,
    required String babyId,
  }) {
    final key = _actionKey(
      action: action,
      timerType: timerType,
      babyId: babyId,
    );
    if (action == 'start') {
      _startBusyKeys.remove(key);
    } else {
      _stopBusyKeys.remove(key);
    }
  }

  Future<void> setLiveActivityLocalization({
    required String sleepTitle,
    String sleepSubtitle = '',
    required String nursingTitle,
    required String leftLabel,
    required String rightLabel,
    required String leftSubtitle,
    required String rightSubtitle,
  }) async {
    _liveSleepTitle = sleepTitle;
    _liveSleepSubtitle = sleepSubtitle;
    _liveNursingTitle = nursingTitle;
    _liveLeftLabel = leftLabel;
    _liveRightLabel = rightLabel;
    _liveLeftSubtitle = leftSubtitle;
    _liveRightSubtitle = rightSubtitle;

    for (final babyId in _uykuStartByBaby.keys) {
      await _liveActivityService.updateSleepActivity(
        babyId: babyId,
        babyName: _babyNameFor(babyId),
        localizedTitle: _liveSleepTitle,
        localizedSubtitle: _liveSleepSubtitle,
      );
    }

    for (final entry in _emzirmeStartByBaby.entries) {
      final side = _emzirmeTarafByBaby[entry.key] ?? 'sol';
      await _liveActivityService.updateNursingSide(
        babyId: entry.key,
        babyName: _babyNameFor(entry.key),
        side: side,
        localizedTitle: _liveNursingTitle,
        localizedSubtitle: _nursingSubtitleForSide(side),
        localizedLeftLabel: _liveLeftLabel,
        localizedRightLabel: _liveRightLabel,
      );
    }
  }

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

            final ilkStr = _prefs?.getString(
              'active_emzirme_ilk_start_$babyId',
            );
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
      await _notificationService.showSleepNotification(
        _uykuStartByBaby[currentBabyId]!,
      );
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
        babyName: _babyNameFor(entry.key),
        startTime: entry.value,
        localizedTitle: _liveSleepTitle,
        localizedSubtitle: _liveSleepSubtitle,
      );
    }
    for (final entry in _emzirmeStartByBaby.entries) {
      final ilkStart = _emzirmeIlkStartByBaby[entry.key] ?? entry.value;
      final side = _emzirmeTarafByBaby[entry.key] ?? 'sol';
      await _liveActivityService.startNursingActivity(
        babyId: entry.key,
        babyName: _babyNameFor(entry.key),
        startTime: ilkStart,
        side: side,
        localizedTitle: _liveNursingTitle,
        localizedSubtitle: _nursingSubtitleForSide(side),
        localizedLeftLabel: _liveLeftLabel,
        localizedRightLabel: _liveRightLabel,
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
    await _liveActivityService.stopSleepActivity(
      babyId: babyId,
      localizedTitle: _liveSleepTitle,
      localizedSubtitle: _liveSleepSubtitle,
    );

    _uykuUpdateTimers[babyId]?.cancel();
    _uykuUpdateTimers.remove(babyId);
    _getUykuController(babyId).add(null);

    if (duration.inMinutes < 1) return;

    final kayitlar = VeriYonetici.getUykuKayitlari();
    kayitlar.insert(0, {'baslangic': start, 'bitis': bitis, 'sure': duration});
    await VeriYonetici.saveUykuKayitlari(kayitlar);
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
    await _liveActivityService.stopNursingActivity(
      babyId: babyId,
      localizedTitle: _liveNursingTitle,
      localizedSubtitle: _nursingSubtitleForSide(taraf ?? 'sol'),
      localizedLeftLabel: _liveLeftLabel,
      localizedRightLabel: _liveRightLabel,
    );

    _emzirmeUpdateTimers[babyId]?.cancel();
    _emzirmeUpdateTimers.remove(babyId);
    _getEmzirmeController(babyId).add(null);

    if (solSaniye == 0 && sagSaniye == 0) return;

    final solDakika = (solSaniye / 60).ceil();
    final sagDakika = (sagSaniye / 60).ceil();
    final kayitlar = VeriYonetici.getMamaKayitlari();
    kayitlar.insert(0, {
      'tarih': tarih,
      'tur': 'Anne Sütü',
      'solDakika': solDakika > 0 ? solDakika : (solSaniye > 0 ? 1 : 0),
      'sagDakika': sagDakika > 0 ? sagDakika : (sagSaniye > 0 ? 1 : 0),
      'miktar': 0,
      'kategori': 'Milk',
    });
    await VeriYonetici.saveMamaKayitlari(kayitlar);

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
      await _notificationService.showSleepNotification(
        _uykuStartByBaby[babyId]!,
      );
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

  Future<void> clearBabyTimerState(String babyId) async {
    if (babyId.isEmpty) return;

    if (_emzirmeStartByBaby.containsKey(babyId) ||
        _emzirmeIlkStartByBaby.containsKey(babyId) ||
        _solToplamByBaby.containsKey(babyId) ||
        _sagToplamByBaby.containsKey(babyId)) {
      await _clearEmzirme(babyId);
    } else {
      _emzirmeStartByBaby.remove(babyId);
      _emzirmeIlkStartByBaby.remove(babyId);
      _emzirmeTurByBaby.remove(babyId);
      _emzirmeTarafByBaby.remove(babyId);
      _solToplamByBaby.remove(babyId);
      _sagToplamByBaby.remove(babyId);
      _emzirmeUpdateTimers[babyId]?.cancel();
      _emzirmeUpdateTimers.remove(babyId);
      if (_emzirmeControllers.containsKey(babyId)) {
        _getEmzirmeController(babyId).add(null);
      }
      await _prefs?.remove('active_emzirme_start_$babyId');
      await _prefs?.remove('active_emzirme_ilk_start_$babyId');
      await _prefs?.remove('active_emzirme_tur_$babyId');
      await _prefs?.remove('active_emzirme_taraf_$babyId');
      await _prefs?.remove('active_emzirme_sol_saniye_$babyId');
      await _prefs?.remove('active_emzirme_sag_saniye_$babyId');
    }

    if (_uykuStartByBaby.containsKey(babyId)) {
      await _clearUyku(babyId);
    } else {
      _uykuStartByBaby.remove(babyId);
      _uykuUpdateTimers[babyId]?.cancel();
      _uykuUpdateTimers.remove(babyId);
      if (_uykuControllers.containsKey(babyId)) {
        _getUykuController(babyId).add(null);
      }
      await _prefs?.remove('active_uyku_start_$babyId');
    }
  }

  // ═══════════════════════════════════════════════════════
  //  EMZİRME (NURSING) — baby-scoped
  // ═══════════════════════════════════════════════════════

  Future<void> startEmzirme(
    String babyId, {
    String tur = 'anne',
    String? taraf,
  }) async {
    if (babyId.isEmpty) return;
    _logTransition(
      'start requested type=nursing babyId=$babyId side=${taraf ?? '-'}',
    );
    if (_shouldRejectSameAction(
      action: 'start',
      timerType: 'nursing',
      babyId: babyId,
    )) {
      _logTransition(
        'start rejected type=nursing babyId=$babyId reason=same_action_cooldown_or_busy',
      );
      return;
    }
    if (_emzirmeStartByBaby.containsKey(babyId)) {
      _logTransition(
        'start rejected type=nursing babyId=$babyId reason=already_running',
      );
      _clearActionBusy(action: 'start', timerType: 'nursing', babyId: babyId);
      return;
    }

    _logTransition('start accepted type=nursing babyId=$babyId');
    try {
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
        'active_emzirme_start_$babyId',
        now.toIso8601String(),
      );
      await _prefs?.setString(
        'active_emzirme_ilk_start_$babyId',
        now.toIso8601String(),
      );
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
        babyName: _babyNameFor(babyId),
        startTime: now,
        side: taraf ?? 'sol',
        localizedTitle: _liveNursingTitle,
        localizedSubtitle: _nursingSubtitleForSide(taraf ?? 'sol'),
        localizedLeftLabel: _liveLeftLabel,
        localizedRightLabel: _liveRightLabel,
      );
    } finally {
      _clearActionBusy(action: 'start', timerType: 'nursing', babyId: babyId);
    }
  }

  Future<void> switchEmzirmeSide(String babyId, String newTaraf) async {
    if (babyId.isEmpty) return;

    if (!_emzirmeStartByBaby.containsKey(babyId)) {
      // Not running, start new
      await startEmzirme(
        babyId,
        tur: _emzirmeTurByBaby[babyId] ?? 'anne',
        taraf: newTaraf,
      );
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
      'active_emzirme_start_$babyId',
      now.toIso8601String(),
    );
    await _prefs?.setString('active_emzirme_taraf_$babyId', newTaraf);
    await _prefs?.setInt(
      'active_emzirme_sol_saniye_$babyId',
      _solToplamByBaby[babyId] ?? 0,
    );
    await _prefs?.setInt(
      'active_emzirme_sag_saniye_$babyId',
      _sagToplamByBaby[babyId] ?? 0,
    );

    _startEmzirmeUpdateTimer(babyId);
    await _notificationService.updateNursingSide(newTaraf);
    await _liveActivityService.updateNursingSide(
      babyId: babyId,
      babyName: _babyNameFor(babyId),
      side: newTaraf,
      localizedTitle: _liveNursingTitle,
      localizedSubtitle: _nursingSubtitleForSide(newTaraf),
      localizedLeftLabel: _liveLeftLabel,
      localizedRightLabel: _liveRightLabel,
    );
  }

  Future<Map<String, dynamic>?> stopEmzirme(String babyId) async {
    if (babyId.isEmpty) return null;
    _logTransition('stop requested type=nursing babyId=$babyId');
    if (_shouldRejectSameAction(
      action: 'stop',
      timerType: 'nursing',
      babyId: babyId,
    )) {
      _logTransition(
        'stop rejected type=nursing babyId=$babyId reason=same_action_cooldown_or_busy',
      );
      return null;
    }

    try {
      final start = _emzirmeStartByBaby[babyId];
      final solTotal = _solToplamByBaby[babyId] ?? 0;
      final sagTotal = _sagToplamByBaby[babyId] ?? 0;

      if (start == null && solTotal == 0 && sagTotal == 0) {
        _logTransition(
          'stop rejected type=nursing babyId=$babyId reason=not_running',
        );
        return null;
      }

      _logTransition('stop accepted type=nursing babyId=$babyId');
      int solSaniye = solTotal;
      int sagSaniye = sagTotal;

      if (start != null) {
        final currentDuration = DateTime.now().difference(start);
        final taraf = _emzirmeTarafByBaby[babyId];
        if (kDebugMode) {
          debugPrint(
            '[TimerYonetici] nursing stop: taraf=$taraf elapsed=${currentDuration.inSeconds}s solTotal=$solTotal sagTotal=$sagTotal',
          );
        }
        if (taraf == 'sol') {
          solSaniye += currentDuration.inSeconds;
        } else if (taraf == 'sag') {
          sagSaniye += currentDuration.inSeconds;
        } else {
          // taraf is null or unexpected — elapsed seconds would be lost and both
          // sides would stay at 0, triggering the silent early-return guard in the
          // UI layer. Attribute elapsed to left side so the record is never dropped.
          if (kDebugMode) {
            debugPrint(
              '[TimerYonetici] WARNING: taraf=$taraf (null/unexpected), attributing ${currentDuration.inSeconds}s to sol',
            );
          }
          solSaniye += currentDuration.inSeconds;
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[TimerYonetici] nursing stop payload: solSaniye=$solSaniye sagSaniye=$sagSaniye',
        );
      }

      final data = {
        'tarih': _emzirmeIlkStartByBaby[babyId] ?? DateTime.now(),
        'bitis': DateTime.now(),
        'tur': _emzirmeTurByBaby[babyId] ?? 'anne',
        'solSaniye': solSaniye,
        'sagSaniye': sagSaniye,
      };

      try {
        await _clearEmzirme(babyId);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint(
            '[TimerYonetici] _clearEmzirme error (non-fatal): $e\n$st',
          );
        }
        // Ensure in-memory state is cleared even if async cleanup failed,
        // so the timer doesn't appear active on next build.
        _emzirmeStartByBaby.remove(babyId);
        _emzirmeIlkStartByBaby.remove(babyId);
        _emzirmeTurByBaby.remove(babyId);
        _emzirmeTarafByBaby.remove(babyId);
        _solToplamByBaby.remove(babyId);
        _sagToplamByBaby.remove(babyId);
        _emzirmeUpdateTimers[babyId]?.cancel();
        _emzirmeUpdateTimers.remove(babyId);
        final ctrl = _emzirmeControllers[babyId];
        if (ctrl != null && !ctrl.isClosed) ctrl.add(null);
      }

      return data;
    } finally {
      _clearActionBusy(action: 'stop', timerType: 'nursing', babyId: babyId);
    }
  }

  Future<void> _clearEmzirme(String babyId) async {
    final lastSide = _emzirmeTarafByBaby[babyId] ?? 'sol';

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
    await _liveActivityService.stopNursingActivity(
      babyId: babyId,
      localizedTitle: _liveNursingTitle,
      localizedSubtitle: _nursingSubtitleForSide(lastSide),
      localizedLeftLabel: _liveLeftLabel,
      localizedRightLabel: _liveRightLabel,
    );
  }

  // ═══════════════════════════════════════════════════════
  //  UYKU (SLEEP) — baby-scoped
  // ═══════════════════════════════════════════════════════

  Future<void> startUyku(String babyId) async {
    if (babyId.isEmpty) return;
    _logTransition('start requested type=sleep babyId=$babyId');
    if (_shouldRejectSameAction(
      action: 'start',
      timerType: 'sleep',
      babyId: babyId,
    )) {
      _logTransition(
        'start rejected type=sleep babyId=$babyId reason=same_action_cooldown_or_busy',
      );
      return;
    }
    if (_uykuStartByBaby.containsKey(babyId)) {
      _logTransition(
        'start rejected type=sleep babyId=$babyId reason=already_running',
      );
      _clearActionBusy(action: 'start', timerType: 'sleep', babyId: babyId);
      return;
    }
    _logTransition('start accepted type=sleep babyId=$babyId');
    try {
      final now = DateTime.now();
      _uykuStartByBaby[babyId] = now;

      await _prefs?.setString(
        'active_uyku_start_$babyId',
        now.toIso8601String(),
      );

      _startUykuUpdateTimer(babyId);
      await _notificationService.showSleepNotification(now);
      await _liveActivityService.startSleepActivity(
        babyId: babyId,
        babyName: _babyNameFor(babyId),
        startTime: now,
        localizedTitle: _liveSleepTitle,
        localizedSubtitle: _liveSleepSubtitle,
      );
    } finally {
      _clearActionBusy(action: 'start', timerType: 'sleep', babyId: babyId);
    }
  }

  Future<Map<String, dynamic>?> stopUyku(String babyId) async {
    if (babyId.isEmpty) return null;
    _logTransition('stop requested type=sleep babyId=$babyId');
    if (_shouldRejectSameAction(
      action: 'stop',
      timerType: 'sleep',
      babyId: babyId,
    )) {
      _logTransition(
        'stop rejected type=sleep babyId=$babyId reason=same_action_cooldown_or_busy',
      );
      return null;
    }
    try {
      final start = _uykuStartByBaby[babyId];
      if (start == null) {
        _logTransition(
          'stop rejected type=sleep babyId=$babyId reason=not_running',
        );
        return null;
      }
      _logTransition('stop accepted type=sleep babyId=$babyId');

      final bitis = DateTime.now();
      final sure = bitis.difference(start);

      if (kDebugMode) {
        debugPrint(
          '[TimerYonetici] sleep stop payload: elapsed=${sure.inSeconds}s',
        );
      }

      final data = {'baslangic': start, 'bitis': bitis, 'sure': sure};

      try {
        await _clearUyku(babyId);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[TimerYonetici] _clearUyku error (non-fatal): $e\n$st');
        }
        // Ensure in-memory state is cleared even if async cleanup failed.
        _uykuStartByBaby.remove(babyId);
        _uykuUpdateTimers[babyId]?.cancel();
        _uykuUpdateTimers.remove(babyId);
        final ctrl = _uykuControllers[babyId];
        if (ctrl != null && !ctrl.isClosed) ctrl.add(null);
      }

      return data;
    } finally {
      _clearActionBusy(action: 'stop', timerType: 'sleep', babyId: babyId);
    }
  }

  Future<void> _clearUyku(String babyId) async {
    _uykuStartByBaby.remove(babyId);

    await _prefs?.remove('active_uyku_start_$babyId');

    _uykuUpdateTimers[babyId]?.cancel();
    _uykuUpdateTimers.remove(babyId);
    _getUykuController(babyId).add(null);

    await _notificationService.cancelSleepNotification();
    await _liveActivityService.stopSleepActivity(
      babyId: babyId,
      localizedTitle: _liveSleepTitle,
      localizedSubtitle: _liveSleepSubtitle,
    );
  }

  // ═══════════════════════════════════════════════════════
  //  PERIODIC UPDATE TIMERS
  // ═══════════════════════════════════════════════════════

  void _startEmzirmeUpdateTimer(String babyId) {
    _emzirmeUpdateTimers[babyId]?.cancel();
    _emzirmeUpdateTimers[babyId] = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) {
      final start = _emzirmeStartByBaby[babyId];
      if (start != null) {
        _getEmzirmeController(babyId).add(DateTime.now().difference(start));
      }
    });
    // Initial emit
    final start = _emzirmeStartByBaby[babyId];
    if (start != null) {
      _getEmzirmeController(babyId).add(DateTime.now().difference(start));
    }
  }

  void _startUykuUpdateTimer(String babyId) {
    _uykuUpdateTimers[babyId]?.cancel();
    _uykuUpdateTimers[babyId] = Timer.periodic(const Duration(seconds: 1), (_) {
      final start = _uykuStartByBaby[babyId];
      if (start != null) {
        _getUykuController(babyId).add(DateTime.now().difference(start));
      }
    });
    // Initial emit
    final start = _uykuStartByBaby[babyId];
    if (start != null) {
      _getUykuController(babyId).add(DateTime.now().difference(start));
    }
  }

  // ═══════════════════════════════════════════════════════
  //  PUBLIC GETTERS — baby-scoped
  // ═══════════════════════════════════════════════════════

  bool isEmzirmeActiveFor(String babyId) =>
      _emzirmeStartByBaby.containsKey(babyId);

  bool isUykuActiveFor(String babyId) => _uykuStartByBaby.containsKey(babyId);

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

  DateTime? emzirmeBaslangicFor(String babyId) => _emzirmeStartByBaby[babyId];

  DateTime? uykuBaslangicFor(String babyId) => _uykuStartByBaby[babyId];

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

  String get _currentBabyId => _prefs?.getString('active_baby_id') ?? '';

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
