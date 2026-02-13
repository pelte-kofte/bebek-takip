import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sleep_notification_service.dart';
import '../services/reminder_service.dart';
import 'veri_yonetici.dart';

/// Singleton class for managing timers across screens
/// Persists timer state even when navigating between screens
class TimerYonetici {
  static final TimerYonetici _instance = TimerYonetici._internal();
  factory TimerYonetici() => _instance;
  TimerYonetici._internal();

  final SleepNotificationService _notificationService =
      SleepNotificationService();

  SharedPreferences? _prefs;

  // Timer states
  String? _activeBabyId; // Baby ID for active timers
  DateTime? _emzirmeBaslangic; // Current timer start time
  DateTime? _emzirmeIlkBaslangic; // First time emzirme started (for recording)
  DateTime? _uykuBaslangic;
  String? _aktifEmzirmeTuru; // 'anne' veya 'biberon'
  String? _emzirmeTaraf; // 'sol', 'sag', veya null
  int _solToplamSaniye = 0; // Total seconds for sol
  int _sagToplamSaniye = 0; // Total seconds for sag

  // Stream controllers for UI updates
  final _emzirmeController = StreamController<Duration?>.broadcast();
  final _uykuController = StreamController<Duration?>.broadcast();

  Stream<Duration?> get emzirmeStream => _emzirmeController.stream;
  Stream<Duration?> get uykuStream => _uykuController.stream;

  // Periodic timers for broadcasting updates
  Timer? _emzirmeUpdateTimer;
  Timer? _uykuUpdateTimer;

  /// Initialize the timer manager
  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    await _notificationService.initialize();
    await _notificationService.requestPermissions();

    // Register foreground notification action handler
    SleepNotificationService.onActionReceived = _handleNotificationAction;

