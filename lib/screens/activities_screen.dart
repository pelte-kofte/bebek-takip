import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        CupertinoSlidingSegmentedControl;
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/veri_yonetici.dart';
import '../widgets/decorative_background.dart';
import '../l10n/app_localizations.dart';
import '../utils/event_datetime_utils.dart';

enum ActivityType { mama, bez, uyku }

enum _CareEditType { feeding, nursing, diaper, sleep }

class ActivitiesScreen extends StatefulWidget {
  final ActivityType? initialTab;
  final int? refreshTrigger;
  final bool fromHome;

  const ActivitiesScreen({
    super.key,
    this.initialTab,
    this.refreshTrigger,
    this.fromHome = false,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  DateTime _selectedDate = DateTime.now();
  late ActivityType _activeType;
  bool _loggedNursingSeparatorSample = false;

  @override
  void initState() {
    super.initState();
    _activeType = widget.initialTab ?? ActivityType.mama;
  }

  @override
  void didUpdateWidget(ActivitiesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When refreshTrigger changes, rebuild to show new data
    // The _activeType is preserved because State object isn't recreated
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      setState(() {});
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _previousDay() => setState(
    () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
  );

  void _nextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    if (tomorrow.isBefore(DateTime.now()) ||
        _isSameDay(tomorrow, DateTime.now())) {
      setState(() => _selectedDate = tomorrow);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  String _formatDateHeader(DateTime date, AppLocalizations l10n) {
    final monthNames = [
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
    if (_isToday(date)) {
      return '${l10n.today}, ${date.day} ${monthNames[date.month - 1]}';
    }
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return DecorativeBackground(
      preset: BackgroundPreset.activities,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header (fixed)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    if (widget.fromHome) ...[
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2A2A3A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: textColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Tarih Secici
                    _buildDateSelector(isDark),
                  ],
                ),
              ),

              // Compact Category Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildCompactTab(
                            Icons.local_drink_outlined,
                            l10n.feeding_tab,
                            ActivityType.mama,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactTab(
                            Icons.baby_changing_station_outlined,
                            l10n.diaper_tab,
                            ActivityType.bez,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactTab(
                            Icons.bedtime_outlined,
                            l10n.sleep_tab,
                            ActivityType.uyku,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Icerik (scrollable, Expanded ile kalan alani doldurur)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildActiveContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFBF5);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black12
                : const Color(0xFFE5E0F7).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left, color: Color(0xFFFFB4A2)),
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFFFFB4A2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateHeader(_selectedDate, l10n),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB4A2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _isToday(_selectedDate) ? null : _nextDay,
            icon: Icon(
              Icons.chevron_right,
              color: _isToday(_selectedDate)
                  ? Colors.grey.shade400
                  : const Color(0xFFFFB4A2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTab(IconData icon, String label, ActivityType type) {
    final isActive = _activeType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedBg = isDark ? const Color(0xFF2A2A3A) : Colors.transparent;
    final unselectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.25)
        : const Color(0xFFE5E0F7).withValues(alpha: 0.5);
    final unselectedFg = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF1d0e0c).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => setState(() => _activeType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFFB4A2).withValues(alpha: 0.15)
              : unselectedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFFFFB4A2) : unselectedBorder,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? const Color(0xFFFFB4A2) : unselectedFg,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.3,
                color: isActive ? const Color(0xFFFFB4A2) : unselectedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent() {
    // Her widget'a unique key ver ki AnimatedSwitcher farki anlasin
    switch (_activeType) {
      case ActivityType.mama:
        return KeyedSubtree(
          key: const ValueKey('mama'),
          child: _buildMamaList(),
        );
      case ActivityType.bez:
        return KeyedSubtree(
          key: const ValueKey('bez'),
          child: _buildKakaList(),
        );
      case ActivityType.uyku:
        return KeyedSubtree(
          key: const ValueKey('uyku'),
          child: _buildUykuList(),
        );
    }
  }

  List<Map<String, dynamic>> _filterBySelectedDayRange(
    List<Map<String, dynamic>> list,
    String dateKey,
  ) {
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    return list.where((item) {
      final date = (item[dateKey] as DateTime).toLocal();
      return !date.isBefore(startOfDay) && !date.isAfter(endOfDay);
    }).toList();
  }

  Widget _buildMamaList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final l10n = AppLocalizations.of(context)!;

    final tumKayitlar = VeriYonetici.getMamaKayitlari();
    final kayitlar = _filterBySelectedDayRange(tumKayitlar, 'tarih');

    int toplamMl = 0;
    int toplamDakika = 0;
    for (var k in kayitlar) {
      toplamMl += (k['miktar'] ?? 0) as int;
      toplamDakika +=
          ((k['solDakika'] ?? 0) as int) + ((k['sagDakika'] ?? 0) as int);
    }

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        Icons.local_drink_outlined,
        l10n.firstFeedingTime,
        l10n.trackBabyFeeding,
        isDark,
        l10n,
      );
    }

    return Column(
      children: [
        // Section Header - OZET
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.summary,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),
        // Ozet karti
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (toplamDakika > 0)
                      Text(
                        '${l10n.breastfeeding}: $toplamDakika ${l10n.minAbbrev}',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (toplamDakika > 0 && toplamMl > 0)
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    if (toplamMl > 0)
                      Text(
                        '${l10n.bottle}: $toplamMl ${l10n.mlAbbrev}',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      '(${kayitlar.length} ${l10n.record})',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Header - SON AKTIVITELER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                l10n.recentActivities,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final tur = kayit['tur'] as String? ?? '';
              final sol = kayit['solDakika'] ?? 0;
              final sag = kayit['sagDakika'] ?? 0;
              final miktar = kayit['miktar'] ?? 0;
              final kategori = kayit['kategori'] as String? ?? 'Milk';
              final solidAciklama = kayit['solidAciklama'] as String?;

              String title;
              String subtitle;
              IconData icon = Icons.local_drink_outlined;

              final normalizedTur = tur.toLowerCase();
              final isSolid =
                  kategori == 'Solid' || normalizedTur.contains('kat');
              final isNursing =
                  normalizedTur.contains('anne') &&
                  !normalizedTur.contains('biberon');
              if (isSolid) {
                final solidDakika = kayit['solidDakika'] as int? ?? 0;
                title = l10n.solid;
                if (solidDakika > 0) {
                  subtitle =
                      '${l10n.solidFood} • $solidDakika ${l10n.minAbbrev}';
                } else {
                  subtitle = l10n.solidFood;
                }
                icon = Icons.restaurant_outlined;
              } else if (isNursing) {
                title = l10n.breastfeeding;
                final toplamDakika = sol + sag;
                if (sag == 0 && sol > 0) {
                  // New format: total duration stored in solDakika
                  subtitle = '${l10n.total}: $sol${l10n.minAbbrev}';
                } else {
                  // Old format: left/right split
                  subtitle =
                      '${l10n.left} $sol${l10n.minAbbrev} • ${l10n.right} $sag${l10n.minAbbrev} (${l10n.total}: $toplamDakika${l10n.minAbbrev})';
                  if (kDebugMode && !_loggedNursingSeparatorSample) {
                    _loggedNursingSeparatorSample = true;
                    debugPrint(
                      '[ActivitiesScreen] nursing subtitle="$subtitle"',
                    );
                  }
                }
              } else {
                title = '$miktar ${l10n.mlAbbrev}';
                subtitle = normalizedTur.contains('form')
                    ? l10n.formula
                    : l10n.bottleBreastMilk;
              }

              return _buildListItem(
                icon: icon,
                title: title,
                subtitle: subtitle,
                time: _formatTime(tarih),
                color: const Color(0xFFE91E63),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () =>
                    _openEditForRecord(_resolveMamaEditType(kayit), kayit),
                onDelete: () => _deleteMama(kayit['id']?.toString() ?? ''),
                notes:
                    (kategori == 'Solid' &&
                        solidAciklama != null &&
                        solidAciklama.isNotEmpty)
                    ? solidAciklama
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKakaList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final l10n = AppLocalizations.of(context)!;

    final tumKayitlar = VeriYonetici.getKakaKayitlari();
    final kayitlar = _filterBySelectedDayRange(tumKayitlar, 'tarih');

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        Icons.baby_changing_station_outlined,
        l10n.diaperChangeTime,
        l10n.trackHygiene,
        isDark,
        l10n,
      );
    }

    final diaperTypes = kayitlar
        .map(
          (k) => VeriYonetici.normalizeDiaperType(k['diaperType'] ?? k['tur']),
        )
        .toList();
    final islak = diaperTypes.where((t) => t == 'wet').length;
    final kirli = diaperTypes.where((t) => t == 'dirty').length;
    final ikisi = diaperTypes.where((t) => t == 'both').length;

    if (kDebugMode) {
      debugPrint(
        '[Bakim/Bez] ${_selectedDate.toLocal()} total=${kayitlar.length} wet=$islak dirty=$kirli both=$ikisi',
      );
    }

    return Column(
      children: [
        // Section Header - OZET
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.summary,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),
        // Ozet karti
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBezSummary(islak, l10n.wet),
              _buildBezSummary(kirli, l10n.dirty),
              _buildBezSummary(ikisi, l10n.both),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Header - SON AKTIVITELER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                l10n.recentActivities,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final tur = VeriYonetici.normalizeDiaperType(
                kayit['diaperType'] ?? kayit['tur'],
              );

              // Map stored diaper type to icon and localized label
              IconData diaperIcon = Icons.baby_changing_station_outlined;
              String diaperLabel = l10n.both;
              if (tur == 'wet') {
                diaperIcon = Icons.water_drop_outlined;
                diaperLabel = l10n.wet;
              } else if (tur == 'dirty') {
                diaperIcon = Icons.cloud_outlined;
                diaperLabel = l10n.dirty;
              } else if (tur == 'both') {
                diaperIcon = Icons.baby_changing_station_outlined;
                diaperLabel = l10n.both;
              }

              return _buildListItem(
                icon: diaperIcon,
                title: diaperLabel,
                subtitle: l10n.diaperChange,
                time: _formatTime(tarih),
                color: const Color(0xFF9C27B0),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () => _openEditForRecord(_CareEditType.diaper, kayit),
                onDelete: () => _deleteKaka(kayit['id']?.toString() ?? ''),
                notes: kayit['notlar'] as String?,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUykuList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final l10n = AppLocalizations.of(context)!;

    final tumKayitlar = VeriYonetici.getUykuKayitlari();
    final kayitlar = _filterBySelectedDayRange(tumKayitlar, 'bitis');

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        Icons.bedtime_outlined,
        l10n.sweetDreams,
        l10n.trackSleepPattern,
        isDark,
        l10n,
      );
    }

    final toplamDakika = kayitlar.fold(
      0,
      (sum, k) => sum + (k['sure'] as Duration).inMinutes,
    );
    final saat = toplamDakika ~/ 60;
    final dakika = toplamDakika % 60;

    return Column(
      children: [
        // Section Header - OZET
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.summary,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),
        // Ozet karti
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.total}: $saat ${l10n.hourAbbrev} $dakika ${l10n.minAbbrev}',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Header - SON AKTIVITELER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                l10n.recentActivities,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1d0e0c),
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kayitlar.length,
            itemBuilder: (context, index) {
              final kayit = kayitlar[index];
              final baslangic = kayit['baslangic'] as DateTime;
              final bitis = kayit['bitis'] as DateTime;
              final sure = kayit['sure'] as Duration;

              return _buildListItem(
                icon: Icons.bedtime_outlined,
                title: _formatDuration(sure, l10n),
                subtitle: '${_formatTime(baslangic)} - ${_formatTime(bitis)}',
                time: '',
                color: const Color(0xFF3F51B5),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () => _openEditForRecord(_CareEditType.sleep, kayit),
                onDelete: () => _deleteUyku(kayit['id']?.toString() ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBezSummary(int count, String label) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : const Color(0xFFFFFBF5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 48, color: const Color(0xFFFFB4A2)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF4A4458),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF8A8494),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFB4A2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB4A2).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.selectAnotherDate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    String? notes,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5E0F7).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon with soft colored circular background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 14),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notes != null && notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notes,
                          style: TextStyle(
                            color: subtitleColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Time badge and delete button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (time.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFB4A2,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4897A),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFF6B6B),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ EDIT & DELETE FUNCTIONS ============

  _CareEditType _resolveMamaEditType(Map<String, dynamic> kayit) {
    final kategori = (kayit['kategori'] ?? 'Milk').toString().toLowerCase();
    final tur = (kayit['tur'] ?? '').toString().toLowerCase();
    final isNursing =
        kategori != 'solid' && tur.contains('anne') && !tur.contains('biberon');
    return isNursing ? _CareEditType.nursing : _CareEditType.feeding;
  }

  void _openEditForRecord(_CareEditType type, Map<String, dynamic> kayit) {
    switch (type) {
      case _CareEditType.feeding:
        _showEditFeedingSheet(kayit);
        break;
      case _CareEditType.nursing:
        _showEditNursingSheet(kayit);
        break;
      case _CareEditType.diaper:
        _showEditDiaperSheet(kayit);
        break;
      case _CareEditType.sleep:
        _showEditSleepSheet(kayit);
        break;
    }
  }

  Future<DateTime?> _pickNormalizedDateTime(DateTime initial) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(hours: 48));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(
        earliest.year,
        earliest.month,
        earliest.day,
      ).subtract(const Duration(days: 2)),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: l10n.selectDate,
    );
    if (pickedDate == null) return null;
    if (!mounted) return null;

    final pickedTime = await _showCupertinoTimePicker(
      context,
      TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (pickedTime == null) return null;

    final candidate = normalizePickedDateTime(
      now: now,
      pickedDate: pickedDate,
      pickedTime: pickedTime,
    );
    if (!isWithinRollingWindow(now: now, candidate: candidate)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.eventTimeTooOld)));
      }
      return null;
    }
    return candidate;
  }

  Widget _buildSheetScaffold({
    required String title,
    required Widget child,
    required VoidCallback onSave,
    required bool isSaving,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: AbsorbPointer(
        absorbing: isSaving,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(child: SingleChildScrollView(child: child)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isSaving ? null : onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF7F7FA),
      onTap: onTap,
    );
  }

  Future<void> _runCareEntrySave({
    required String recordType,
    required String recordId,
    required BuildContext sheetContext,
    required StateSetter setModalState,
    required bool isSaving,
    required void Function(bool value) setSaving,
    required Future<bool> Function() action,
    required ScaffoldMessengerState messenger,
    required AppLocalizations l10n,
  }) async {
    if (isSaving) return;

    void safeSetSaving(bool value) {
      if (!sheetContext.mounted) return;
      try {
        setModalState(() => setSaving(value));
      } catch (e, st) {
        debugPrint('ActivitiesScreen setSaving($value) failed: $e\n$st');
      }
    }

    safeSetSaving(true);
    var didPop = false;
    try {
      debugPrint(
        '[ActivitiesScreen] care_edit_save start type=$recordType id=$recordId',
      );
      final saved = await action().timeout(const Duration(seconds: 3));
      debugPrint(
        '[ActivitiesScreen] care_edit_save result type=$recordType id=$recordId saved=$saved',
      );
      if (!saved) {
        throw StateError('Record could not be updated.');
      }
      if (!mounted || !sheetContext.mounted) return;
      safeSetSaving(false);
      Navigator.of(sheetContext).pop(true);
      didPop = true;
    } catch (e, st) {
      debugPrint(
        '[ActivitiesScreen] care_edit_save error type=$recordType id=$recordId error=$e\n$st',
      );
      if (!mounted || !sheetContext.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailedTryAgain)));
    } finally {
      if (sheetContext.mounted && !didPop) {
        safeSetSaving(false);
      }
    }
  }

  Future<void> _showEditNursingSheet(Map<String, dynamic> kayit) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final String recordId = kayit['id']?.toString() ?? '';
    DateTime eventTime = kayit['tarih'] as DateTime;
    final int left = kayit['solDakika'] as int? ?? 0;
    final int right = kayit['sagDakika'] as int? ?? 0;
    String side = right > left ? 'right' : 'left';
    int duration = side == 'right' ? right : left;
    if (duration == 0) duration = left + right;
    bool isSaving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          title: l10n.editTitleNursing,
          isSaving: isSaving,
          onSave: () async {
            if (duration <= 0) return;
            await _runCareEntrySave(
              recordType: 'nursing',
              recordId: recordId,
              sheetContext: ctx,
              setModalState: setModalState,
              isSaving: isSaving,
              setSaving: (value) => isSaving = value,
              messenger: messenger,
              l10n: l10n,
              action: () {
                final updated = {
                  'id': recordId,
                  'tarih': eventTime,
                  'tur': 'Anne Sütü',
                  'solDakika': side == 'left' ? duration : 0,
                  'sagDakika': side == 'right' ? duration : 0,
                  'miktar': 0,
                  'kategori': 'Milk',
                };
                return VeriYonetici.updateMamaKaydiById(recordId, updated);
              },
            );
          },
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl<String>(
                groupValue: side,
                children: <String, Widget>{
                  'left': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.left),
                  ),
                  'right': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.right),
                  ),
                },
                onValueChanged: (v) {
                  if (v != null) setModalState(() => side = v);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(l10n.duration),
                subtitle: Text('$duration ${l10n.minAbbrev}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => setModalState(
                        () => duration = (duration - 1).clamp(1, 180),
                      ),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      onPressed: () => setModalState(
                        () => duration = (duration + 1).clamp(1, 180),
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
              _buildRowTile(
                title: l10n.time,
                value: _formatTime(eventTime),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(eventTime);
                  if (picked != null) setModalState(() => eventTime = picked);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _showEditFeedingSheet(Map<String, dynamic> kayit) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final String recordId = kayit['id']?.toString() ?? '';
    DateTime eventTime = kayit['tarih'] as DateTime;
    final noteController = TextEditingController(
      text: kayit['solidAciklama'] as String? ?? '',
    );
    final String tur = (kayit['tur'] as String? ?? '').toLowerCase();
    final String kategori = (kayit['kategori'] as String? ?? 'Milk')
        .toLowerCase();
    String selectedType;
    if (kategori == 'solid' || tur.contains('kat')) {
      selectedType = 'solid';
    } else if (tur.contains('biberon')) {
      selectedType = 'bottleMilk';
    } else {
      selectedType = 'formula';
    }
    int amount = (kayit['miktar'] as int? ?? 0).clamp(0, 500);
    int solidDuration = (kayit['solidDakika'] as int? ?? 0).clamp(0, 180);
    bool isSaving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          title: l10n.editTitleFeeding,
          isSaving: isSaving,
          onSave: () async {
            await _runCareEntrySave(
              recordType: 'feeding',
              recordId: recordId,
              sheetContext: ctx,
              setModalState: setModalState,
              isSaving: isSaving,
              setSaving: (value) => isSaving = value,
              messenger: messenger,
              l10n: l10n,
              action: () {
                final Map<String, dynamic> updated = {
                  'id': recordId,
                  'tarih': eventTime,
                };
                if (selectedType == 'solid') {
                  updated.addAll({
                    'tur': 'Katı Gıda',
                    'solDakika': 0,
                    'sagDakika': 0,
                    'miktar': 0,
                    'kategori': 'Solid',
                    'solidAciklama': noteController.text.isEmpty
                        ? null
                        : noteController.text,
                    'solidDakika': solidDuration,
                  });
                } else if (selectedType == 'bottleMilk') {
                  updated.addAll({
                    'tur': 'Anne Sütü (Biberon)',
                    'solDakika': 0,
                    'sagDakika': 0,
                    'miktar': amount,
                    'kategori': 'Milk',
                  });
                } else {
                  updated.addAll({
                    'tur': 'Formül',
                    'solDakika': 0,
                    'sagDakika': 0,
                    'miktar': amount,
                    'kategori': 'Milk',
                  });
                }
                return VeriYonetici.updateMamaKaydiById(recordId, updated);
              },
            );
          },
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl<String>(
                groupValue: selectedType,
                children: <String, Widget>{
                  'formula': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.formula),
                  ),
                  'bottleMilk': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.bottleBreastMilk),
                  ),
                  'solid': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.solid),
                  ),
                },
                onValueChanged: (v) {
                  if (v != null) setModalState(() => selectedType = v);
                },
              ),
              const SizedBox(height: 12),
              if (selectedType == 'solid')
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(l10n.duration),
                  subtitle: Text('$solidDuration ${l10n.minAbbrev}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => setModalState(
                          () =>
                              solidDuration = (solidDuration - 5).clamp(0, 180),
                        ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () => setModalState(
                          () =>
                              solidDuration = (solidDuration + 5).clamp(0, 180),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                )
              else
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(l10n.amount),
                  subtitle: Text('$amount ${l10n.mlAbbrev}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => setModalState(
                          () => amount = (amount - 10).clamp(0, 500),
                        ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () => setModalState(
                          () => amount = (amount + 10).clamp(0, 500),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              if (selectedType == 'solid')
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: l10n.solidFoodHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              const SizedBox(height: 10),
              _buildRowTile(
                title: l10n.time,
                value: _formatTime(eventTime),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(eventTime);
                  if (picked != null) setModalState(() => eventTime = picked);
                },
              ),
            ],
          ),
        ),
      ),
    );
    noteController.dispose();
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _showEditDiaperSheet(Map<String, dynamic> kayit) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final String recordId = kayit['id']?.toString() ?? '';
    DateTime eventTime = kayit['tarih'] as DateTime;
    String type = VeriYonetici.normalizeDiaperType(
      kayit['diaperType'] ?? kayit['tur'],
    );
    final noteController = TextEditingController(
      text: kayit['notlar'] as String? ?? '',
    );
    bool isSaving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          title: l10n.editTitleDiaper,
          isSaving: isSaving,
          onSave: () async {
            await _runCareEntrySave(
              recordType: 'diaper',
              recordId: recordId,
              sheetContext: ctx,
              setModalState: setModalState,
              isSaving: isSaving,
              setSaving: (value) => isSaving = value,
              messenger: messenger,
              l10n: l10n,
              action: () {
                final normalized = VeriYonetici.normalizeDiaperType(type);
                final updated = {
                  'id': recordId,
                  'tarih': eventTime,
                  'tur': normalized,
                  'diaperType': normalized,
                  'eventType': VeriYonetici.diaperEventType,
                  'notlar': noteController.text,
                };
                return VeriYonetici.updateKakaKaydiById(recordId, updated);
              },
            );
          },
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl<String>(
                groupValue: type,
                children: <String, Widget>{
                  'wet': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.diaperWet),
                  ),
                  'dirty': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.diaperDirty),
                  ),
                  'both': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.diaperBoth),
                  ),
                },
                onValueChanged: (v) {
                  if (v != null) setModalState(() => type = v);
                },
              ),
              const SizedBox(height: 12),
              _buildRowTile(
                title: l10n.time,
                value: _formatTime(eventTime),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(eventTime);
                  if (picked != null) setModalState(() => eventTime = picked);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: l10n.addOptionalNote,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
    noteController.dispose();
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _showEditSleepSheet(Map<String, dynamic> kayit) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final String recordId = kayit['id']?.toString() ?? '';
    DateTime start = kayit['baslangic'] as DateTime;
    DateTime end = kayit['bitis'] as DateTime;
    bool isSaving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          title: l10n.editTitleSleep,
          isSaving: isSaving,
          onSave: () async {
            await _runCareEntrySave(
              recordType: 'sleep',
              recordId: recordId,
              sheetContext: ctx,
              setModalState: setModalState,
              isSaving: isSaving,
              setSaving: (value) => isSaving = value,
              messenger: messenger,
              l10n: l10n,
              action: () {
                var normalizedEnd = end;
                if (normalizedEnd.isBefore(start)) {
                  normalizedEnd = normalizedEnd.add(const Duration(days: 1));
                }
                final updated = {
                  'id': recordId,
                  'baslangic': start,
                  'bitis': normalizedEnd,
                  'sure': normalizedEnd.difference(start),
                };
                return VeriYonetici.updateUykuKaydiById(recordId, updated);
              },
            );
          },
          child: Column(
            children: [
              _buildRowTile(
                title: l10n.start,
                value: _formatTime(start),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(start);
                  if (picked != null) setModalState(() => start = picked);
                },
              ),
              const SizedBox(height: 8),
              _buildRowTile(
                title: l10n.end,
                value: _formatTime(end),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(end);
                  if (picked != null) setModalState(() => end = picked);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  void _deleteMama(String id) async {
    if (id.isEmpty) return;
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      await VeriYonetici.deleteMamaKaydiById(id);
      setState(() {});
    }
  }

  void _deleteKaka(String id) async {
    if (id.isEmpty) return;
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      await VeriYonetici.deleteKakaKaydiById(id);
      setState(() {});
    }
  }

  void _deleteUyku(String id) async {
    if (id.isEmpty) return;
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      await VeriYonetici.deleteUykuKaydiById(id);
      setState(() {});
    }
  }

  // ============ HELPER WIDGETS ============

  /// Shows a Cupertino-style time picker in a bottom sheet
  Future<TimeOfDay?> _showCupertinoTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    TimeOfDay selectedTime = initialTime;

    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with Done button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        color: Color(0xFF866F65),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedTime),
                    child: Text(
                      l10n.ok,
                      style: const TextStyle(
                        color: Color(0xFFFF998A),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cupertino Time Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  initialTime.hour,
                  initialTime.minute,
                ),
                onDateTimeChanged: (DateTime dateTime) {
                  selectedTime = TimeOfDay(
                    hour: dateTime.hour,
                    minute: dateTime.minute,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  /// Shows a Cupertino-style duration picker in a bottom sheet
  Future<bool?> _showDeleteConfirm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '??? ${l10n.delete}',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          l10n.deleteConfirm,
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  String _formatDuration(Duration d, AppLocalizations l10n) => d.inHours > 0
      ? '${d.inHours} ${l10n.hourAbbrev} ${d.inMinutes % 60} ${l10n.minAbbrev}'
      : '${d.inMinutes} ${l10n.minAbbrev}';
}
