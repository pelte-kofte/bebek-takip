import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';
import 'package:flutter/services.dart';

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
  Timer? _emzirmeTimer;
  DateTime? _emzirmeBaslangic;

  // Uyku sayaç değişkenleri
  bool _uykuAktif = false;
  int _uykuSaniye = 0;
  Timer? _uykuTimer;
  DateTime? _uykuBaslangic;

  @override
  void dispose() {
    _emzirmeTimer?.cancel();
    _uykuTimer?.cancel();
    super.dispose();
  }

  // EMZİRME FONKSİYONLARI
  void _startSol() {
    if (_emzirmeBaslangic == null) {
      _emzirmeBaslangic = DateTime.now();
    }
    setState(() {
      _solAktif = true;
      _sagAktif = false;
    });
    _startEmzirmeTimer();
  }

  void _startSag() {
    if (_emzirmeBaslangic == null) {
      _emzirmeBaslangic = DateTime.now();
    }
    setState(() {
      _sagAktif = true;
      _solAktif = false;
    });
    _startEmzirmeTimer();
  }

  void _startEmzirmeTimer() {
    _emzirmeTimer?.cancel();
    _emzirmeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_solAktif) {
          _solSaniye++;
        } else if (_sagAktif) {
          _sagSaniye++;
        }
      });
    });
  }

  void _stopEmzirmeAndSave() async {
    _emzirmeTimer?.cancel();

    if (_solSaniye == 0 && _sagSaniye == 0) {
      setState(() {
        _solAktif = false;
        _sagAktif = false;
        _emzirmeBaslangic = null;
      });
      return;
    }

    // Loading başlat
    setState(() {
      _emzirmeKaydediliyor = true;
    });

    // Kısa bekleme (UX için)
    await Future.delayed(const Duration(milliseconds: 500));

    final solDakika = (_solSaniye / 60).ceil();
    final sagDakika = (_sagSaniye / 60).ceil();

    final kayitlar = VeriYonetici.getMamaKayitlari();
    kayitlar.insert(0, {
      'tarih': _emzirmeBaslangic ?? DateTime.now(),
      'tur': 'Anne Sütü',
      'solDakika': solDakika > 0 ? solDakika : (_solSaniye > 0 ? 1 : 0),
      'sagDakika': sagDakika > 0 ? sagDakika : (_sagSaniye > 0 ? 1 : 0),
      'miktar': 0,
    });

    await VeriYonetici.saveMamaKayitlari(kayitlar);

    final kaydedilenSol = solDakika > 0 ? solDakika : (_solSaniye > 0 ? 1 : 0);
    final kaydedilenSag = sagDakika > 0 ? sagDakika : (_sagSaniye > 0 ? 1 : 0);

    setState(() {
      _solAktif = false;
      _sagAktif = false;
      _solSaniye = 0;
      _sagSaniye = 0;
      _emzirmeBaslangic = null;
      _emzirmeKaydediliyor = false;
    });

    widget.onDataChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Emzirme kaydedildi: Sol ${kaydedilenSol}dk, Sağ ${kaydedilenSag}dk',
        ),
        backgroundColor: const Color(0xFFE91E63),
      ),
    );
  }

  // UYKU FONKSİYONLARI
  void _startUyku() {
    _uykuBaslangic = DateTime.now();
    setState(() {
      _uykuAktif = true;
      _uykuSaniye = 0;
    });
    _uykuTimer?.cancel();
    _uykuTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _uykuSaniye++;
      });
    });
  }

  void _stopUykuAndSave() async {
    _uykuTimer?.cancel();

    if (_uykuSaniye < 60) {
      setState(() {
        _uykuAktif = false;
        _uykuSaniye = 0;
        _uykuBaslangic = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Uyku 1 dakikadan kısa, kaydedilmedi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Loading başlat
    setState(() {
      _uykuKaydediliyor = true;
    });

    // Kısa bekleme (UX için)
    await Future.delayed(const Duration(milliseconds: 500));

    final bitis = DateTime.now();
    final sure = Duration(seconds: _uykuSaniye);

    final kayitlar = VeriYonetici.getUykuKayitlari();
    kayitlar.insert(0, {
      'baslangic': _uykuBaslangic ?? bitis.subtract(sure),
      'bitis': bitis,
      'sure': sure,
    });

    await VeriYonetici.saveUykuKayitlari(kayitlar);

    final dakika = _uykuSaniye ~/ 60;
    final saat = dakika ~/ 60;
    final kalanDakika = dakika % 60;

    setState(() {
      _uykuAktif = false;
      _uykuSaniye = 0;
      _uykuBaslangic = null;
      _uykuKaydediliyor = false;
    });

    widget.onDataChanged?.call();

    String sureText = saat > 0 ? '$saat sa $kalanDakika dk' : '$dakika dk';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Uyku kaydedildi: $sureText'),
        backgroundColor: const Color(0xFF3F51B5),
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

  bool get _emzirmeAktif =>
      _solAktif || _sagAktif || _solSaniye > 0 || _sagSaniye > 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF121212)]
                : [const Color(0xFFFCE4EC), const Color(0xFFF8F8F8)],
          ),
        ),
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
                              ? Colors.pink.shade900
                              : Colors.pink.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('👶', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bebeğim',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (sonOlcum != null)
                            Text(
                              '${sonOlcum['boy']} cm • ${sonOlcum['kilo']} kg',
                              style: TextStyle(
                                fontSize: 12,
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.pink.shade900
                              : Colors.pink.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                ),

                // SAYAÇLAR KARTI (EMZİRME + UYKU)
                _buildSayaclarKarti(
                  cardColor,
                  textColor,
                  subtitleColor,
                  isDark,
                ),
                const SizedBox(height: 16),

                // SON AKTİVİTELER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    Dil.sonAktiviteler,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLastActionCard(
                          Ikonlar.bottle(size: 20),
                          Dil.sonBeslenme,
                          mamaKayitlari.isNotEmpty
                              ? _timeAgo(mamaKayitlari.first['tarih'])
                              : '-',
                          _getMamaDetail(
                            mamaKayitlari.isNotEmpty
                                ? mamaKayitlari.first
                                : null,
                          ),
                          const Color(0xFFFFE0B2),
                          cardColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildLastActionCard(
                          Ikonlar.sleep(size: 20),
                          Dil.sonUyku,
                          uykuKayitlari.isNotEmpty
                              ? _timeAgo(uykuKayitlari.first['bitis'])
                              : '-',
                          uykuKayitlari.isNotEmpty
                              ? _formatDuration(uykuKayitlari.first['sure'])
                              : '',
                          const Color(0xFFE1BEE7),
                          cardColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildLastActionCard(
                          Ikonlar.diaperClean(size: 20),
                          Dil.sonBezDegisimi,
                          kakaKayitlari.isNotEmpty
                              ? _timeAgo(kakaKayitlari.first['tarih'])
                              : '-',
                          kakaKayitlari.isNotEmpty
                              ? kakaKayitlari.first['tur']
                              : '',
                          const Color(0xFFB3E5FC),
                          cardColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ZAMAN ÇİZELGESİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Dil.zaman,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          Dil.son24Saat,
                          style: TextStyle(fontSize: 12, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (timeline.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Ikonlar.timer(size: 48),
                          const SizedBox(height: 12),
                          Text(
                            Dil.henuzKayitYok,
                            style: TextStyle(color: subtitleColor),
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
                const SizedBox(height: 24),

                // BÜYÜME TAKİBİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Ikonlar.growth(size: 24),
                          const SizedBox(width: 8),
                          Text(
                            Dil.buyumeTakibi,
                            style: TextStyle(
                              fontSize: 18,
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
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _showGrowthChart
                                      ? const Color(0xFF4CAF50)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.show_chart,
                                  size: 18,
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
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: !_showGrowthChart
                                      ? const Color(0xFF4CAF50)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.list,
                                  size: 18,
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
                const SizedBox(height: 12),

                if (boyKiloKayitlari.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Ikonlar.growth(size: 48),
                          const SizedBox(height: 12),
                          Text(
                            Dil.henuzOlcumYok,
                            style: TextStyle(color: subtitleColor),
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

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SAYAÇLAR KARTI (EMZİRME + UYKU YAN YANA)
  Widget _buildSayaclarKarti(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOL: EMZİRME
          Expanded(
            child: _buildEmzirmeBolumu(textColor, subtitleColor, isDark),
          ),
          // AYIRICI ÇİZGİ
          Container(
            width: 1,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          // SAĞ: UYKU
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
            Ikonlar.breastfeeding(size: 24),
            const SizedBox(width: 6),
            Text(
              Dil.emzirme,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sol ve Sağ butonları
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _solAktif
                        ? const Color(0xFFE91E63)
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Ikonlar.leftBreast(
                        size: 28,
                        color: _solAktif ? Colors.white : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sol',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _solAktif ? Colors.white : textColor,
                        ),
                      ),
                      Text(
                        _formatSaniye(_solSaniye),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _solAktif
                              ? Colors.white
                              : const Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _sagAktif
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        _startSag();
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _sagAktif
                        ? const Color(0xFFE91E63)
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Ikonlar.rightBreast(
                        size: 28,
                        color: _sagAktif ? Colors.white : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sağ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _sagAktif ? Colors.white : textColor,
                        ),
                      ),
                      Text(
                        _formatSaniye(_sagSaniye),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _sagAktif
                              ? Colors.white
                              : const Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Durdur ve Kaydet
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
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _emzirmeKaydediliyor
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Kaydet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          )
        else
          Text(
            'Başlatmak için dokun',
            style: TextStyle(fontSize: 10, color: subtitleColor),
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
            Ikonlar.sleep(size: 24),
            const SizedBox(width: 6),
            Text(
              Dil.uyku,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sayaç gösterimi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _uykuAktif
                ? const Color(0xFF3F51B5).withAlpha(30)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: _uykuAktif
                ? Border.all(color: const Color(0xFF3F51B5), width: 2)
                : null,
          ),
          child: Column(
            children: [
              Text(
                _formatUykuSaniye(_uykuSaniye),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _uykuAktif ? const Color(0xFF3F51B5) : textColor,
                ),
              ),
              if (_uykuAktif)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Ikonlar.sleep(size: 16, color: const Color(0xFF3F51B5)),
                    const SizedBox(width: 4),
                    const Text(
                      'Uyuyor...',
                      style: TextStyle(fontSize: 12, color: Color(0xFF3F51B5)),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Başlat / Uyandı butonu
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
                  : const Color(0xFF3F51B5),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _uykuKaydediliyor
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _uykuAktif ? 'Uyandı 🌞' : 'Uyudu 🌙',
                    style: const TextStyle(
                      fontSize: 12,
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
      height: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: subtitleColor),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
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
        lineColor = const Color(0xFFFF9800);
        final tur = item['tur'] as String? ?? '';
        final sol = item['solDakika'] ?? 0;
        final sag = item['sagDakika'] ?? 0;
        final miktar = item['miktar'] ?? 0;

        if (tur == 'Anne Sütü') {
          icon = Ikonlar.breastfeeding(size: 20);
          title = Dil.emzirme;
          subtitle = 'Sol ${sol}dk • Sağ ${sag}dk';
        } else if (tur == 'Formül') {
          icon = Ikonlar.bottle(size: 20);
          title = Dil.formula;
          subtitle = '$miktar ml';
        } else {
          icon = Ikonlar.bottle(size: 20);
          title = Dil.biberon;
          subtitle = '$miktar ml';
        }
        break;
      case 'kaka':
        lineColor = const Color(0xFF03A9F4);
        final bezTur = item['tur'] ?? '';
        if (bezTur == Dil.islak) {
          icon = Ikonlar.diaperWet(size: 20);
        } else if (bezTur == Dil.kirli) {
          icon = Ikonlar.diaperDirty(size: 20);
        } else {
          icon = Ikonlar.diaperClean(size: 20);
        }
        title = Dil.bezDegisimi;
        subtitle = bezTur;
        break;
      case 'uyku':
        lineColor = const Color(0xFF9C27B0);
        icon = Ikonlar.sleep(size: 20);
        title = Dil.uyku;
        subtitle = item['sure'] ?? '';
        break;
      default:
        lineColor = Colors.grey;
        icon = Ikonlar.timer(size: 20);
        title = 'Aktivite';
        subtitle = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: lineColor.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(color: lineColor, width: 2),
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: lineColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: subtitleColor, fontSize: 11),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.straighten, color: Color(0xFF4CAF50), size: 18),
              const SizedBox(width: 8),
              Text(
                '${Dil.boy} (cm)',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _ChartPainter(
                data: son6.map((k) => (k['boy'] as num).toDouble()).toList(),
                maxValue: maxBoy,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.monitor_weight,
                color: Color(0xFF2196F3),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${Dil.kilo} (kg)',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kayitlar.length > 5 ? 5 : kayitlar.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: subtitleColor.withAlpha(50)),
        itemBuilder: (context, index) {
          final k = kayitlar[index];
          final tarih = k['tarih'] as DateTime;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Ikonlar.growth(size: 24)),
            ),
            title: Text(
              '${tarih.day} ${Dil.aylar[tarih.month - 1]} ${tarih.year}',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              '${Dil.boy}: ${k['boy']} cm • ${Dil.kilo}: ${k['kilo']} kg',
              style: TextStyle(color: subtitleColor, fontSize: 12),
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color.withAlpha(30)
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
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
