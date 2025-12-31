import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../models/ikonlar.dart';

class RaporScreen extends StatefulWidget {
  const RaporScreen({super.key});

  @override
  State<RaporScreen> createState() => _RaporScreenState();
}

class _RaporScreenState extends State<RaporScreen> {
  bool _isWeekly = true;
  bool _isLoading = false;

  // İstatistik verileri
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  void _calculateStats() {
    final now = DateTime.now();
    final startDate = _isWeekly
        ? now.subtract(const Duration(days: 7))
        : DateTime(now.year, now.month - 1, now.day);

    // Mama kayıtları
    final mamaKayitlari = VeriYonetici.getMamaKayitlari()
        .where((k) => (k['tarih'] as DateTime).isAfter(startDate))
        .toList();

    // Emzirme istatistikleri
    final emzirmeKayitlari = mamaKayitlari
        .where((k) => k['tur'] == 'Anne Sütü')
        .toList();
    int toplamEmzirme = emzirmeKayitlari.length;
    int toplamSolDk = 0;
    int toplamSagDk = 0;
    for (var k in emzirmeKayitlari) {
      toplamSolDk += (k['solDakika'] as int?) ?? 0;
      toplamSagDk += (k['sagDakika'] as int?) ?? 0;
    }

    // Biberon/Formül
    final biberonKayitlari = mamaKayitlari
        .where((k) => k['tur'] != 'Anne Sütü')
        .toList();
    int toplamBiberonMl = 0;
    int toplamFormulMl = 0;
    for (var k in biberonKayitlari) {
      final miktar = (k['miktar'] as int?) ?? 0;
      if (k['tur'] == 'Formül') {
        toplamFormulMl += miktar;
      } else {
        toplamBiberonMl += miktar;
      }
    }

    // Bez kayıtları
    final kakaKayitlari = VeriYonetici.getKakaKayitlari()
        .where((k) => (k['tarih'] as DateTime).isAfter(startDate))
        .toList();
    int islak = kakaKayitlari.where((k) => k['tur'] == Dil.islak).length;
    int kirli = kakaKayitlari.where((k) => k['tur'] == Dil.kirli).length;
    int ikisi = kakaKayitlari.where((k) => k['tur'] == Dil.ikisiBirden).length;

    // Uyku kayıtları
    final uykuKayitlari = VeriYonetici.getUykuKayitlari()
        .where((k) => (k['bitis'] as DateTime).isAfter(startDate))
        .toList();
    int toplamUykuDakika = 0;
    int enUzunUykuDakika = 0;
    for (var k in uykuKayitlari) {
      final sure = k['sure'] as Duration;
      toplamUykuDakika += sure.inMinutes;
      if (sure.inMinutes > enUzunUykuDakika) {
        enUzunUykuDakika = sure.inMinutes;
      }
    }

    // Büyüme kayıtları
    final boyKiloKayitlari = VeriYonetici.getBoyKiloKayitlari();
    double? sonBoy, sonKilo, oncekiBoy, oncekiKilo;
    if (boyKiloKayitlari.isNotEmpty) {
      sonBoy = (boyKiloKayitlari.first['boy'] as num?)?.toDouble();
      sonKilo = (boyKiloKayitlari.first['kilo'] as num?)?.toDouble();
      if (boyKiloKayitlari.length > 1) {
        oncekiBoy = (boyKiloKayitlari[1]['boy'] as num?)?.toDouble();
        oncekiKilo = (boyKiloKayitlari[1]['kilo'] as num?)?.toDouble();
      }
    }

    final gunSayisi = _isWeekly ? 7 : 30;

    setState(() {
      _stats = {
        'startDate': startDate,
        'endDate': now,
        'gunSayisi': gunSayisi,
        // Emzirme
        'toplamEmzirme': toplamEmzirme,
        'toplamEmzirmeDk': toplamSolDk + toplamSagDk,
        'gunlukEmzirme': (toplamEmzirme / gunSayisi).toStringAsFixed(1),
        'solMemeDk': toplamSolDk,
        'sagMemeDk': toplamSagDk,
        // Biberon
        'toplamBiberonMl': toplamBiberonMl,
        'toplamFormulMl': toplamFormulMl,
        // Bez
        'toplamBez': kakaKayitlari.length,
        'gunlukBez': (kakaKayitlari.length / gunSayisi).toStringAsFixed(1),
        'islak': islak,
        'kirli': kirli,
        'ikisi': ikisi,
        // Uyku
        'toplamUykuSaat': (toplamUykuDakika / 60).toStringAsFixed(1),
        'gunlukUykuSaat': (toplamUykuDakika / 60 / gunSayisi).toStringAsFixed(
          1,
        ),
        'enUzunUyku':
            '${enUzunUykuDakika ~/ 60} sa ${enUzunUykuDakika % 60} dk',
        'uykuSayisi': uykuKayitlari.length,
        // Büyüme
        'boy': sonBoy,
        'kilo': sonKilo,
        'boyDegisim': sonBoy != null && oncekiBoy != null
            ? sonBoy - oncekiBoy
            : null,
        'kiloDegisim': sonKilo != null && oncekiKilo != null
            ? sonKilo - oncekiKilo
            : null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1625) : const Color(0xFFFFF9F5);
    final cardColor = isDark ? const Color(0xFF2A2435) : Colors.white;
    final textColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF2D2D2D);
    final subtitleColor = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF888888);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(isDark, cardColor, textColor),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFeedingCard(
                      isDark,
                      cardColor,
                      textColor,
                      subtitleColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDiaperCard(
                      isDark,
                      cardColor,
                      textColor,
                      subtitleColor,
                    ),
                    const SizedBox(height: 16),
                    _buildSleepCard(
                      isDark,
                      cardColor,
                      textColor,
                      subtitleColor,
                    ),
                    const SizedBox(height: 16),
                    _buildGrowthCard(
                      isDark,
                      cardColor,
                      textColor,
                      subtitleColor,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // EXPORT BUTTON
      bottomSheet: _buildExportButton(isDark),
    );
  }

  Widget _buildHeader(bool isDark, Color cardColor, Color textColor) {
    final startDate = _stats['startDate'] as DateTime?;
    final endDate = _stats['endDate'] as DateTime?;
    String dateRange = '';
    if (startDate != null && endDate != null) {
      dateRange =
          '${startDate.day} ${Dil.aylar[startDate.month - 1]} - ${endDate.day} ${Dil.aylar[endDate.month - 1]} ${endDate.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3445)
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: isDark ? Colors.white70 : const Color(0xFF666666),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isWeekly ? 'Haftalık Rapor' : 'Aylık Rapor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3445) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isWeekly = true);
                      _calculateStats();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isWeekly
                            ? (isDark ? const Color(0xFF4A4455) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _isWeekly
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Haftalık',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isWeekly
                              ? const Color(0xFFFF8AC1)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isWeekly = false);
                      _calculateStats();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isWeekly
                            ? (isDark ? const Color(0xFF4A4455) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_isWeekly
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Aylık',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: !_isWeekly
                              ? const Color(0xFFFF8AC1)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BESLENME KARTI
  Widget _buildFeedingCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top gradient accent
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB3D9), Color(0xFFFF8FAB)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB3D9), Color(0xFFFF8FAB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.breastfeeding(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Beslenme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['toplamEmzirme'] ?? 0}',
                        'Toplam Emzirme',
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF8FAB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['toplamEmzirmeDk'] ?? 0} dk',
                        'Toplam Süre',
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF8FAB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['gunlukEmzirme'] ?? 0}',
                        'Günlük Ort.',
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF8FAB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${((_stats['toplamEmzirmeDk'] ?? 0) / ((_stats['toplamEmzirme'] ?? 1) == 0 ? 1 : _stats['toplamEmzirme'])).toStringAsFixed(0)} dk',
                        'Ort. Süre',
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF8FAB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Breast stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB3D9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Ikonlar.leftBreast(size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Sol Meme',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['solMemeDk'] ?? 0} dk',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8AC1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFFF8AC1).withOpacity(0.2),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Ikonlar.rightBreast(size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Sağ Meme',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['sagMemeDk'] ?? 0} dk',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8AC1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Bottle stats
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB3D9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Biberon',
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['toplamBiberonMl'] ?? 0} ml',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8AC1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB3D9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Formül',
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['toplamFormulMl'] ?? 0} ml',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8AC1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BEZ DEĞİŞİMİ KARTI
  Widget _buildDiaperCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3D9FF), Color(0xFFA2C4F5)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB3D9FF), Color(0xFFA2C4F5)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.diaperClean(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bez Değişimi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['toplamBez'] ?? 0}',
                        'Toplam',
                        const Color(0xFFB3D9FF),
                        const Color(0xFF6BA3E0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['gunlukBez'] ?? 0}',
                        'Günlük Ort.',
                        const Color(0xFFB3D9FF),
                        const Color(0xFF6BA3E0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Breakdown
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3D9FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Ikonlar.diaperWet(size: 24),
                            const SizedBox(height: 6),
                            Text(
                              '${_stats['islak'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6BA3E0),
                              ),
                            ),
                            Text(
                              'Islak',
                              style: TextStyle(
                                fontSize: 10,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3D9FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Ikonlar.diaperDirty(size: 24),
                            const SizedBox(height: 6),
                            Text(
                              '${_stats['kirli'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6BA3E0),
                              ),
                            ),
                            Text(
                              'Kirli',
                              style: TextStyle(
                                fontSize: 10,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3D9FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Ikonlar.diaperClean(size: 24),
                            const SizedBox(height: 6),
                            Text(
                              '${_stats['ikisi'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6BA3E0),
                              ),
                            ),
                            Text(
                              'İkisi',
                              style: TextStyle(
                                fontSize: 10,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UYKU KARTI
  Widget _buildSleepCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD9B3FF), Color(0xFFB39DDB)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD9B3FF), Color(0xFFB39DDB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.sleep(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Uyku',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['toplamUykuSaat'] ?? 0} sa',
                        'Toplam',
                        const Color(0xFFD9B3FF),
                        const Color(0xFF9B6FCC),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['gunlukUykuSaat'] ?? 0} sa',
                        'Günlük Ort.',
                        const Color(0xFFD9B3FF),
                        const Color(0xFF9B6FCC),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['enUzunUyku'] ?? '-'}',
                        'En Uzun',
                        const Color(0xFFD9B3FF),
                        const Color(0xFF9B6FCC),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['uykuSayisi'] ?? 0}',
                        'Uyku Sayısı',
                        const Color(0xFFD9B3FF),
                        const Color(0xFF9B6FCC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BÜYÜME KARTI
  Widget _buildGrowthCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final boy = _stats['boy'];
    final kilo = _stats['kilo'];
    final boyDegisim = _stats['boyDegisim'];
    final kiloDegisim = _stats['kiloDegisim'];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3FFD9), Color(0xFF81C784)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB3FFD9), Color(0xFF81C784)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.growth(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Büyüme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3FFD9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Boy',
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              boy != null ? '$boy cm' : '-',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7BC47F),
                              ),
                            ),
                            if (boyDegisim != null)
                              Text(
                                '+${boyDegisim.toStringAsFixed(1)} cm',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3FFD9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Kilo',
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              kilo != null ? '$kilo kg' : '-',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7BC47F),
                              ),
                            ),
                            if (kiloDegisim != null)
                              Text(
                                '+${kiloDegisim.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color color1,
    Color color2,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              LinearGradient(colors: [color1, color2]).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            (isDark ? const Color(0xFF1A1625) : const Color(0xFFFFF9F5))
                .withOpacity(0.95),
          ],
          stops: const [0.0, 0.2],
        ),
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: _isLoading ? null : _exportPDF,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8AC1), Color(0xFF9B6FCC)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8AC1).withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  const Icon(Icons.download, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'PDF Olarak Kaydet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportPDF() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.pink50,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Bebek Takip Raporu',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.pink,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        _isWeekly ? 'Haftalık Rapor' : 'Aylık Rapor',
                        style: const pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Beslenme
                _buildPdfSection('Beslenme', [
                  'Toplam Emzirme: ${_stats['toplamEmzirme']} kez',
                  'Toplam Süre: ${_stats['toplamEmzirmeDk']} dakika',
                  'Sol Meme: ${_stats['solMemeDk']} dk | Sağ Meme: ${_stats['sagMemeDk']} dk',
                  'Biberon: ${_stats['toplamBiberonMl']} ml | Formül: ${_stats['toplamFormulMl']} ml',
                ], PdfColors.pink100),
                pw.SizedBox(height: 16),

                // Bez
                _buildPdfSection('Bez Değişimi', [
                  'Toplam: ${_stats['toplamBez']} kez',
                  'Günlük Ortalama: ${_stats['gunlukBez']} kez',
                  'Islak: ${_stats['islak']} | Kirli: ${_stats['kirli']} | İkisi: ${_stats['ikisi']}',
                ], PdfColors.blue100),
                pw.SizedBox(height: 16),

                // Uyku
                _buildPdfSection('Uyku', [
                  'Toplam Uyku: ${_stats['toplamUykuSaat']} saat',
                  'Günlük Ortalama: ${_stats['gunlukUykuSaat']} saat',
                  'En Uzun Uyku: ${_stats['enUzunUyku']}',
                  'Uyku Sayısı: ${_stats['uykuSayisi']} kez',
                ], PdfColors.purple100),
                pw.SizedBox(height: 16),

                // Büyüme
                _buildPdfSection('Büyüme', [
                  'Boy: ${_stats['boy'] ?? '-'} cm',
                  'Kilo: ${_stats['kilo'] ?? '-'} kg',
                ], PdfColors.green100),

                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Bebek Takip Uygulaması ile oluşturuldu',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      // Web için indirme
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'bebek_rapor_${DateTime.now().millisecondsSinceEpoch}.pdf',
        )
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PDF başarıyla indirildi!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  pw.Widget _buildPdfSection(
    String title,
    List<String> items,
    PdfColor bgColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(item, style: const pw.TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
