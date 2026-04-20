import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/veri_yonetici.dart';
import '../models/timer_yonetici.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/reminder_service.dart';
import 'settings_screen.dart';
import 'activities_screen.dart';
import 'add_growth_screen.dart';
import 'baby_profile_screen.dart';
import 'growth_screen.dart';
import '../models/daily_tip.dart';
import '../widgets/baby_switcher_sheet.dart';
import '../widgets/add_baby_sheet.dart';
import 'tips_archive_screen.dart';
import 'vaccines_screen.dart';
import '../utils/vaccine_utils.dart';
import '../utils/locale_text_utils.dart';
import 'premium_screen.dart';
import '../services/premium_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const HomeScreen({super.key, this.onDataChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _emzirmeKaydediliyor = false;
  late final VoidCallback _dataChangedListener;

  // Emzirme sayaç değişkenleri
  bool _solAktif = false;
  bool _sagAktif = false;
  int _solSaniye = 0;
  int _sagSaniye = 0;

  // Uyku sayaç değişkenleri
  int _uykuSaniye = 0;

  // Timer manager instance
  final _timerYonetici = TimerYonetici();

  // Stream subscriptions
  StreamSubscription<Duration?>? _emzirmeSubscription;
  StreamSubscription<Duration?>? _uykuSubscription;

  // Baby info
  String _babyName = 'Sofia';
  DateTime _birthDate = DateTime(2024, 9, 17);
  String? _babyPhotoPath;
  String? _babyPhotoUrl; // remote fallback for shared babies

  int get babyAgeInMonths {
    return calcAge(_birthDate, referenceDate: DateTime.now()).totalMonths;
  }

  @override
  void initState() {
    super.initState();
    _dataChangedListener = () {
      if (!mounted) return;
      if (kDebugMode) {
        debugPrint('[HomeScreen] State notified → reloading baby info + recents');
      }
      _loadBabyInfo();
    };
    VeriYonetici.dataNotifier.addListener(_dataChangedListener);
    _loadBabyInfo();
    _initializeTimerValues();
    _setupTimerListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _timerYonetici.setLiveActivityLocalization(
      sleepTitle: l10n.sleep,
      sleepSubtitle: '',
      nursingTitle: l10n.nursing,
      leftLabel: l10n.left,
      rightLabel: l10n.right,
      leftSubtitle: l10n.leftBreast,
      rightSubtitle: l10n.rightBreast,
    );
  }

  void _initializeTimerValues() {
    // Initialize timer values from TimerYonetici's current state
    // This prevents showing "00:00" flash before first stream update
    if (_timerYonetici.isEmzirmeActive) {
      _solSaniye = _timerYonetici.solToplamSaniye;
      _sagSaniye = _timerYonetici.sagToplamSaniye;
      final taraf = _timerYonetici.emzirmeTaraf;
      _solAktif = taraf == 'sol';
      _sagAktif = taraf == 'sag';
    }

    if (_timerYonetici.isUykuActive) {
      _uykuSaniye = _timerYonetici.uykuElapsed?.inSeconds ?? 0;
    }
  }

  void _loadBabyInfo() {
    final baby = VeriYonetici.getActiveBabyOrNull();
    setState(() {
      if (baby == null) {
        _babyName = '';
        _birthDate = DateTime.now();
        _babyPhotoPath = null;
        _babyPhotoUrl = null;
        return;
      }
      _babyName = baby.name;
      _birthDate = baby.birthDate;
      _babyPhotoPath = baby.photoPath;
      _babyPhotoUrl = baby.photoUrl;
    });
  }

  void _setupTimerListeners() {
    // Listen to emzirme timer updates
    _emzirmeSubscription = _timerYonetici.emzirmeStream.listen((duration) {
      if (duration != null) {
        setState(() {
          // Determine which side is active based on saved state
          final taraf = _timerYonetici.emzirmeTaraf;
          _solAktif = taraf == 'sol';
          _sagAktif = taraf == 'sag';

          // Get total seconds for each side
          _solSaniye = _timerYonetici.solToplamSaniye;
          _sagSaniye = _timerYonetici.sagToplamSaniye;
        });
      } else {
        // Timer stopped
        setState(() {
          _solAktif = false;
          _sagAktif = false;
          _solSaniye = 0;
          _sagSaniye = 0;
        });
      }
    });

    // Listen to uyku timer updates
    _uykuSubscription = _timerYonetici.uykuStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _uykuSaniye = duration.inSeconds;
        });
      } else {
        setState(() {
          _uykuSaniye = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    VeriYonetici.dataNotifier.removeListener(_dataChangedListener);
    _emzirmeSubscription?.cancel();
    _uykuSubscription?.cancel();
    super.dispose();
  }

  // EMZİRME FONKSİYONLARI
  void _startSol() async {
    if (!VeriYonetici.hasActiveBaby()) return;
    await _timerYonetici.switchEmzirmeSide(
      VeriYonetici.getActiveBabyId(),
      'sol',
    );
  }

  void _startSag() async {
    if (!VeriYonetici.hasActiveBaby()) return;
    await _timerYonetici.switchEmzirmeSide(
      VeriYonetici.getActiveBabyId(),
      'sag',
    );
  }

  void _stopEmzirmeAndSave() async {
    if (!VeriYonetici.hasActiveBaby()) return;
    if (kDebugMode) debugPrint('[HomeScreen] Stop pressed type=nursing');

    // ── 1. Stop timer ──────────────────────────────────────────────────────────
    Map<String, dynamic>? data;
    try {
      data = await _timerYonetici.stopEmzirme(VeriYonetici.getActiveBabyId());
    } catch (e, st) {
      if (kDebugMode) debugPrint('[HomeScreen] stopEmzirme threw: $e\n$st');
      setState(() {
        _solAktif = false;
        _sagAktif = false;
      });
      return;
    }

    if (data == null) {
      if (kDebugMode) {
        debugPrint('[HomeScreen] stopEmzirme returned null, skipping save');
      }
      setState(() {
        _solAktif = false;
        _sagAktif = false;
      });
      return;
    }

    final solSaniye = data['solSaniye'] as int;
    final sagSaniye = data['sagSaniye'] as int;

    if (kDebugMode) {
      debugPrint(
        '[HomeScreen] nursing stop data: solSaniye=$solSaniye sagSaniye=$sagSaniye',
      );
    }

    if (solSaniye == 0 && sagSaniye == 0) {
      // Both sides zero — timer ran but no side was ever attributed. This
      // should not happen after the TimerYonetici fix (null taraf → sol),
      // but guard here so we at least log rather than silently drop.
      if (kDebugMode) {
        debugPrint(
          '[HomeScreen] WARNING: both sides 0 after stop, skipping save',
        );
      }
      setState(() {
        _solAktif = false;
        _sagAktif = false;
      });
      return;
    }

    setState(() => _emzirmeKaydediliyor = true);

    // ── 2. Persist ─────────────────────────────────────────────────────────────
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

    try {
      if (kDebugMode) {
        debugPrint(
          '[HomeScreen] saving nursing record: solDakika=$solDakika sagDakika=$sagDakika',
        );
      }
      await VeriYonetici.saveMamaKayitlari(kayitlar);
      if (kDebugMode) {
        debugPrint(
          '[HomeScreen] nursing record saved OK, total=${VeriYonetici.getMamaKayitlari().length}',
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[HomeScreen] ERROR saving nursing record: $e\n$st');
      }
    }

    // ── 3. Schedule reminder ───────────────────────────────────────────────────
    if (VeriYonetici.isFeedingReminderEnabled()) {
      try {
        final scheduledAt = _nextReminderDateTime(
          TimeOfDay(
            hour: VeriYonetici.getFeedingReminderHour(),
            minute: VeriYonetici.getFeedingReminderMinute(),
          ),
        );
        final reminderService = ReminderService();
        await reminderService.initialize();
        await reminderService.scheduleFeedingReminderAt(scheduledAt);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[HomeScreen] reminder schedule error: $e\n$st');
        }
      }
    }

    setState(() {
      _solAktif = false;
      _sagAktif = false;
      _solSaniye = 0;
      _sagSaniye = 0;
      _emzirmeKaydediliyor = false;
    });

    widget.onDataChanged?.call();
  }

  // UYKU FONKSİYONLARI
  void _startUyku() async {
    if (!VeriYonetici.hasActiveBaby()) return;
    await _timerYonetici.startUyku(VeriYonetici.getActiveBabyId());
  }

  void _stopUykuAndSave() async {
    if (!VeriYonetici.hasActiveBaby()) return;
    if (kDebugMode) debugPrint('[HomeScreen] Stop pressed type=sleep');

    // ── 1. Stop timer ──────────────────────────────────────────────────────────
    Map<String, dynamic>? data;
    try {
      data = await _timerYonetici.stopUyku(VeriYonetici.getActiveBabyId());
    } catch (e, st) {
      if (kDebugMode) debugPrint('[HomeScreen] stopUyku threw: $e\n$st');
      setState(() => _uykuSaniye = 0);
      return;
    }

    if (data == null) {
      if (kDebugMode) {
        debugPrint('[HomeScreen] stopUyku returned null, skipping save');
      }
      setState(() => _uykuSaniye = 0);
      return;
    }

    final baslangic = data['baslangic'] as DateTime;
    final bitis = data['bitis'] as DateTime;
    final duration = bitis.difference(baslangic);

    if (kDebugMode) {
      debugPrint(
        '[HomeScreen] sleep stop data: elapsed=${duration.inSeconds}s',
      );
    }

    if (duration.inMinutes < 1) {
      if (kDebugMode) debugPrint('[HomeScreen] sleep < 1 min, skipping save');
      setState(() => _uykuSaniye = 0);
      return;
    }

    // ── 2. Persist ─────────────────────────────────────────────────────────────
    final kayitlar = VeriYonetici.getUykuKayitlari();
    kayitlar.insert(0, {
      'baslangic': data['baslangic'],
      'bitis': data['bitis'],
      'sure': data['sure'],
    });

    try {
      if (kDebugMode) {
        debugPrint(
          '[HomeScreen] saving sleep record: duration=${duration.inMinutes}m',
        );
      }
      await VeriYonetici.saveUykuKayitlari(kayitlar);
      if (kDebugMode) {
        debugPrint(
          '[HomeScreen] sleep record saved OK, total=${VeriYonetici.getUykuKayitlari().length}',
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[HomeScreen] ERROR saving sleep record: $e\n$st');
      }
    }

    setState(() => _uykuSaniye = 0);
    widget.onDataChanged?.call();
  }

  String _formatSaniye(int saniye) {
    final dk = saniye ~/ 60;
    final sn = saniye % 60;
    return '${dk.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  DateTime _nextReminderDateTime(TimeOfDay time) {
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      return scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  bool get _emzirmeAktif => _timerYonetici.isEmzirmeActive;

  bool get _uykuAktif => _timerYonetici.isUykuActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasBabies = VeriYonetici.getBabies().isNotEmpty;

    if (!hasBabies) {
      return _buildNoBabyState(context, l10n, isDark);
    }

    final textColor = isDark ? Colors.white : const Color(0xFF2D1A18);
    final subtitleColor = textColor.withValues(alpha: 0.6);
    final hasLocalPhoto =
        !kIsWeb &&
        _babyPhotoPath != null &&
        _babyPhotoPath!.isNotEmpty &&
        File(_babyPhotoPath!).existsSync();
    final hasRemotePhoto =
        _babyPhotoUrl != null && _babyPhotoUrl!.isNotEmpty;
    final hasValidPhoto = hasLocalPhoto || hasRemotePhoto;

    final mamaKayitlari = VeriYonetici.getMamaKayitlari();
    final kakaKayitlari = VeriYonetici.getKakaKayitlari();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFFF8F0),
            ),
          ),

          // Decorative blobs
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    top: -80,
                    left: -80,
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFFEBE8FF,
                        ).withValues(alpha: isDark ? 0.08 : 0.5),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    right: -128,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFFEBE8FF,
                        ).withValues(alpha: isDark ? 0.06 : 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        // Baby profile area (tappable -> profile)
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BabyProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadBabyInfo();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.bgDarkCard
                                      : const Color(0xFFEBE8FF),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                  image: hasValidPhoto
                                      ? DecorationImage(
                                          image: hasLocalPhoto
                                              ? FileImage(File(_babyPhotoPath!))
                                                  as ImageProvider
                                              : NetworkImage(_babyPhotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: !hasValidPhoto
                                    ? Icon(
                                        Icons.child_care,
                                        color: isDark
                                            ? Colors.white54
                                            : AppColors.primary.withValues(
                                                alpha: 0.7,
                                              ),
                                        size: 24,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _babyName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                        if (VeriYonetici.hasActiveBaby() &&
                                            VeriYonetici.isBabyVisiblyShared(
                                              VeriYonetici.getActiveBaby().id,
                                            )) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF6AADCF)
                                                      .withValues(alpha: 0.14)
                                                  : const Color(0xFFDCEFF7),
                                              border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF9DCFE8)
                                                        .withValues(alpha: 0.18)
                                                    : const Color(0xFF6AADCF)
                                                        .withValues(alpha: 0.16),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF9DCFE8,
                                                          )
                                                        : const Color(
                                                            0xFF6AADCF,
                                                          ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.sharedBadge,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF9DCFE8,
                                                          )
                                                        : const Color(
                                                            0xFF6AADCF,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      ageString(context, _birthDate),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Baby switcher icon
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (_) => BabySwitcherSheet(
                                onBabyChanged: () {
                                  _loadBabyInfo();
                                  widget.onDataChanged?.call();
                                },
                              ),
                            );
                          },
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: subtitleColor,
                            size: 22,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: textColor.withValues(alpha: 0.7),
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // TIMER CARDS (2x2 grid)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Feeding card
                        Expanded(
                          child: _buildTimerCard(
                            label: l10n.feedingTimer,
                            time: _formatSaniye(_solSaniye + _sagSaniye),
                            lastActivity: '',
                            isActive: _emzirmeAktif,
                            isDark: isDark,
                            activeSide: _emzirmeAktif
                                ? (_solAktif
                                      ? l10n.left.toUpperCase()
                                      : (_sagAktif
                                            ? l10n.right.toUpperCase()
                                            : null))
                                : null,
                            buttons: _emzirmeAktif
                                ? GestureDetector(
                                    onTap: _emzirmeKaydediliyor
                                        ? null
                                        : _stopEmzirmeAndSave,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF998A),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l10n.stopAndSave,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _startSol,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF998A),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              l10n.left.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _startSag,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.1,
                                                    )
                                                  : const Color(0xFFFFF8F0),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              l10n.right.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? const Color(
                                                        0xFFFF998A,
                                                      ).withValues(alpha: 0.9)
                                                    : const Color(0xFFFF998A),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Sleeping card
                        Expanded(
                          child: _buildTimerCard(
                            label: l10n.sleepingTimer,
                            time: _formatSaniye(_uykuSaniye),
                            lastActivity: '',
                            isActive: _uykuAktif,
                            isDark: isDark,
                            buttons: GestureDetector(
                              onTap: _uykuAktif ? _stopUykuAndSave : _startUyku,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(
                                          0xFFEBE8FF,
                                        ).withValues(alpha: 0.15)
                                      : const Color(0xFFEBE8FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_uykuAktif)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF4CAF50),
                                        ),
                                      ),
                                    Text(
                                      _uykuAktif
                                          ? l10n.activeTimer
                                          : l10n.start.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7A749E),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LAST ACTIVITY SUMMARY
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _navigateToActivities(ActivityType.mama),
                            child: _buildSummaryCard(
                              label: l10n.lastFed,
                              value: _getLastFeedingValue(l10n, mamaKayitlari),
                              progress: _getTimeProgress(
                                mamaKayitlari.isNotEmpty
                                    ? mamaKayitlari.first['tarih'] as DateTime?
                                    : null,
                              ),
                              progressColor: const Color(0xFFFF998A),
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _navigateToActivities(ActivityType.bez),
                            child: _buildSummaryCard(
                              label: l10n.lastDiaper,
                              value: _getLastDiaperValue(l10n, kakaKayitlari),
                              progress: _getTimeProgress(
                                kakaKayitlari.isNotEmpty
                                    ? kakaKayitlari.first['tarih'] as DateTime?
                                    : null,
                              ),
                              progressColor: const Color(0xFF7A749E),
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _navigateToActivities(ActivityType.uyku),
                            child: _buildSummaryCard(
                              label: l10n.lastSleep,
                              value: _getLastSleepValue(
                                l10n,
                                VeriYonetici.getUykuKayitlari(),
                              ),
                              progress: _getTimeProgress(
                                VeriYonetici.getUykuKayitlari().isNotEmpty
                                    ? VeriYonetici.getUykuKayitlari()
                                              .first['bitis']
                                          as DateTime?
                                    : null,
                              ),
                              progressColor: const Color(0xFF7A749E),
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // DAILY TIP
                  _buildDailyTipCard(l10n, isDark, textColor, subtitleColor),

                  const SizedBox(height: 18),

                  // RECENT ACTIVITY HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recentActivity,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActivitiesScreen(fromHome: true),
                              ),
                            );
                          },
                          child: Text(
                            l10n.seeHistory,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFFFF998A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RECENT ACTIVITY LIST (last 24 hours)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ValueListenableBuilder<int>(
                      valueListenable: VeriYonetici.dataNotifier,
                      builder: (context, _, _) => _buildRecentActivitiesList(
                        l10n,
                        VeriYonetici.getMamaKayitlari(),
                        VeriYonetici.getKakaKayitlari(),
                        VeriYonetici.getUykuKayitlari(),
                        isDark,
                        textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // UPCOMING VACCINE
                  ValueListenableBuilder<int>(
                    valueListenable: VeriYonetici.vaccineNotifier,
                    builder: (context, value, child) {
                      return _buildUpcomingVaccineCard(
                        l10n,
                        isDark,
                        textColor,
                        subtitleColor,
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // GROWTH TRACKING SECTION
                  _buildGrowthSection(l10n, isDark, textColor, subtitleColor),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TIMER CARD WIDGET
  Widget _buildTimerCard({
    required String label,
    required String time,
    required String lastActivity,
    required bool isActive,
    required bool isDark,
    required Widget buttons,
    String? activeSide,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkCard : const Color(0xFFF1D9F5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFFFF8F0).withValues(alpha: 0.5),
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                  .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: isDark ? Colors.white : const Color(0xFF2D1A18),
                ),
              ),
              if (activeSide != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF998A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activeSide,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (lastActivity.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              lastActivity,
              style: TextStyle(
                fontSize: 10,
                color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
          const SizedBox(height: 14),
          buttons,
        ],
      ),
    );
  }

  // SUMMARY CARD
  Widget _buildSummaryCard({
    required String label,
    required String value,
    required double progress,
    required Color progressColor,
    required bool isDark,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF4EEEB),
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
              color:
                  (isDark ? AppColors.textPrimaryDark : const Color(0xFF1D0E0C))
                      .withValues(alpha: 0.44),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF1D0E0C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ACTIVITY ITEM
  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String trailingLabel,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.bgDarkCard : Colors.white).withValues(
          alpha: isDark ? 0.76 : 0.72,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF4EFEC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2D1A18),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.15,
                    color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                trailingLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                      .withValues(alpha: 0.38),
                ),
              ),
              const SizedBox(height: 1),
              Icon(
                Icons.chevron_right_rounded,
                color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                    .withValues(alpha: 0.26),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // RECENT ACTIVITIES LIST (last 24 hours)
  Widget _buildRecentActivitiesList(
    AppLocalizations l10n,
    List<Map<String, dynamic>> mama,
    List<Map<String, dynamic>> kaka,
    List<Map<String, dynamic>> uyku,
    bool isDark,
    Color textColor,
  ) {
    final List<Map<String, dynamic>> timeline = [];
    final son24Saat = DateTime.now().subtract(const Duration(hours: 24));

    // Add mama activities
    for (var k in mama) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({'type': 'mama', 'tarih': tarih, 'data': k});
      }
    }

    // Add kaka activities
    for (var k in kaka) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({'type': 'kaka', 'tarih': tarih, 'data': k});
      }
    }

    // Add uyku activities
    for (var k in uyku) {
      final tarih = k['bitis'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({'type': 'uyku', 'tarih': tarih, 'data': k});
      }
    }

    // Sort by time descending
    timeline.sort(
      (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
    );

    if (kDebugMode) {
      debugPrint('[HomeScreen] Recents rebuilt, count=${timeline.length}');
    }

    if (timeline.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            l10n.noActivitiesLast24h,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(timeline.length > 5 ? 5 : timeline.length, (
        index,
      ) {
        final item = timeline[index];
        final type = item['type'] as String;
        final tarih = item['tarih'] as DateTime;
        final data = item['data'] as Map<String, dynamic>;

        String title;
        String subtitle;

        switch (type) {
          case 'mama':
            final tur = data['tur'] as String? ?? '';
            final kategori = data['kategori'] as String? ?? 'Milk';
            if (tur == 'Anne Sütü') {
              title = l10n.breastfeeding;
              final sol = data['solDakika'] ?? 0;
              final sag = data['sagDakika'] ?? 0;
              subtitle = l10n.leftMinRightMin(sol, sag);
            } else if (kategori == 'Solid' || tur == 'Katı Gıda') {
              title = l10n.solidFood;
              final solidAciklama = data['solidAciklama'] as String?;
              subtitle = (solidAciklama != null && solidAciklama.isNotEmpty)
                  ? solidAciklama
                  : l10n.solidFood;
            } else {
              title = l10n.bottleFeeding;
              subtitle = '${data['miktar']} ml';
            }
            break;
          case 'kaka':
            title = l10n.diaperChange;
            subtitle = _localizedDiaperType(
              l10n,
              data['diaperType'] ?? data['tur'],
            );
            break;
          case 'uyku':
            title = l10n.sleep;
            final sure = data['sure'] as Duration;
            final hours = sure.inHours;
            final minutes = sure.inMinutes % 60;
            subtitle = hours > 0
                ? '$hours${l10n.hourAbbrev} $minutes${l10n.minAbbrev}'
                : '$minutes${l10n.minAbbrev}';
            break;
          default:
            title = l10n.activities;
            subtitle = '';
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < timeline.length - 1 ? 10 : 0,
          ),
          child: _buildActivityItem(
            title: title,
            subtitle: subtitle,
            trailingLabel: _timeAgo(l10n, tarih),
            isDark: isDark,
          ),
        );
      }),
    );
  }

  // DAILY TIP CARD
  Widget _buildDailyTipCard(
    AppLocalizations l10n,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final tip = DailyTip.todayForBaby(babyAgeInMonths);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFE5E0F7).withValues(alpha: 0.5),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dailyTip,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (!PremiumService.instance.isPremium) {
                      await PremiumScreen.show(context);
                      return;
                    }
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TipsArchiveScreen(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.allTips,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.accentLavender
                          : const Color(0xFF7A749E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFE5E0F7).withValues(alpha: 0.12)
                        : const Color(0xFFE5E0F7).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      tip.illustrationPath,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.lightbulb_outline,
                        color: isDark
                            ? AppColors.accentLavender
                            : const Color(0xFF7A749E),
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title(context),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.description(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // UPCOMING VACCINE CARD
  Widget _buildUpcomingVaccineCard(
    AppLocalizations l10n,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final vaccines = VeriYonetici.getAsiKayitlari();
    final upcoming = getUpcomingVaccines(vaccines);

    if (upcoming.isEmpty) {
      return const SizedBox.shrink();
    }

    final primaryVaccine = upcoming[0];
    final secondaryVaccine = upcoming.length > 1 ? upcoming[1] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VaccinesScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDarkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE5E0F7).withValues(alpha: 0.5),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.upcomingVaccine,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: subtitleColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFFFB4A2).withValues(alpha: 0.15)
                          : const Color(0xFFFFB4A2).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.vaccines_outlined,
                      color: isDark
                          ? const Color(0xFFFFB4A2)
                          : const Color(0xFFE8A0A0),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          primaryVaccine['ad'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${primaryVaccine['donem']} · ${getVaccineRelativeDate(primaryVaccine['tarih'] as DateTime)}',
                          style: TextStyle(fontSize: 13, color: subtitleColor),
                        ),
                        if (secondaryVaccine != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.nextVaccineLabel(secondaryVaccine['ad'] ?? ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // GROWTH SECTION
  Widget _buildGrowthSection(
    AppLocalizations l10n,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final boyKiloKayitlari = VeriYonetici.getBoyKiloKayitlari();

    if (boyKiloKayitlari.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFFFF8F0).withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.straighten, color: Color(0xFFFF998A), size: 32),
              const SizedBox(height: 12),
              Text(
                l10n.trackYourBabyGrowth,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addHeightWeightMeasurements,
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _navigateToAddGrowth(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF998A),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    l10n.addFirstMeasurement,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final latest = boyKiloKayitlari.first;
    final tarih = latest['tarih'] as DateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.growthTracking,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    _formatDaysAgo(l10n, tarih),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFEBE8FF).withValues(alpha: 0.12)
                      : const Color(0xFFEBE8FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: isDark
                      ? AppColors.accentLavender
                      : const Color(0xFF7A749E),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Growth cards
        GestureDetector(
          onTap: () => _navigateToAddGrowth(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildGrowthCard(
                    icon: Icons.monitor_weight_outlined,
                    label: l10n.weightLabel,
                    value: '${latest['kilo']}',
                    unit: 'kg',
                    change: _getWeightChange(l10n, boyKiloKayitlari),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGrowthCard(
                    icon: Icons.straighten,
                    label: l10n.heightLabel,
                    value: '${latest['boy']}',
                    unit: 'cm',
                    change: _getHeightChange(l10n, boyKiloKayitlari),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // View charts button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GrowthScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? AppColors.accentLavender.withValues(alpha: 0.3)
                      : const Color(0xFFEBE8FF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.viewGrowthCharts,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark
                      ? AppColors.accentLavender
                      : const Color(0xFF7A749E),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required String change,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkCard : const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: change.startsWith('+')
                    ? const Color(0xFFFF998A)
                    : const Color(0xFF7A749E),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (change.isNotEmpty)
            Row(
              children: [
                Icon(Icons.arrow_upward, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // HELPER METHODS
  String _getLastFeedingValue(
    AppLocalizations l10n,
    List<Map<String, dynamic>> mama,
  ) {
    if (mama.isEmpty) return l10n.noRecordsYet;
    final tarih = mama.first['tarih'] as DateTime;
    final diff = DateTime.now().difference(tarih);
    if (diff.inMinutes < 60) {
      return l10n.mAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return l10n.hmAgo(hours, minutes);
    } else {
      return l10n.dAgo(diff.inDays);
    }
  }

  String _getLastDiaperValue(
    AppLocalizations l10n,
    List<Map<String, dynamic>> kaka,
  ) {
    if (kaka.isEmpty) return l10n.noRecordsYet;
    final tarih = kaka.first['tarih'] as DateTime;
    final diff = DateTime.now().difference(tarih);
    if (diff.inMinutes < 60) {
      return l10n.mAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return l10n.hmAgo(hours, minutes);
    } else {
      return l10n.dAgo(diff.inDays);
    }
  }

  String _getLastSleepValue(
    AppLocalizations l10n,
    List<Map<String, dynamic>> uyku,
  ) {
    if (uyku.isEmpty) return l10n.noRecordsYet;
    final tarih = uyku.first['bitis'] as DateTime;
    final diff = DateTime.now().difference(tarih);
    if (diff.inMinutes < 60) {
      return l10n.mAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return l10n.hmAgo(hours, minutes);
    } else {
      return l10n.dAgo(diff.inDays);
    }
  }

  double _getTimeProgress(DateTime? lastTime) {
    if (lastTime == null) return 0.0;
    final diff = DateTime.now().difference(lastTime);
    // Progress bar shows how "fresh" the activity is
    // Full bar (1.0) = just now, empty bar (0.0) = 4+ hours ago
    final hoursAgo = diff.inMinutes / 60.0;
    if (hoursAgo >= 4) return 0.1;
    return 1.0 - (hoursAgo / 4.0) * 0.9;
  }

  void _navigateToActivities(ActivityType tab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitiesScreen(initialTab: tab, fromHome: true),
      ),
    );
  }

  void _navigateToAddGrowth() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGrowthScreen(onSaved: widget.onDataChanged),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  String _formatDaysAgo(AppLocalizations l10n, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return l10n.lastUpdatedToday;
    if (diff.inDays == 1) return l10n.lastUpdated1Day;
    return l10n.lastUpdatedDays(diff.inDays);
  }

  String _getWeightChange(
    AppLocalizations l10n,
    List<Map<String, dynamic>> records,
  ) {
    if (records.length < 2) return '';
    final latest = records[0]['kilo'] as num;
    final previous = records[1]['kilo'] as num;
    final change = latest - previous;
    if (change > 0) {
      return l10n.kgThisMonth(change.toStringAsFixed(1));
    }
    return '';
  }

  String _getHeightChange(
    AppLocalizations l10n,
    List<Map<String, dynamic>> records,
  ) {
    if (records.length < 2) return '';
    final latest = records[0]['boy'] as num;
    final previous = records[1]['boy'] as num;
    final change = latest - previous;
    if (change > 0) {
      return l10n.cmThisMonth(change.toStringAsFixed(1));
    }
    return '';
  }

  // SAYAÇLAR KARTI
  // EMZİRME BÖLÜMÜ
  // UYKU BÖLÜMÜ
  Widget _buildNoBabyState(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF2D1A18);
    final subtitleColor = textColor.withValues(alpha: 0.6);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: textColor.withValues(alpha: 0.7),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE8FF).withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: 42,
                    color: Color(0xFFFF998A),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'No baby yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'No baby profile found yet. Tap below to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openAddBabySheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add baby'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF998A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddBabySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBabySheet(
        onBabyAdded: () {
          _loadBabyInfo();
          widget.onDataChanged?.call();
        },
      ),
    );
  }

  String _localizedDiaperType(AppLocalizations l10n, dynamic rawType) {
    final diaperType = VeriYonetici.normalizeDiaperType(rawType);
    switch (diaperType) {
      case 'wet':
        return l10n.wet;
      case 'dirty':
        return l10n.dirty;
      default:
        return l10n.both;
    }
  }

  String _timeAgo(AppLocalizations l10n, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.isNegative || diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
