import 'dart:async';
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

  /// Stop sleep timer and save activity from notification action
  Future<void> _stopAndSaveUykuFromNotification() async {
    final data = await stopUyku();
    if (data == null) return;

    final baslangic = data['baslangic'] as DateTime;
    final bitis = data['bitis'] as DateTime;
    final duration = bitis.difference(baslangic);
    if (duration.inMinutes < 1) return;

    final kayitlar = VeriYonetici.getUykuKayitlari();
    kayitlar.insert(0, {
      'baslangic': data['baslangic'],
      'bitis': data['bitis'],
      'sure': data['sure'],
    });
    await VeriYonetici.saveUykuKayitlari(kayitlar);
  }

  /// Stop nursing timer and save activity from notification action
  Future<void> _stopAndSaveEmzirmeFromNotification() async {
    final data = await stopEmzirme();
    if (data == null) return;

    final solSaniye = data['solSaniye'] as int;
    final sagSaniye = data['sagSaniye'] as int;
    if (solSaniye == 0 && sagSaniye == 0) return;

    final solDakika = (solSaniye / 60).ceil();
    final sagDakika = (sagSaniye / 60).ceil();

    final kayitlar = VeriYonetici.getMamaKayitlari();
    kayitlar.insert(0, {
      'tarih': data['tarih'] ?? DateTime.now(),
      'tur': 'Anne Sütü',
      'solDakika': solDakika > 0 ? solDakika : (solSaniye > 0 ? 1 : 0),
      'sagDakika': sagDakika > 0 ? sagDakika : (sagSaniye > 0 ? 1 : 0),
      'miktar': 0,
    });
    await VeriYonetici.saveMamaKayitlari(kayitlar);

    // Schedule feeding reminder if enabled
    if (VeriYonetici.isFeedingReminderEnabled()) {
      final reminderService = ReminderService();
      await reminderService.initialize();
      await reminderService.scheduleFeedingReminder(
        lastFeedingTime: DateTime.now(),
        intervalMinutes: VeriYonetici.getFeedingReminderInterval(),
      );
    }
  }

  /// Load saved timer states from preferences
  Future<void> _loadState() async {
    final emzirmeStr = _prefs?.getString('active_emzirme_start');
    final emzirmeIlkStr = _prefs?.getString('active_emzirme_ilk_start');
    final uykuStr = _prefs?.getString('active_uyku_start');

    if (emzirmeStr != null && emzirmeStr.isNotEmpty) {
      try {
        _emzirmeBaslangic = DateTime.parse(emzirmeStr);
        _emzirmeIlkBaslangic = emzirmeIlkStr != null
            ? DateTime.parse(emzirmeIlkStr)
            : _emzirmeBaslangic;
        _aktifEmzirmeTuru = _prefs?.getString('active_emzirme_tur');
        _emzirmeTaraf = _prefs?.getString('active_emzirme_taraf');
        _solToplamSaniye = _prefs?.getInt('active_emzirme_sol_saniye') ?? 0;
        _sagToplamSaniye = _prefs?.getInt('active_emzirme_sag_saniye') ?? 0;
        _startEmzirmeUpdateTimer();
        // Resume notification if nursing was active
        await _notificationService.showNursingNotification(
            _emzirmeBaslangic!, _emzirmeTaraf);
      } catch (e) {
        _emzirmeBaslangic = null;
        _emzirmeIlkBaslangic = null;
        _aktifEmzirmeTuru = null;
        _emzirmeTaraf = null;
        _solToplamSaniye = 0;
        _sagToplamSaniye = 0;
      }
    }

    if (uykuStr != null && uykuStr.isNotEmpty) {
      try {
        _uykuBaslangic = DateTime.parse(uykuStr);
        _startUykuUpdateTimer();
        // Resume notification if sleep was active
        await _notificationService.showSleepNotification(_uykuBaslangic!);
      } catch (e) {
        _uykuBaslangic = null;
      }
    }
  }

  /// Start emzirme timer
  Future<void> startEmzirme({String tur = 'anne', String? taraf}) async {
    if (_emzirmeBaslangic != null) return; // Already running

    _emzirmeBaslangic = DateTime.now();
    _emzirmeIlkBaslangic ??= _emzirmeBaslangic; // Set initial start time if not set
    _aktifEmzirmeTuru = tur;
    _emzirmeTaraf = taraf;

    await _prefs?.setString('active_emzirme_start', _emzirmeBaslangic!.toIso8601String());
    await _prefs?.setString('active_emzirme_ilk_start', _emzirmeIlkBaslangic!.toIso8601String());
    await _prefs?.setString('active_emzirme_tur', tur);
    if (taraf != null) {
      await _prefs?.setString('active_emzirme_taraf', taraf);
    } else {
      await _prefs?.remove('active_emzirme_taraf');
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
    await _prefs?.setString('active_emzirme_start', _emzirmeBaslangic!.toIso8601String());
    await _prefs?.setString('active_emzirme_taraf', newTaraf);
    await _prefs?.setInt('active_emzirme_sol_saniye', _solToplamSaniye);
    await _prefs?.setInt('active_emzirme_sag_saniye', _sagToplamSaniye);

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
    _emzirmeBaslangic = null;
    _emzirmeIlkBaslangic = null;
    _aktifEmzirmeTuru = null;
    _emzirmeTaraf = null;
    _solToplamSaniye = 0;
    _sagToplamSaniye = 0;

    await _prefs?.remove('active_emzirme_start');
    await _prefs?.remove('active_emzirme_ilk_start');
    await _prefs?.remove('active_emzirme_tur');
    await _prefs?.remove('active_emzirme_taraf');
    await _prefs?.remove('active_emzirme_sol_saniye');
    await _prefs?.remove('active_emzirme_sag_saniye');

    _emzirmeUpdateTimer?.cancel();
    _emzirmeUpdateTimer = null;
    _emzirmeController.add(null);

    // Cancel nursing notification
    await _notificationService.cancelNursingNotification();
  }

  /// Start uyku timer
  Future<void> startUyku() async {
    if (_uykuBaslangic != null) return; // Already running

    _uykuBaslangic = DateTime.now();
    await _prefs?.setString('active_uyku_start', _uykuBaslangic!.toIso8601String());

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
    _uykuBaslangic = null;
    await _prefs?.remove('active_uyku_start');

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

  /// Check if emzirme timer is active
  bool get isEmzirmeActive => _emzirmeBaslangic != null;

  /// Check if uyku timer is active
  bool get isUykuActive => _uykuBaslangic != null;

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
