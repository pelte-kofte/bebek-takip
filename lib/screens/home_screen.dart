import 'package:flutter/material.dart';
import 'dart:async';
import '../models/veri_yonetici.dart';
import '../models/timer_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../widgets/decorative_background.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const HomeScreen({super.key, this.onDataChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _emzirmeKaydediliyor = false;
  bool _uykuKaydediliyor = false;
  bool _showGrowthChart = true;

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
    final cardColor = isDark ? AppColors.bgDarkCard : AppColors.bgLightCard;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final mamaKayitlari = VeriYonetici.getMamaKayitlari();
    final kakaKayitlari = VeriYonetici.getKakaKayitlari();
    final uykuKayitlari = VeriYonetici.getUykuKayitlari();
    final boyKiloKayitlari = VeriYonetici.getBoyKiloKayitlari();

    final timeline = _buildTimeline(
      mamaKayitlari,
      kakaKayitlari,
      uykuKayitlari,
    );

    Map<String, dynamic>? sonOlcum;
    if (boyKiloKayitlari.isNotEmpty) {
      sonOlcum = boyKiloKayitlari.first;
    }

    return Scaffold(
      body: DecorativeBackground(
        variant: BackgroundVariant.home,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Ikonlar.cuddle(size: 32)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bebeğim',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (sonOlcum != null)
                            Text(
                              '${sonOlcum['boy']} cm • ${sonOlcum['kilo']} kg',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            )
                          else
                            Text(
                              'Hoş geldin!',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Ikonlar.notifications(size: 28),
                      ),
                    ],
                  ),
                ),

                // SAYAÇLAR KARTI
                _buildSayaclarKarti(
                  cardColor,
                  textColor,
                  subtitleColor,
                  isDark,
                ),
                const SizedBox(height: 24),

                // SON AKTİVİTELER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    Dil.sonAktiviteler,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Son Aktiviteler Kartları
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLastActionCard(
                          Ikonlar.bottle(size: 24),
                          Dil.sonBeslenme,
                          mamaKayitlari.isNotEmpty
                              ? _timeAgo(mamaKayitlari.first['tarih'])
                              : '-',
                          _getMamaDetail(
                            mamaKayitlari.isNotEmpty
                                ? mamaKayitlari.first
                                : null,
                          ),
                          AppColors.accentPeach,
                          cardColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLastActionCard(
                          Ikonlar.sleepingMoon(size: 28),
                          Dil.sonUyku,
                          uykuKayitlari.isNotEmpty
                              ? _timeAgo(uykuKayitlari.first['bitis'])
                              : '-',
                          uykuKayitlari.isNotEmpty
                              ? _formatDuration(uykuKayitlari.first['sure'])
                              : '',
                          AppColors.accentLavender,
                          cardColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLastActionCard(
                          Ikonlar.diaperClean(size: 24),
                          Dil.sonBezDegisimi,
                          kakaKayitlari.isNotEmpty
                              ? _timeAgo(kakaKayitlari.first['tarih'])
                              : '-',
                          kakaKayitlari.isNotEmpty
                              ? kakaKayitlari.first['tur']
                              : '',
                          AppColors.accentBlue,
                          cardColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ZAMAN ÇİZELGESİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Dil.zaman,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          Dil.son24Saat,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (timeline.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Ikonlar.timer(size: 48),
                          const SizedBox(height: 16),
                          Text(
                            Dil.henuzKayitYok,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: timeline.length > 5 ? 5 : timeline.length,
                    itemBuilder: (context, index) => _buildTimelineItem(
                      timeline[index],
                      textColor,
                      subtitleColor,
                      isDark,
                    ),
                  ),
                const SizedBox(height: 28),

                // BÜYÜME TAKİBİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Ikonlar.growth(size: 28),
                          const SizedBox(width: 10),
                          Text(
                            Dil.buyumeTakibi,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showGrowthChart = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _showGrowthChart
                                      ? AppColors.accentGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.show_chart,
                                  size: 20,
                                  color: _showGrowthChart
                                      ? Colors.white
                                      : subtitleColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showGrowthChart = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: !_showGrowthChart
                                      ? AppColors.accentGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.list,
                                  size: 20,
                                  color: !_showGrowthChart
                                      ? Colors.white
                                      : subtitleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (boyKiloKayitlari.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Ikonlar.growth(size: 28),
                          const SizedBox(height: 16),
                          Text(
                            Dil.henuzOlcumYok,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_showGrowthChart)
                  _buildGrowthChart(boyKiloKayitlari, cardColor, textColor)
                else
                  _buildGrowthList(
                    boyKiloKayitlari,
                    cardColor,
                    textColor,
                    subtitleColor,
                  ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
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
            color: isDark ? Colors.black26 : AppColors.primary.withOpacity(0.1),
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
                ? AppColors.accentLavender.withOpacity(0.3)
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
            color: color.withOpacity(0.15),
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
              color: color.withOpacity(0.2),
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
                  color: lineColor.withOpacity(0.3),
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
            Divider(height: 1, color: subtitleColor.withOpacity(0.2)),
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
                color: AppColors.accentGreen.withOpacity(0.2),
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
      ..color = color.withOpacity(0.15)
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