    await _loadState();
  }

  /// Handle notification action button taps (foreground)
  void _handleNotificationAction(String actionId) {
    if (actionId == 'STOP_SLEEP_TIMER') {
      _stopAndSaveUykuFromNotification();
    } else if (actionId == 'STOP_NURSING_TIMER') {
      _stopAndSaveEmzirmeFromNotification();
    }
  }

  /// Stop sleep timer and save activity from notification action.
  /// Reads timer owner from prefs so it works even if user switched babies.
  Future<void> _stopAndSaveUykuFromNotification() async {
    final timerBabyId = _prefs?.getString('active_uyku_baby_id');
    if (timerBabyId == null || timerBabyId.isEmpty) return;

    final uykuStr = _prefs?.getString('active_uyku_start_$timerBabyId');
    if (uykuStr == null || uykuStr.isEmpty) return;

    final baslangic = DateTime.parse(uykuStr);
    final bitis = DateTime.now();
    final duration = bitis.difference(baslangic);

    // Clear prefs for this timer
    await _prefs?.remove('active_uyku_start_$timerBabyId');
    await _prefs?.remove('active_uyku_baby_id');
    await _notificationService.cancelSleepNotification();

    // If this baby is currently loaded in memory, clear in-memory state too
    if (_activeBabyId == timerBabyId) {
      _uykuBaslangic = null;
      if (_emzirmeBaslangic == null) _activeBabyId = null;
      _uykuUpdateTimer?.cancel();
      _uykuUpdateTimer = null;
      _uykuController.add(null);
    }

    if (duration.inMinutes < 1) return;

    // Load all records and insert with timer's baby ID
    final allRecords = _prefs?.getString('uyku_kayitlari');
    List<dynamic> records = [];
    if (allRecords != null && allRecords.isNotEmpty) {
      try {
        records = jsonDecode(allRecords) as List;
      } catch (_) {}
    }
    records.insert(0, {
      'baslangic': baslangic.toIso8601String(),
      'bitis': bitis.toIso8601String(),
      'sure': duration.inMinutes,
      'babyId': timerBabyId,
    });
    await _prefs?.setString('uyku_kayitlari', jsonEncode(records));
  }

  /// Stop nursing timer and save activity from notification action.
  /// Reads timer owner from prefs so it works even if user switched babies.
  Future<void> _stopAndSaveEmzirmeFromNotification() async {
    final timerBabyId = _prefs?.getString('active_emzirme_baby_id');
    if (timerBabyId == null || timerBabyId.isEmpty) return;

    final emzirmeStr = _prefs?.getString('active_emzirme_start_$timerBabyId');
    if (emzirmeStr == null || emzirmeStr.isEmpty) return;

    // Calculate side totals from prefs
    final emzirmeBaslangic = DateTime.parse(emzirmeStr);
    final taraf = _prefs?.getString('active_emzirme_taraf_$timerBabyId');
    int solSaniye = _prefs?.getInt('active_emzirme_sol_saniye_$timerBabyId') ?? 0;
    int sagSaniye = _prefs?.getInt('active_emzirme_sag_saniye_$timerBabyId') ?? 0;

    // Add current running time to active side
    final currentDuration = DateTime.now().difference(emzirmeBaslangic);
    if (taraf == 'sol') {
      solSaniye += currentDuration.inSeconds;
    } else if (taraf == 'sag') {
      sagSaniye += currentDuration.inSeconds;
    }

    final emzirmeIlkStr = _prefs?.getString('active_emzirme_ilk_start_$timerBabyId');
    final tarih = emzirmeIlkStr != null ? DateTime.parse(emzirmeIlkStr) : DateTime.now();

    // Clear prefs for this timer
    await _prefs?.remove('active_emzirme_start_$timerBabyId');
    await _prefs?.remove('active_emzirme_ilk_start_$timerBabyId');
    await _prefs?.remove('active_emzirme_tur_$timerBabyId');
    await _prefs?.remove('active_emzirme_taraf_$timerBabyId');
    await _prefs?.remove('active_emzirme_sol_saniye_$timerBabyId');
    await _prefs?.remove('active_emzirme_sag_saniye_$timerBabyId');
    await _prefs?.remove('active_emzirme_baby_id');
    await _notificationService.cancelNursingNotification();

    // If this baby is currently loaded in memory, clear in-memory state too
    if (_activeBabyId == timerBabyId) {
      _emzirmeBaslangic = null;
      _emzirmeIlkBaslangic = null;
      _aktifEmzirmeTuru = null;
      _emzirmeTaraf = null;
      _solToplamSaniye = 0;
      _sagToplamSaniye = 0;
      if (_uykuBaslangic == null) _activeBabyId = null;
      _emzirmeUpdateTimer?.cancel();
      _emzirmeUpdateTimer = null;
      _emzirmeController.add(null);
    }

    if (solSaniye == 0 && sagSaniye == 0) return;

    final solDakika = (solSaniye / 60).ceil();
    final sagDakika = (sagSaniye / 60).ceil();

    // Load all records and insert with timer's baby ID
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
      'babyId': timerBabyId,
    });
    await _prefs?.setString('mama_kayitlari', jsonEncode(records));

    // Schedule feeding reminder if enabled
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

  /// Called when user switches the active baby.
  /// Reloads timer state for the new baby and emits stream updates.
  Future<void> onActiveBabyChanged(String babyId) async {
    // Stop broadcasting old baby's timers
    _emzirmeUpdateTimer?.cancel();
    _emzirmeUpdateTimer = null;
    _uykuUpdateTimer?.cancel();
    _uykuUpdateTimer = null;

    await _loadStateForBaby(babyId);
  }

  /// Load saved timer states from preferences
  Future<void> _loadState() async {
    final currentBabyId = _prefs?.getString('active_baby_id') ?? '';
    await _loadStateForBaby(currentBabyId);
  }

  /// Load timer state for a specific baby from preferences
  Future<void> _loadStateForBaby(String babyId) async {
    // Reset in-memory state
    _activeBabyId = null;
    _emzirmeBaslangic = null;
    _emzirmeIlkBaslangic = null;
    _aktifEmzirmeTuru = null;
    _emzirmeTaraf = null;
    _solToplamSaniye = 0;
    _sagToplamSaniye = 0;
    _uykuBaslangic = null;

    // Load emzirme timer (scoped to baby)
    final emzirmeBabyId = _prefs?.getString('active_emzirme_baby_id');
    if (emzirmeBabyId == babyId) {
      final emzirmeStr = _prefs?.getString('active_emzirme_start_$babyId');
      final emzirmeIlkStr = _prefs?.getString('active_emzirme_ilk_start_$babyId');

      if (emzirmeStr != null && emzirmeStr.isNotEmpty) {
        try {
          _activeBabyId = babyId;
          _emzirmeBaslangic = DateTime.parse(emzirmeStr);
          _emzirmeIlkBaslangic = emzirmeIlkStr != null
              ? DateTime.parse(emzirmeIlkStr)
              : _emzirmeBaslangic;
          _aktifEmzirmeTuru = _prefs?.getString('active_emzirme_tur_$babyId');
          _emzirmeTaraf = _prefs?.getString('active_emzirme_taraf_$babyId');
          _solToplamSaniye = _prefs?.getInt('active_emzirme_sol_saniye_$babyId') ?? 0;
          _sagToplamSaniye = _prefs?.getInt('active_emzirme_sag_saniye_$babyId') ?? 0;
          _startEmzirmeUpdateTimer();
          // Resume notification if nursing was active
          await _notificationService.showNursingNotification(
              _emzirmeBaslangic!, _emzirmeTaraf);
        } catch (e) {
          _emzirmeBaslangic = null;
          _emzirmeIlkBaslangic = null;
        }
      }
    }

    // Load uyku timer (scoped to baby)
    final uykuBabyId = _prefs?.getString('active_uyku_baby_id');
    if (uykuBabyId == babyId) {
      final uykuStr = _prefs?.getString('active_uyku_start_$babyId');

      if (uykuStr != null && uykuStr.isNotEmpty) {
        try {
          _activeBabyId = babyId;
          _uykuBaslangic = DateTime.parse(uykuStr);
          _startUykuUpdateTimer();
          // Resume notification if sleep was active
          await _notificationService.showSleepNotification(_uykuBaslangic!);
        } catch (e) {
          _uykuBaslangic = null;
        }
      }
    }

    // Emit null for inactive timers so UI clears
    if (_emzirmeBaslangic == null) {
      _emzirmeController.add(null);
    }
    if (_uykuBaslangic == null) {
      _uykuController.add(null);
    }
  }

  /// Start emzirme timer
  Future<void> startEmzirme({String tur = 'anne', String? taraf}) async {
    if (_emzirmeBaslangic != null) return; // Already running

    _activeBabyId = _prefs?.getString('active_baby_id') ?? '';
    if (_activeBabyId == null || _activeBabyId!.isEmpty) return;

    _emzirmeBaslangic = DateTime.now();
    _emzirmeIlkBaslangic ??= _emzirmeBaslangic; // Set initial start time if not set
    _aktifEmzirmeTuru = tur;
    _emzirmeTaraf = taraf;

    await _prefs?.setString('active_emzirme_baby_id', _activeBabyId!);
    await _prefs?.setString('active_emzirme_start_$_activeBabyId', _emzirmeBaslangic!.toIso8601String());
    await _prefs?.setString('active_emzirme_ilk_start_$_activeBabyId', _emzirmeIlkBaslangic!.toIso8601String());
    await _prefs?.setString('active_emzirme_tur_$_activeBabyId', tur);
    if (taraf != null) {
      await _prefs?.setString('active_emzirme_taraf_$_activeBabyId', taraf);
    } else {
      await _prefs?.remove('active_emzirme_taraf_$_activeBabyId');
    }

    _startEmzirmeUpdateTimer();

    // Show persistent nursing notification
    await _notificationService.showNursingNotification(_emzirmeBaslangic!, taraf);
  }

  /// Switch emzirme side (sol <-> sag)
  Future<void> switchEmzirmeSide(String newTaraf) async {
    if (_emzirmeBaslangic == null) {
      // Not running, just start new
      await startEmzirme(tur: _aktifEmzirmeTuru ?? 'anne', taraf: newTaraf);
      return;
    }

    if (_activeBabyId == null || _activeBabyId!.isEmpty) return;

    // Save current side's time
    final currentDuration = DateTime.now().difference(_emzirmeBaslangic!);
    if (_emzirmeTaraf == 'sol') {
      _solToplamSaniye += currentDuration.inSeconds;
    } else if (_emzirmeTaraf == 'sag') {
      _sagToplamSaniye += currentDuration.inSeconds;
    }

    // Start new side timer
    _emzirmeBaslangic = DateTime.now();
    _emzirmeTaraf = newTaraf;

    // Save to preferences
    await _prefs?.setString('active_emzirme_start_$_activeBabyId', _emzirmeBaslangic!.toIso8601String());
    await _prefs?.setString('active_emzirme_taraf_$_activeBabyId', newTaraf);
    await _prefs?.setInt('active_emzirme_sol_saniye_$_activeBabyId', _solToplamSaniye);
    await _prefs?.setInt('active_emzirme_sag_saniye_$_activeBabyId', _sagToplamSaniye);

    // Restart update timer
    _startEmzirmeUpdateTimer();

    // Update notification with new side
    await _notificationService.updateNursingSide(newTaraf);
  }

  /// Stop emzirme timer and return the data
  Future<Map<String, dynamic>?> stopEmzirme() async {
    if (_emzirmeBaslangic == null && _solToplamSaniye == 0 && _sagToplamSaniye == 0) {
      return null;
    }

    // Add current running time to the active side
    if (_emzirmeBaslangic != null) {
      final currentDuration = DateTime.now().difference(_emzirmeBaslangic!);
      if (_emzirmeTaraf == 'sol') {
        _solToplamSaniye += currentDuration.inSeconds;
      } else if (_emzirmeTaraf == 'sag') {
        _sagToplamSaniye += currentDuration.inSeconds;
      }
    }

    final data = {
      'tarih': _emzirmeIlkBaslangic ?? DateTime.now(),
      'bitis': DateTime.now(),
      'tur': _aktifEmzirmeTuru ?? 'anne',
      'solSaniye': _solToplamSaniye,
      'sagSaniye': _sagToplamSaniye,
    };

    await _clearEmzirme();
    return data;
  }

  /// Clear emzirme timer without returning data
  Future<void> _clearEmzirme() async {
    final babyId = _activeBabyId;

    _emzirmeBaslangic = null;
    _emzirmeIlkBaslangic = null;
    _aktifEmzirmeTuru = null;
    _emzirmeTaraf = null;
    _solToplamSaniye = 0;
    _sagToplamSaniye = 0;

    if (babyId != null && babyId.isNotEmpty) {
      await _prefs?.remove('active_emzirme_start_$babyId');
      await _prefs?.remove('active_emzirme_ilk_start_$babyId');
      await _prefs?.remove('active_emzirme_tur_$babyId');
      await _prefs?.remove('active_emzirme_taraf_$babyId');
      await _prefs?.remove('active_emzirme_sol_saniye_$babyId');
      await _prefs?.remove('active_emzirme_sag_saniye_$babyId');
    }
    await _prefs?.remove('active_emzirme_baby_id');

    // Check if we should clear _activeBabyId (only if uyku is also not active)
    if (_uykuBaslangic == null) {
      _activeBabyId = null;
    }

    _emzirmeUpdateTimer?.cancel();
    _emzirmeUpdateTimer = null;
    _emzirmeController.add(null);

    // Cancel nursing notification
    await _notificationService.cancelNursingNotification();
  }

  /// Start uyku timer
  Future<void> startUyku() async {
    if (_uykuBaslangic != null) return; // Already running

    _activeBabyId = _prefs?.getString('active_baby_id') ?? '';
    if (_activeBabyId == null || _activeBabyId!.isEmpty) return;

    _uykuBaslangic = DateTime.now();
    await _prefs?.setString('active_uyku_baby_id', _activeBabyId!);
    await _prefs?.setString('active_uyku_start_$_activeBabyId', _uykuBaslangic!.toIso8601String());

    _startUykuUpdateTimer();

    // Show lock screen notification
    await _notificationService.showSleepNotification(_uykuBaslangic!);
  }

  /// Stop uyku timer and return the data
  Future<Map<String, dynamic>?> stopUyku() async {
    if (_uykuBaslangic == null) return null;

    final baslangic = _uykuBaslangic!;
    final bitis = DateTime.now();
    final sure = bitis.difference(baslangic);

    final data = {
      'baslangic': baslangic,
      'bitis': bitis,
      'sure': sure,
    };

    await _clearUyku();
    return data;
  }

  /// Clear uyku timer without returning data
  Future<void> _clearUyku() async {
    final babyId = _activeBabyId;

    _uykuBaslangic = null;

    if (babyId != null && babyId.isNotEmpty) {
      await _prefs?.remove('active_uyku_start_$babyId');
    }
    await _prefs?.remove('active_uyku_baby_id');

    // Check if we should clear _activeBabyId (only if emzirme is also not active)
    if (_emzirmeBaslangic == null) {
      _activeBabyId = null;
    }

    _uykuUpdateTimer?.cancel();
    _uykuUpdateTimer = null;
    _uykuController.add(null);

    // Cancel lock screen notification
    await _notificationService.cancelSleepNotification();
  }

  /// Start broadcasting emzirme updates
  void _startEmzirmeUpdateTimer() {
    _emzirmeUpdateTimer?.cancel();
    _emzirmeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_emzirmeBaslangic != null) {
        final elapsed = DateTime.now().difference(_emzirmeBaslangic!);
        _emzirmeController.add(elapsed);
      }
    });
    // Initial emit
    if (_emzirmeBaslangic != null) {
      final elapsed = DateTime.now().difference(_emzirmeBaslangic!);
      _emzirmeController.add(elapsed);
    }
  }

  /// Start broadcasting uyku updates
  void _startUykuUpdateTimer() {
    _uykuUpdateTimer?.cancel();
    _uykuUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_uykuBaslangic != null) {
        final elapsed = DateTime.now().difference(_uykuBaslangic!);
        _uykuController.add(elapsed);
      }
    });
    // Initial emit
    if (_uykuBaslangic != null) {
      final elapsed = DateTime.now().difference(_uykuBaslangic!);
      _uykuController.add(elapsed);
    }
  }

  /// Check if emzirme timer is active for current baby
  bool get isEmzirmeActive {
    if (_emzirmeBaslangic == null) return false;
    final currentBabyId = _prefs?.getString('active_baby_id') ?? '';
    return _activeBabyId == currentBabyId;
  }

  /// Check if uyku timer is active for current baby
  bool get isUykuActive {
    if (_uykuBaslangic == null) return false;
    final currentBabyId = _prefs?.getString('active_baby_id') ?? '';
    return _activeBabyId == currentBabyId;
  }

  /// Get current emzirme elapsed time
  Duration? get emzirmeElapsed {
    if (_emzirmeBaslangic == null) return null;
    return DateTime.now().difference(_emzirmeBaslangic!);
  }

  /// Get current uyku elapsed time
  Duration? get uykuElapsed {
    if (_uykuBaslangic == null) return null;
    return DateTime.now().difference(_uykuBaslangic!);
  }

  /// Get emzirme start time
  DateTime? get emzirmeBaslangic => _emzirmeBaslangic;

  /// Get uyku start time
  DateTime? get uykuBaslangic => _uykuBaslangic;

  /// Get active emzirme type
  String? get aktifEmzirmeTuru => _aktifEmzirmeTuru;

  /// Get active emzirme side
  String? get emzirmeTaraf => _emzirmeTaraf;

  /// Get sol total seconds (including current running time if sol is active)
  int get solToplamSaniye {
    int total = _solToplamSaniye;
    if (_emzirmeBaslangic != null && _emzirmeTaraf == 'sol') {
      total += DateTime.now().difference(_emzirmeBaslangic!).inSeconds;
    }
    return total;
  }

  /// Get sag total seconds (including current running time if sag is active)
  int get sagToplamSaniye {
    int total = _sagToplamSaniye;
    if (_emzirmeBaslangic != null && _emzirmeTaraf == 'sag') {
      total += DateTime.now().difference(_emzirmeBaslangic!).inSeconds;
    }
    return total;
  }

  /// Dispose resources
  void dispose() {
    _emzirmeUpdateTimer?.cancel();
    _uykuUpdateTimer?.cancel();
    _emzirmeController.close();
    _uykuController.close();
    _notificationService.dispose();
  }
}
