import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../models/ikonlar.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class RaporScreen extends StatefulWidget {
  const RaporScreen({super.key});

  @override
  State<RaporScreen> createState() => _RaporScreenState();
}

// Range mode: 0 = weekly, 1 = monthly, 2 = custom
const int _kWeekly = 0;
const int _kMonthly = 1;
const int _kCustom = 2;

class _RaporScreenState extends State<RaporScreen> {
  int _rangeMode = _kWeekly;
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _isLoading = false;
  bool _isCapturing = false;
  final GlobalKey _repaintKey = GlobalKey();

  // Istatistik verileri
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _calculateStats();
    VeriYonetici.dataNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) _calculateStats();
  }

  @override
  void dispose() {
    VeriYonetici.dataNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  /// Opens the Material date-range picker and stores the selection.
  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: (_customStart != null && _customEnd != null)
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customStart = picked.start;
      _customEnd = picked.end;
      _rangeMode = _kCustom;
    });
    _calculateStats();
  }

  void _calculateStats() {
    final now = DateTime.now();
    final DateTime startDate;
    if (_rangeMode == _kWeekly) {
      startDate = now.subtract(const Duration(days: 7));
    } else if (_rangeMode == _kMonthly) {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = _customStart ?? now.subtract(const Duration(days: 7));
    }
    final DateTime endDate = (_rangeMode == _kCustom && _customEnd != null)
        ? _customEnd!
        : now;

    // Mama kayitlari
    final mamaKayitlari = VeriYonetici.getMamaKayitlari()
        .where((k) {
          final t = k['tarih'] as DateTime;
          return t.isAfter(startDate) && !t.isAfter(endDate);
        })
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

    // Kati gida (solid food)
    final solidKayitlari = mamaKayitlari
        .where((k) => k['kategori'] == 'Solid' || k['tur'] == 'Katı Gıda')
        .toList();

    // Biberon/Formul (exclude solid food)
    final biberonKayitlari = mamaKayitlari
        .where(
          (k) =>
              k['tur'] != 'Anne Sütü' &&
              k['kategori'] != 'Solid' &&
              k['tur'] != 'Katı Gıda',
        )
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

    // Bez kayitlari
    final kakaKayitlari = VeriYonetici.getKakaKayitlari()
        .where((k) {
          final t = k['tarih'] as DateTime;
          return t.isAfter(startDate) && !t.isAfter(endDate);
        })
        .toList();
    int islak = kakaKayitlari
        .where(
          (k) =>
              VeriYonetici.normalizeDiaperType(k['diaperType'] ?? k['tur']) ==
              'wet',
        )
        .length;
    int kirli = kakaKayitlari
        .where(
          (k) =>
              VeriYonetici.normalizeDiaperType(k['diaperType'] ?? k['tur']) ==
              'dirty',
        )
        .length;
    int ikisi = kakaKayitlari
        .where(
          (k) =>
              VeriYonetici.normalizeDiaperType(k['diaperType'] ?? k['tur']) ==
              'both',
        )
        .length;

    // Uyku kayitlari
    final uykuKayitlari = VeriYonetici.getUykuKayitlari()
        .where((k) {
          final t = k['bitis'] as DateTime;
          return t.isAfter(startDate) && !t.isAfter(endDate);
        })
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

    // Buyume kayitlari
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

    final gunSayisi = _rangeMode == _kWeekly
        ? 7
        : _rangeMode == _kMonthly
            ? now.day
            : endDate.difference(startDate).inDays.clamp(1, 999);

    setState(() {
      _stats = {
        'startDate': startDate,
        'endDate': endDate,
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
        // Kati gida
        'toplamSolid': solidKayitlari.length,
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
        'enUzunUykuDakika': enUzunUykuDakika,
        'uykuSayisi': uykuKayitlari.length,
        // Buyume
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
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: Container(
                    color: bgColor,
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
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    final startDate = _stats['startDate'] as DateTime?;
    final endDate = _stats['endDate'] as DateTime?;
    String dateRange = '';
    if (startDate != null && endDate != null) {
      dateRange =
          '${startDate.day} ${months[startDate.month - 1]} - ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
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
                      _rangeMode == _kWeekly
                          ? l10n.weeklyReport
                          : _rangeMode == _kMonthly
                              ? l10n.monthlyReport
                              : l10n.customRange,
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
              // Share Button
              GestureDetector(
                onTap: _isCapturing ? null : _shareAsImage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3445)
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: _isCapturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF8AC1),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF666666),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Range Toggle: Weekly | Monthly | Custom
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3445) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildRangeTab(
                  label: l10n.weekly,
                  mode: _kWeekly,
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                _buildRangeTab(
                  label: l10n.monthly,
                  mode: _kMonthly,
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                _buildRangeTab(
                  label: l10n.customRange,
                  mode: _kCustom,
                  isDark: isDark,
                  onTapOverride: _pickCustomRange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTab({
    required String label,
    required int mode,
    required bool isDark,
    VoidCallback? onTapOverride,
  }) {
    final isActive = _rangeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: onTapOverride ??
            () {
              HapticFeedback.lightImpact();
              setState(() => _rangeMode = mode);
              _calculateStats();
            },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF4A4455) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFFFF8AC1)
                  : const Color(0xFF888888),
            ),
          ),
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.breastfeeding(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.feeding,
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
                        l10n.totalBreastfeeding,
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF8FAB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['toplamEmzirmeDk'] ?? 0} ${l10n.minAbbrev}',
                        l10n.totalDuration,
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
                        l10n.dailyAvg,
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF8FAB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${((_stats['toplamEmzirmeDk'] ?? 0) / ((_stats['toplamEmzirme'] ?? 1) == 0 ? 1 : _stats['toplamEmzirme'])).toStringAsFixed(0)} ${l10n.minAbbrev}',
                        l10n.avgDuration,
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
                    color: const Color(0xFFFFB3D9).withValues(alpha: 0.1),
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
                                  l10n.leftBreast,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['solMemeDk'] ?? 0} ${l10n.minAbbrev}',
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
                        color: const Color(0xFFFF8AC1).withValues(alpha: 0.2),
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
                                  l10n.rightBreast,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['sagMemeDk'] ?? 0} ${l10n.minAbbrev}',
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
                          color: const Color(0xFFFFB3D9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.bottle,
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB3D9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.formula,
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB3D9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.solidFood,
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_stats['toplamSolid'] ?? 0}',
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

  // BEZ DEGISIMI KARTI
  Widget _buildDiaperCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.diaperClean(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.diaperChanges,
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
                        l10n.total,
                        const Color(0xFFB3D9FF),
                        const Color(0xFF6BA3E0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['gunlukBez'] ?? 0}',
                        l10n.dailyAvg,
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
                          color: const Color(0xFFB3D9FF).withValues(alpha: 0.1),
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
                              l10n.wet,
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
                          color: const Color(0xFFB3D9FF).withValues(alpha: 0.1),
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
                              l10n.dirty,
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
                          color: const Color(0xFFB3D9FF).withValues(alpha: 0.1),
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
                              l10n.both,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.sleep(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.sleep,
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
                        '${_stats['toplamUykuSaat'] ?? 0} ${l10n.hourAbbrev}',
                        l10n.total,
                        const Color(0xFFD9B3FF),
                        const Color(0xFF9B6FCC),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['gunlukUykuSaat'] ?? 0} ${l10n.hourAbbrev}',
                        l10n.dailyAvg,
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
                        _formatDurationMinutes(
                          _stats['enUzunUykuDakika'],
                          l10n,
                        ),
                        l10n.longestSleep,
                        const Color(0xFFD9B3FF),
                        const Color(0xFF9B6FCC),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        '${_stats['uykuSayisi'] ?? 0}',
                        l10n.sleepCount,
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

  // BUYUME KARTI
  Widget _buildGrowthCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: Ikonlar.growth(size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.growth,
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
                          color: const Color(0xFFB3FFD9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.height,
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
                          color: const Color(0xFFB3FFD9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.weight,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            (isDark ? const Color(0xFF1A1625) : const Color(0xFFFFF9F5))
                .withValues(alpha: 0.95),
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
                  color: const Color(0xFFFF8AC1).withValues(alpha: 0.4),
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
                  Text(
                    l10n.saveAsPdf,
                    style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    final appLocale = Localizations.localeOf(context);
    final localeTag = appLocale.toLanguageTag();

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfMobileOnly),
          backgroundColor: const Color(0xFF888888),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // Prefer NotoSans (full Unicode: Latin, Cyrillic, Greek …).
      // Drop the TTF files into assets/fonts/ to activate:
      //   assets/fonts/NotoSans-Regular.ttf
      //   assets/fonts/NotoSans-Bold.ttf
      // Falls back to Arial (covers Latin/TR/ES) when they are absent.
      pw.Font regularFont;
      pw.Font boldFont;
      try {
        regularFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
        );
        boldFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
        );
      } catch (_) {
        regularFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Arial-Regular.ttf'),
        );
        boldFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Arial-Bold.ttf'),
        );
      }
      final pdf = pw.Document();
      final theme = pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        italic: regularFont,
        boldItalic: boldFont,
      );

      final startDate = _stats['startDate'] as DateTime?;
      final endDate = _stats['endDate'] as DateTime?;
      final dateRangeText = startDate == null || endDate == null
          ? '-'
          : '${_formatPdfDate(startDate, localeTag)} - ${_formatPdfDate(endDate, localeTag)}';
      final reportType = _rangeMode == _kWeekly
          ? l10n.weeklyReport
          : _rangeMode == _kMonthly
              ? l10n.monthlyReport
              : l10n.customRange;

      final sectionTitleStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF2B2D33),
      );
      final labelStyle = pw.TextStyle(
        fontSize: 10.5,
        color: PdfColor.fromInt(0xFF5E6470),
      );
      final valueStyle = pw.TextStyle(
        fontSize: 10.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF2B2D33),
      );

      final medicationCount = VeriYonetici.getIlacDozKayitlari().where((log) {
        final givenAt = log['givenAt'] as DateTime?;
        if (givenAt == null || startDate == null || endDate == null) {
          return false;
        }
        return !givenAt.isBefore(startDate) && !givenAt.isAfter(endDate);
      }).length;

      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 32),
          build: (pw.Context context) => [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF3EFF2),
                borderRadius: pw.BorderRadius.circular(14),
                border: pw.Border.all(color: PdfColor.fromInt(0xFFE2DDE1)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    l10n.babyTrackerReport,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF2B2D33),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    reportType,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromInt(0xFF5E6470),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    '${l10n.period}: $dateRangeText',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromInt(0xFF5E6470),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            _buildPdfSection(
              title: l10n.feeding,
              rows: [
                MapEntry(
                  l10n.totalBreastfeeding,
                  '${_pdfStat('toplamEmzirme')} ${l10n.times}',
                ),
                MapEntry(
                  l10n.totalDuration,
                  '${_pdfStat('toplamEmzirmeDk')} ${l10n.minAbbrev}',
                ),
                MapEntry(
                  l10n.leftBreast,
                  '${_pdfStat('solMemeDk')} ${l10n.minAbbrev}',
                ),
                MapEntry(
                  l10n.rightBreast,
                  '${_pdfStat('sagMemeDk')} ${l10n.minAbbrev}',
                ),
                MapEntry(l10n.bottle, '${_pdfStat('toplamBiberonMl')} ml'),
                MapEntry(l10n.formula, '${_pdfStat('toplamFormulMl')} ml'),
                MapEntry(
                  l10n.solidFood,
                  '${_pdfStat('toplamSolid')} ${l10n.times}',
                ),
              ],
              backgroundColor: PdfColor.fromInt(0xFFFDF3F5),
              sectionTitleStyle: sectionTitleStyle,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            pw.SizedBox(height: 12),
            _buildPdfSection(
              title: l10n.diaperChanges,
              rows: [
                MapEntry(l10n.total, '${_pdfStat('toplamBez')} ${l10n.times}'),
                MapEntry(
                  l10n.dailyAvg,
                  '${_pdfStat('gunlukBez')} ${l10n.times}',
                ),
                MapEntry(l10n.wet, _pdfStat('islak')),
                MapEntry(l10n.dirty, _pdfStat('kirli')),
                MapEntry(l10n.both, _pdfStat('ikisi')),
              ],
              backgroundColor: PdfColor.fromInt(0xFFF2F6FC),
              sectionTitleStyle: sectionTitleStyle,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            pw.SizedBox(height: 12),
            _buildPdfSection(
              title: l10n.sleep,
              rows: [
                MapEntry(
                  '${l10n.total} ${l10n.sleep}',
                  '${_pdfStat('toplamUykuSaat')} ${l10n.hourAbbrev}',
                ),
                MapEntry(
                  '${l10n.dailyAvg} ${l10n.sleep}',
                  '${_pdfStat('gunlukUykuSaat')} ${l10n.hourAbbrev}',
                ),
                MapEntry(
                  l10n.longestSleep,
                  _formatDurationMinutes(_stats['enUzunUykuDakika'], l10n),
                ),
                MapEntry(
                  l10n.sleepCount,
                  '${_pdfStat('uykuSayisi')} ${l10n.times}',
                ),
              ],
              backgroundColor: PdfColor.fromInt(0xFFF6F4FC),
              sectionTitleStyle: sectionTitleStyle,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            pw.SizedBox(height: 12),
            _buildPdfSection(
              title: l10n.growth,
              rows: [
                MapEntry(l10n.height, '${_pdfStat('boy')} cm'),
                MapEntry(l10n.weight, '${_pdfStat('kilo')} kg'),
              ],
              backgroundColor: PdfColor.fromInt(0xFFF1F8F4),
              sectionTitleStyle: sectionTitleStyle,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            if (medicationCount > 0) ...[
              pw.SizedBox(height: 12),
              _buildPdfSection(
                title: l10n.medications,
                rows: [
                  MapEntry(l10n.applied, '$medicationCount ${l10n.times}'),
                ],
                backgroundColor: PdfColor.fromInt(0xFFFAF5EE),
                sectionTitleStyle: sectionTitleStyle,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ],
          ],
          footer: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  l10n.generatedWith,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromInt(0xFF9AA0AA),
                  ),
                ),
                pw.Text(
                  '${context.pageNumber}/${context.pagesCount}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromInt(0xFF9AA0AA),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final bytes = await pdf.save();

      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/bebek_rapor_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: l10n.babyTrackerReport),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfSaved),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithMessage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _shareAsImage() async {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sharingMobileOnly),
          backgroundColor: const Color(0xFF888888),
        ),
      );
      return;
    }

    setState(() => _isCapturing = true);
    HapticFeedback.mediumImpact();

    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RepaintBoundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to capture image');
      }

      final bytes = byteData.buffer.asUint8List();

      // Save to temp file
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/bebek_rapor_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      // Open share sheet
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: _rangeMode == _kWeekly
              ? l10n.weeklyReport
              : _rangeMode == _kMonthly
                  ? l10n.monthlyReport
                  : l10n.customRange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithMessage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isCapturing = false);
  }

  String _formatPdfDate(DateTime date, String localeTag) {
    final localDate = date.toLocal();
    final normalizedLocale = localeTag.isEmpty ? 'en' : localeTag;
    try {
      return DateFormat.yMMMd(normalizedLocale).format(localDate);
    } catch (_) {
      final day = localDate.day.toString().padLeft(2, '0');
      final month = localDate.month.toString().padLeft(2, '0');
      return '$day.$month.${localDate.year}';
    }
  }

  String _pdfStat(String key) {
    final value = _stats[key];
    if (value == null) return '-';
    if (value is num) {
      if (value is double && value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String _formatDurationMinutes(dynamic value, AppLocalizations l10n) {
    if (value == null) return '-';

    int minutes;
    if (value is num) {
      minutes = value.toInt();
    } else {
      minutes = int.tryParse(value.toString()) ?? 0;
    }

    if (minutes <= 0) return '-';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '$hours ${l10n.hourAbbrev} $remainingMinutes ${l10n.minAbbrev}';
    }
    if (hours > 0) {
      return '$hours ${l10n.hourAbbrev}';
    }
    return '$remainingMinutes ${l10n.minAbbrev}';
  }

  pw.Widget _buildPdfSection({
    required String title,
    required List<MapEntry<String, String>> rows,
    required PdfColor backgroundColor,
    required pw.TextStyle sectionTitleStyle,
    required pw.TextStyle labelStyle,
    required pw.TextStyle valueStyle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: sectionTitleStyle),
          pw.SizedBox(height: 8.5),
          ...rows.map((row) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(row.key, style: labelStyle),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      row.value,
                      style: valueStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
