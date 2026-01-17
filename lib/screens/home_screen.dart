import 'package:flutter/material.dart';
import 'dart:async';
import '../models/veri_yonetici.dart';
import '../models/timer_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'add_screen.dart';
import 'settings_screen.dart';
import 'activities_screen.dart';
import 'add_growth_screen.dart';
import 'baby_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const HomeScreen({super.key, this.onDataChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _emzirmeKaydediliyor = false;
  bool _uykuKaydediliyor = false;

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

  @override
  void initState() {
    super.initState();
    _setupTimerListeners();
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
    _emzirmeSubscription?.cancel();
    _uykuSubscription?.cancel();
    super.dispose();
  }

  // EMZİRME FONKSİYONLARI
  void _startSol() async {
    await _timerYonetici.switchEmzirmeSide('sol');
  }

  void _startSag() async {
    await _timerYonetici.switchEmzirmeSide('sag');
  }

  void _stopEmzirmeAndSave() async {
    final data = await _timerYonetici.stopEmzirme();

    if (data == null) {
      setState(() {
        _solAktif = false;
        _sagAktif = false;
      });
      return;
    }

    final solSaniye = data['solSaniye'] as int;
    final sagSaniye = data['sagSaniye'] as int;

    if (solSaniye == 0 && sagSaniye == 0) {
      setState(() {
        _solAktif = false;
        _sagAktif = false;
      });
      return;
    }

    setState(() {
      _emzirmeKaydediliyor = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

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

    final kaydedilenSol = solDakika > 0 ? solDakika : (solSaniye > 0 ? 1 : 0);
    final kaydedilenSag = sagDakika > 0 ? sagDakika : (sagSaniye > 0 ? 1 : 0);

    setState(() {
      _solAktif = false;
      _sagAktif = false;
      _solSaniye = 0;
      _sagSaniye = 0;
      _emzirmeKaydediliyor = false;
    });

    widget.onDataChanged?.call();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Emzirme kaydedildi: Sol ${kaydedilenSol}dk, Sağ ${kaydedilenSag}dk',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // UYKU FONKSİYONLARI
  void _startUyku() async {
    await _timerYonetici.startUyku();
  }

  void _stopUykuAndSave() async {
    final data = await _timerYonetici.stopUyku();

    if (data == null || _uykuSaniye < 60) {
      setState(() {
        _uykuSaniye = 0;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Uyku 1 dakikadan kısa, kaydedilmedi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _uykuKaydediliyor = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final kayitlar = VeriYonetici.getUykuKayitlari();
    kayitlar.insert(0, {
      'baslangic': data['baslangic'],
      'bitis': data['bitis'],
      'sure': data['sure'],
    });

    await VeriYonetici.saveUykuKayitlari(kayitlar);

    final dakika = _uykuSaniye ~/ 60;
    final saat = dakika ~/ 60;
    final kalanDakika = dakika % 60;

    setState(() {
      _uykuSaniye = 0;
      _uykuKaydediliyor = false;
    });

    widget.onDataChanged?.call();

    String sureText = saat > 0 ? '$saat sa $kalanDakika dk' : '$dakika dk';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Uyku kaydedildi: $sureText'),
        backgroundColor: AppColors.accentLavender,
      ),
    );
  }

  String _formatSaniye(int saniye) {
    final dk = saniye ~/ 60;
    final sn = saniye % 60;
    return '${dk.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  String _formatUykuSaniye(int saniye) {
    final saat = saniye ~/ 3600;
    final dk = (saniye % 3600) ~/ 60;
    final sn = saniye % 60;
    return '${saat.toString().padLeft(2, '0')}:${dk.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  bool get _emzirmeAktif => _timerYonetici.isEmzirmeActive;

  bool get _uykuAktif => _timerYonetici.isUykuActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D1A18);
    final subtitleColor = textColor.withValues(alpha: 0.6);

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
          if (!isDark)
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
                          color: const Color(0xFFEBE8FF).withValues(alpha: 0.5),
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
                          color: const Color(0xFFEBE8FF).withValues(alpha: 0.5),
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
                        // Baby profile area (tappable)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BabyProfileScreen(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFEBE8FF),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/icons/illustration/baby_face.png',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFFEBE8FF),
                                      child: const Icon(
                                        Icons.child_care,
                                        color: Color(0xFFFF998A),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sofia',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    '4 months old',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                            icon: Icons.child_care,
                            iconColor: const Color(0xFFFF998A),
                            label: 'FEEDING',
                            time: _formatSaniye(_solSaniye + _sagSaniye),
                            lastActivity: _getLastFeedingTime(mamaKayitlari),
                            isActive: _emzirmeAktif,
                            isDark: isDark,
                            buttons: _emzirmeAktif
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _solAktif ? null : _startSol,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _solAktif
                                                      ? const Color(0xFFFF998A)
                                                      : const Color(0xFFFFF8F0),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'LEFT',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: _solAktif
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFFFF998A),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _sagAktif ? null : _startSag,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _sagAktif
                                                      ? const Color(0xFFFF998A)
                                                      : const Color(0xFFFFF8F0),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'RIGHT',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: _sagAktif
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFFFF998A),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
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
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'STOP & SAVE',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                                            child: const Text(
                                              'LEFT',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
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
                                              color: const Color(0xFFFFF8F0),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'RIGHT',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF998A),
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
                            icon: Icons.bedtime,
                            iconColor: const Color(0xFF7A749E),
                            label: 'SLEEPING',
                            time: _formatSaniye(_uykuSaniye),
                            lastActivity: _getLastSleepTime(
                                VeriYonetici.getUykuKayitlari()),
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
                                  color: const Color(0xFFEBE8FF),
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
                                          color: Color(0xFF7A749E),
                                        ),
                                      ),
                                    Text(
                                      _uykuAktif ? 'ACTIVE' : 'START',
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

                  const SizedBox(height: 16),

                  // LAST ACTIVITY SUMMARY
                  SizedBox(
                    height: 100,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToActivities(ActivityType.mama),
                          child: _buildSummaryCard(
                            label: 'LAST FED',
                            value: _getLastFeedingValue(mamaKayitlari),
                            progress: _getTimeProgress(mamaKayitlari.isNotEmpty ? mamaKayitlari.first['tarih'] as DateTime? : null),
                            progressColor: const Color(0xFFFF998A),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _navigateToActivities(ActivityType.bez),
                          child: _buildSummaryCard(
                            label: 'LAST DIAPER',
                            value: _getLastDiaperValue(kakaKayitlari),
                            progress: _getTimeProgress(kakaKayitlari.isNotEmpty ? kakaKayitlari.first['tarih'] as DateTime? : null),
                            progressColor: const Color(0xFF7A749E),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _navigateToActivities(ActivityType.uyku),
                          child: _buildSummaryCard(
                            label: 'LAST SLEEP',
                            value: _getLastSleepValue(VeriYonetici.getUykuKayitlari()),
                            progress: _getTimeProgress(VeriYonetici.getUykuKayitlari().isNotEmpty ? VeriYonetici.getUykuKayitlari().first['bitis'] as DateTime? : null),
                            progressColor: const Color(0xFF7A749E),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // RECENT ACTIVITY HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT ACTIVITY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to Activities tab
                            DefaultTabController.of(context).animateTo(1);
                          },
                          child: const Text(
                            'SEE HISTORY',
                            style: TextStyle(
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
                    child: _buildRecentActivitiesList(
                      mamaKayitlari,
                      kakaKayitlari,
                      VeriYonetici.getUykuKayitlari(),
                      isDark,
                      textColor,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // GROWTH TRACKING SECTION
                  _buildGrowthSection(isDark, textColor, subtitleColor),

                  const SizedBox(height: 120),
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
    required IconData icon,
    required Color iconColor,
    required String label,
    required String time,
    required String lastActivity,
    required bool isActive,
    required bool isDark,
    required Widget buttons,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF1D9F5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFFF8F0).withValues(alpha: 0.5),
        ),
        boxShadow: const [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 24),
            ],
          ),
          const SizedBox(height: 16),
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
          Text(
            time,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
              color: isDark ? Colors.white : const Color(0xFF2D1A18),
            ),
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
          const SizedBox(height: 16),
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
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D1A18) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
            ? const Color(0xFF3D2A28)
            : const Color(0xFFF0EBE8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
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
                  color: progressColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: (isDark
                ? const Color(0xFFFCF8F8)
                : const Color(0xFF1D0E0C)
              ).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                ? const Color(0xFFFCF8F8)
                : const Color(0xFF1D0E0C),
            ),
          ),
        ],
      ),
    );
  }

  // ACTIVITY ITEM
  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF2A2A3E) : Colors.white)
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEBE8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D1A18),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  // RECENT ACTIVITIES LIST (last 24 hours)
  Widget _buildRecentActivitiesList(
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
        timeline.add({
          'type': 'mama',
          'tarih': tarih,
          'data': k,
        });
      }
    }

    // Add kaka activities
    for (var k in kaka) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({
          'type': 'kaka',
          'tarih': tarih,
          'data': k,
        });
      }
    }

    // Add uyku activities
    for (var k in uyku) {
      final tarih = k['bitis'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({
          'type': 'uyku',
          'tarih': tarih,
          'data': k,
        });
      }
    }

    // Sort by time descending
    timeline.sort(
      (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
    );

    if (timeline.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No activities in the last 24 hours',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        timeline.length > 5 ? 5 : timeline.length,
        (index) {
          final item = timeline[index];
          final type = item['type'] as String;
          final tarih = item['tarih'] as DateTime;
          final data = item['data'] as Map<String, dynamic>;

          IconData icon;
          Color iconColor;
          String title;
          String subtitle;

          switch (type) {
            case 'mama':
              icon = Icons.restaurant;
              iconColor = const Color(0xFFFF998A);
              final tur = data['tur'] as String? ?? '';
              if (tur == 'Anne Sütü') {
                title = 'Breastfeeding';
                final sol = data['solDakika'] ?? 0;
                final sag = data['sagDakika'] ?? 0;
                subtitle = 'L ${sol}min • R ${sag}min';
              } else {
                title = 'Bottle Feeding';
                subtitle = '${data['miktar']} ml';
              }
              break;
            case 'kaka':
              icon = Icons.water_drop;
              iconColor = const Color(0xFF7A749E);
              title = 'Diaper Change';
              subtitle = data['tur'] ?? '';
              break;
            case 'uyku':
              icon = Icons.bedtime;
              iconColor = const Color(0xFF7A749E);
              title = 'Sleep';
              final sure = data['sure'] as Duration;
              final hours = sure.inHours;
              final minutes = sure.inMinutes % 60;
              subtitle = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
              break;
            default:
              icon = Icons.circle;
              iconColor = Colors.grey;
              title = 'Activity';
              subtitle = '';
          }

          return Padding(
            padding: EdgeInsets.only(bottom: index < timeline.length - 1 ? 12 : 0),
            child: _buildActivityItem(
              icon: icon,
              iconColor: iconColor,
              title: '$title • ${_timeAgo(tarih)}',
              subtitle: subtitle,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  // GROWTH SECTION
  Widget _buildGrowthSection(
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
          color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFFF8F0).withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.straighten,
                color: Color(0xFFFF998A),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Track your baby\'s growth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add weight and height measurements',
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                ),
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
                  child: const Text(
                    'Add first measurement',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
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
                    'Growth Tracking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Last updated ${_formatDaysAgo(tarih)}',
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
                  color: const Color(0xFFEBE8FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF7A749E),
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
                    label: 'WEIGHT',
                    value: '${latest['kilo']}',
                    unit: 'kg',
                    change: _getWeightChange(boyKiloKayitlari),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGrowthCard(
                    icon: Icons.straighten,
                    label: 'HEIGHT',
                    value: '${latest['boy']}',
                    unit: 'cm',
                    change: _getHeightChange(boyKiloKayitlari),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // View charts button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () {
              // Could navigate to detailed growth screen
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFEBE8FF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'VIEW GROWTH CHARTS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFF7A749E),
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
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
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
                Icon(
                  Icons.arrow_upward,
                  color: Colors.green,
                  size: 12,
                ),
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
  String _getLastFeedingTime(List<Map<String, dynamic>> mama) {
    if (mama.isEmpty) return '';
    final tarih = mama.first['tarih'] as DateTime;
    return 'Last feed: ${_timeAgo(tarih)}';
  }

  String _getLastSleepTime(List<Map<String, dynamic>> uyku) {
    if (uyku.isEmpty) return '';
    final tarih = uyku.first['bitis'] as DateTime;
    return 'Last sleep: ${_timeAgo(tarih)}';
  }

  String _getLastFeedingValue(List<Map<String, dynamic>> mama) {
    if (mama.isEmpty) return 'Henüz kayıt yok';
    final tarih = mama.first['tarih'] as DateTime;
    final diff = DateTime.now().difference(tarih);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return '${hours}h ${minutes}m ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  String _getLastDiaperValue(List<Map<String, dynamic>> kaka) {
    if (kaka.isEmpty) return 'Henüz kayıt yok';
    final tarih = kaka.first['tarih'] as DateTime;
    final diff = DateTime.now().difference(tarih);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return '${hours}h ${minutes}m ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  String _getLastSleepValue(List<Map<String, dynamic>> uyku) {
    if (uyku.isEmpty) return 'Henüz kayıt yok';
    final tarih = uyku.first['bitis'] as DateTime;
    final diff = DateTime.now().difference(tarih);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return '${hours}h ${minutes}m ago';
    } else {
      return '${diff.inDays}d ago';
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
        builder: (context) => ActivitiesScreen(initialTab: tab),
      ),
    );
  }

  void _navigateToAddGrowth() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGrowthScreen(onSaved: widget.onDataChanged),
      ),
    );
    setState(() {});
  }

  String _getDailySleepTotal(List<Map<String, dynamic>> uyku) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    int totalMinutes = 0;
    for (var entry in uyku) {
      final bitis = entry['bitis'] as DateTime;
      if (bitis.isAfter(todayStart)) {
        final sure = entry['sure'] as Duration;
        totalMinutes += sure.inMinutes;
      }
    }

    if (totalMinutes == 0) return 'No sleep';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _formatDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }

  String _getWeightChange(List<Map<String, dynamic>> records) {
    if (records.length < 2) return '';
    final latest = records[0]['kilo'] as num;
    final previous = records[1]['kilo'] as num;
    final change = latest - previous;
    if (change > 0) {
      return '+${change.toStringAsFixed(1)}kg this month';
    }
    return '';
  }

  String _getHeightChange(List<Map<String, dynamic>> records) {
    if (records.length < 2) return '';
    final latest = records[0]['boy'] as num;
    final previous = records[1]['boy'] as num;
    final change = latest - previous;
    if (change > 0) {
      return '+${change.toStringAsFixed(1)}cm this month';
    }
    return '';
  }

  // SAYAÇLAR KARTI
  Widget _buildSayaclarKarti(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.primary.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildEmzirmeBolumu(textColor, subtitleColor, isDark),
          ),
          Container(
            width: 1,
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          Expanded(child: _buildUykuBolumu(textColor, subtitleColor, isDark)),
        ],
      ),
    );
  }

  // EMZİRME BÖLÜMÜ
  Widget _buildEmzirmeBolumu(
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Ikonlar.nursing(size: 28),
            const SizedBox(width: 8),
            Text(
              Dil.emzirme,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _solAktif
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        _startSol();
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _solAktif
                        ? AppColors.primary
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _solAktif ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Ikonlar.nursing(size: 28),
                      const SizedBox(height: 6),
                      Text(
                        'Sol',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _solAktif ? Colors.white : textColor,
                        ),
                      ),
                      Text(
                        _formatSaniye(_solSaniye),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _solAktif ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _sagAktif
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        _startSag();
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _sagAktif
                        ? AppColors.primary
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _sagAktif ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Ikonlar.nursing(size: 28),
                      const SizedBox(height: 6),
                      Text(
                        'Sağ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _sagAktif ? Colors.white : textColor,
                        ),
                      ),
                      Text(
                        _formatSaniye(_sagSaniye),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _sagAktif ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (_emzirmeAktif)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _emzirmeKaydediliyor
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _stopEmzirmeAndSave();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _emzirmeKaydediliyor
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Kaydet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          )
        else
          Text(
            'Başlatmak için dokun',
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
      ],
    );
  }

  // UYKU BÖLÜMÜ
  Widget _buildUykuBolumu(Color textColor, Color subtitleColor, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Ikonlar.sleepingMoon(size: 26),
            const SizedBox(width: 8),
            Text(
              Dil.uyku,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _uykuAktif
                ? AppColors.accentLavender.withValues(alpha:0.3)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(16),
            border: _uykuAktif
                ? Border.all(color: AppColors.accentLavender, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Text(
                _formatUykuSaniye(_uykuSaniye),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _uykuAktif ? AppColors.accentLavender : textColor,
                ),
              ),
              if (_uykuAktif)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Ikonlar.sleepingMoon(size: 28),
                    const SizedBox(width: 6),
                    Text(
                      'Uyuyor...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.accentLavender,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _uykuKaydediliyor
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    if (_uykuAktif) {
                      _stopUykuAndSave();
                    } else {
                      _startUyku();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _uykuAktif
                  ? Colors.orange
                  : AppColors.accentLavender,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _uykuKaydediliyor
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _uykuAktif ? 'Uyandı 🌞' : 'Uyudu 🌙',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _getMamaDetail(Map<String, dynamic>? kayit) {
    if (kayit == null) return '';
    final tur = kayit['tur'] as String? ?? '';
    if (tur == 'Anne Sütü') {
      final sol = kayit['solDakika'] ?? 0;
      final sag = kayit['sagDakika'] ?? 0;
      return 'Sol ${sol}dk • Sağ ${sag}dk';
    } else {
      return '${kayit['miktar']} ml';
    }
  }

  Widget _buildLastActionCard(
    Widget icon,
    String title,
    String value,
    String detail,
    Color color,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    Map<String, dynamic> item,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    final type = item['type'] as String;
    final time = item['time'] as String;

    Color lineColor;
    Widget icon;
    String title;
    String subtitle;

    switch (type) {
      case 'mama':
        lineColor = AppColors.accentPeach;
        final tur = item['tur'] as String? ?? '';
        final sol = item['solDakika'] ?? 0;
        final sag = item['sagDakika'] ?? 0;
        final miktar = item['miktar'] ?? 0;

        if (tur == 'Anne Sütü') {
          icon = Ikonlar.nursing(size: 28);
          title = Dil.emzirme;
          subtitle = 'Sol ${sol}dk • Sağ ${sag}dk';
        } else if (tur == 'Formül') {
          icon = Ikonlar.bottle(size: 24);
          title = Dil.formula;
          subtitle = '$miktar ml';
        } else {
          icon = Ikonlar.bottle(size: 24);
          title = Dil.biberon;
          subtitle = '$miktar ml';
        }
        break;
      case 'kaka':
        lineColor = AppColors.accentBlue;
        final bezTur = item['tur'] ?? '';
        if (bezTur == Dil.islak) {
          icon = Ikonlar.diaperWet(size: 24);
        } else if (bezTur == Dil.kirli) {
          icon = Ikonlar.diaperDirty(size: 24);
        } else {
          icon = Ikonlar.diaperClean(size: 24);
        }
        title = Dil.bezDegisimi;
        subtitle = bezTur;
        break;
      case 'uyku':
        lineColor = AppColors.accentLavender;
        icon = Ikonlar.sleepingMoon(size: 28);
        title = Dil.uyku;
        subtitle = item['sure'] ?? '';
        break;
      default:
        lineColor = Colors.grey;
        icon = Ikonlar.timer(size: 24);
        title = 'Aktivite';
        subtitle = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha:0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: lineColor, width: 3),
                ),
              ),
              Container(
                width: 3,
                height: 50,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: lineColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(
    List<Map<String, dynamic>> kayitlar,
    Color cardColor,
    Color textColor,
  ) {
    final son6 = kayitlar.take(6).toList().reversed.toList();
    if (son6.isEmpty) return const SizedBox();

    double maxBoy = 0, maxKilo = 0;
    for (var k in son6) {
      if ((k['boy'] as num) > maxBoy) maxBoy = (k['boy'] as num).toDouble();
      if ((k['kilo'] as num) > maxKilo) maxKilo = (k['kilo'] as num).toDouble();
    }
    maxBoy *= 1.1;
    maxKilo *= 1.1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.straighten, color: Color(0xFF4CAF50), size: 22),
              const SizedBox(width: 10),
              Text(
                '${Dil.boy} (cm)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _ChartPainter(
                data: son6.map((k) => (k['boy'] as num).toDouble()).toList(),
                maxValue: maxBoy,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.monitor_weight,
                color: Color(0xFF2196F3),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                '${Dil.kilo} (kg)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _ChartPainter(
                data: son6.map((k) => (k['kilo'] as num).toDouble()).toList(),
                maxValue: maxKilo,
                color: const Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthList(
    List<Map<String, dynamic>> kayitlar,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kayitlar.length > 5 ? 5 : kayitlar.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: subtitleColor.withValues(alpha:0.2)),
        itemBuilder: (context, index) {
          final k = kayitlar[index];
          final tarih = k['tarih'] as DateTime;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Ikonlar.growth(size: 32)),
            ),
            title: Text(
              '${tarih.day} ${Dil.aylar[tarih.month - 1]} ${tarih.year}',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              '${Dil.boy}: ${k['boy']} cm • ${Dil.kilo}: ${k['kilo']} kg',
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimeline(
    List<Map<String, dynamic>> mama,
    List<Map<String, dynamic>> kaka,
    List<Map<String, dynamic>> uyku,
  ) {
    final List<Map<String, dynamic>> timeline = [];
    final son24Saat = DateTime.now().subtract(const Duration(hours: 24));

    for (var k in mama) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({
          'type': 'mama',
          'tarih': tarih,
          'time': _formatTime(tarih),
          'miktar': k['miktar'] ?? 0,
          'tur': k['tur'] ?? '',
          'solDakika': k['solDakika'] ?? 0,
          'sagDakika': k['sagDakika'] ?? 0,
        });
      }
    }
    for (var k in kaka) {
      final tarih = k['tarih'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({
          'type': 'kaka',
          'tarih': tarih,
          'time': _formatTime(tarih),
          'tur': k['tur'],
        });
      }
    }
    for (var k in uyku) {
      final tarih = k['bitis'] as DateTime;
      if (tarih.isAfter(son24Saat)) {
        timeline.add({
          'type': 'uyku',
          'tarih': tarih,
          'time': _formatTime(tarih),
          'sure': _formatDuration(k['sure']),
        });
      }
    }

    timeline.sort(
      (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
    );
    return timeline;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return Dil.azOnce;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${Dil.dakikaOnce}';
    if (diff.inHours < 24) return '${diff.inHours} ${Dil.saatOnce}';
    return '${diff.inDays} ${Dil.gunOnce}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '$hours ${Dil.sa} $minutes ${Dil.dk}';
    return '$minutes ${Dil.dk}';
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final Color color;

  _ChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color.withValues(alpha:0.15)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final stepX = data.length > 1 ? size.width / (data.length - 1) : size.width;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 6, dotPaint);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
