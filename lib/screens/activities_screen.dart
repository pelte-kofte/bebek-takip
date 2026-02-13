import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker, CupertinoDatePickerMode, CupertinoTimerPicker, CupertinoTimerPickerMode;
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../widgets/decorative_background.dart';
import '../l10n/app_localizations.dart';

enum ActivityType { mama, bez, uyku }

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
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december
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
                      Row(
                        children: [
                          if (widget.fromHome) ...[
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2A2A3A) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
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
                            const SizedBox(width: 12),
                          ],
                          Text(
                            AppLocalizations.of(context)!.activities,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tarih Seçici
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

                // İçerik (scrollable, Expanded ile kalan alanı doldurur)
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
    // Her widget'a unique key ver ki AnimatedSwitcher farkı anlasın
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

  List<Map<String, dynamic>> _filterByDate(
    List<Map<String, dynamic>> list,
    String dateKey,
  ) {
    return list
        .where((item) => _isSameDay(item[dateKey] as DateTime, _selectedDate))
        .toList();
  }

  Widget _buildMamaList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final l10n = AppLocalizations.of(context)!;

    final tumKayitlar = VeriYonetici.getMamaKayitlari();
    final kayitlar = _filterByDate(tumKayitlar, 'tarih');

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
        // Section Header - ÖZET
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
        // Özet kartı
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

        // Section Header - SON AKTİVİTELER
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
              final originalIndex = tumKayitlar.indexOf(kayit);
              final tur = kayit['tur'] as String? ?? '';
              final sol = kayit['solDakika'] ?? 0;
              final sag = kayit['sagDakika'] ?? 0;
              final miktar = kayit['miktar'] ?? 0;
              final kategori = kayit['kategori'] as String? ?? 'Milk';
              final solidAciklama = kayit['solidAciklama'] as String?;

              String title;
              String subtitle;
              IconData icon = Icons.local_drink_outlined;

              if (kategori == 'Solid' || tur == 'Katı Gıda') {
                final solidDakika = kayit['solidDakika'] as int? ?? 0;
                title = l10n.solid;
                if (solidDakika > 0) {
                  subtitle = '${l10n.solidFood} • $solidDakika ${l10n.minAbbrev}';
                } else {
                  subtitle = l10n.solidFood;
                }
                icon = Icons.restaurant_outlined;
              } else if (tur == 'Anne Sütü') {
                title = l10n.breastfeeding;
                final toplamDakika = sol + sag;
                if (sag == 0 && sol > 0) {
                  // New format: total duration stored in solDakika
                  subtitle = '${l10n.total}: $sol${l10n.minAbbrev}';
                } else {
                  // Old format: left/right split
                  subtitle =
                      '${l10n.left} $sol${l10n.minAbbrev} • ${l10n.right} $sag${l10n.minAbbrev} (${l10n.total}: $toplamDakika${l10n.minAbbrev})';
                }
              } else {
                title = '$miktar ${l10n.mlAbbrev}';
                subtitle = tur == 'Formül' ? l10n.formula : l10n.bottleBreastMilk;
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
                onEdit: () => _editMama(originalIndex, kayit),
                onDelete: () => _deleteMama(originalIndex),
                notes: (kategori == 'Solid' && solidAciklama != null && solidAciklama.isNotEmpty) ? solidAciklama : null,
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
    final kayitlar = _filterByDate(tumKayitlar, 'tarih');

    if (kayitlar.isEmpty) {
      return _buildEmptyState(
        Icons.baby_changing_station_outlined,
        l10n.diaperChangeTime,
        l10n.trackHygiene,
        isDark,
        l10n,
      );
    }

    final islak = kayitlar.where((k) => k['tur'] == Dil.islak).length;
    final kirli = kayitlar.where((k) => k['tur'] == Dil.kirli).length;
    final ikisi = kayitlar.where((k) => k['tur'] == Dil.ikisiBirden).length;

    return Column(
      children: [
        // Section Header - ÖZET
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
        // Özet kartı
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

        // Section Header - SON AKTİVİTELER
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
              final originalIndex = tumKayitlar.indexOf(kayit);
              final tur = kayit['tur'] ?? '';

              // Map stored diaper type to icon and localized label
              IconData diaperIcon = Icons.baby_changing_station_outlined;
              String diaperLabel = l10n.both;
              if (tur == Dil.islak) {
                diaperIcon = Icons.water_drop_outlined;
                diaperLabel = l10n.wet;
              } else if (tur == Dil.kirli) {
                diaperIcon = Icons.cloud_outlined;
                diaperLabel = l10n.dirty;
              } else if (tur == Dil.ikisiBirden) {
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
                onEdit: () => _editKaka(originalIndex, kayit),
                onDelete: () => _deleteKaka(originalIndex),
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
    final kayitlar = _filterByDate(tumKayitlar, 'bitis');

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
        // Section Header - ÖZET
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
        // Özet kartı
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

        // Section Header - SON AKTİVİTELER
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
              final originalIndex = tumKayitlar.indexOf(kayit);

              return _buildListItem(
                icon: Icons.bedtime_outlined,
                title: _formatDuration(sure, l10n),
                subtitle: '${_formatTime(baslangic)} - ${_formatTime(bitis)}',
                time: '',
                color: const Color(0xFF3F51B5),
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onEdit: () => _editUyku(originalIndex, kayit),
                onDelete: () => _deleteUyku(originalIndex),
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
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
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
                          color: const Color(0xFFFFB4A2).withValues(alpha: 0.15),
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

  void _editMama(int index, Map<String, dynamic> kayit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    String kategori = kayit['kategori'] as String? ?? 'Milk';
    String tur = kayit['tur'] as String? ?? 'Anne Sütü';

    // Normalize type for proper button selection and UI display
    if (kategori == 'Solid' || tur == 'Katı Gıda') {
      tur = 'Katı Gıda';
    } else if (tur == 'Anne Sütü (Biberon)') {
      tur = 'Biberon Anne Sütü';
    }

    int solDakika = kayit['solDakika'] ?? 0;
    int sagDakika = kayit['sagDakika'] ?? 0;
    int totalDakika = solDakika + sagDakika;
    int miktar = kayit['miktar'] ?? 100;
    final solidAciklamaController = TextEditingController(text: kayit['solidAciklama'] as String? ?? '');
    int solidDakika = kayit['solidDakika'] ?? 0;
    DateTime tarih = kayit['tarih'];
    TimeOfDay saat = TimeOfDay(hour: tarih.hour, minute: tarih.minute);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFE91E63),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.editFeeding,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTurButtonIcon(
                        Icons.child_care_outlined,
                        l10n.breastfeeding,
                        'Anne Sütü',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                      _buildTurButtonIcon(
                        Icons.local_drink_outlined,
                        l10n.formula,
                        'Formül',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                      _buildTurButtonIcon(
                        Icons.local_drink_outlined,
                        l10n.bottleBreastMilk,
                        'Biberon Anne Sütü',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                      _buildTurButtonIcon(
                        Icons.restaurant_outlined,
                        l10n.solid,
                        'Katı Gıda',
                        tur,
                        (t) => setModalState(() => tur = t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (tur == 'Anne Sütü') ...[
                    _buildDurationEditor(
                      totalDakika,
                      (d) => setModalState(() => totalDakika = d),
                      isDark,
                      l10n,
                      ctx,
                    ),
                  ],
                  if (tur == 'Formül' || tur == 'Biberon Anne Sütü') ...[
                    _buildMiktarEditor(
                      miktar,
                      (m) => setModalState(() => miktar = m),
                      isDark,
                      l10n,
                    ),
                  ],
                  if (tur == 'Katı Gıda' || kategori == 'Solid') ...[
                    // Duration for solid food
                    _buildDurationEditor(
                      solidDakika,
                      (d) => setModalState(() => solidDakika = d),
                      isDark,
                      l10n,
                      ctx,
                    ),
                    const SizedBox(height: 16),
                    // Description field
                    TextField(
                      controller: solidAciklamaController,
                      decoration: InputDecoration(
                        hintText: l10n.solidFoodHint,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: Icon(
                          Icons.note_outlined,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildTimeSelector(
                    saat,
                    (s) => setModalState(() => saat = s),
                    ctx,
                  ),
                  const SizedBox(height: 24),
                  _buildSaveButton(() async {
                    final yeniTarih = DateTime(
                      tarih.year,
                      tarih.month,
                      tarih.day,
                      saat.hour,
                      saat.minute,
                    );
                    final kayitlar = VeriYonetici.getMamaKayitlari();
                    if (tur == 'Anne Sütü') {
                      kayitlar[index] = {
                        'tarih': yeniTarih,
                        'tur': 'Anne Sütü',
                        'solDakika': totalDakika,
                        'sagDakika': 0,
                        'miktar': 0,
                        'kategori': 'Milk',
                      };
                    } else if (tur == 'Katı Gıda' || kategori == 'Solid') {
                      // Save solid food with description and duration
                      kayitlar[index] = {
                        'tarih': yeniTarih,
                        'tur': 'Katı Gıda',
                        'solDakika': 0,
                        'sagDakika': 0,
                        'miktar': 0,
                        'kategori': 'Solid',
                        'solidAciklama': solidAciklamaController.text.isNotEmpty ? solidAciklamaController.text : null,
                        'solidDakika': solidDakika,
                      };
                    } else {
                      // Formula or bottle breast milk
                      kayitlar[index] = {
                        'tarih': yeniTarih,
                        'tur': tur,
                        'miktar': miktar,
                        'solDakika': 0,
                        'sagDakika': 0,
                        'kategori': 'Milk',
                      };
                    }
                    await VeriYonetici.saveMamaKayitlari(kayitlar);
                    solidAciklamaController.dispose();
                    Navigator.pop(ctx);
                    setState(() {});
                  }, const Color(0xFFE91E63), l10n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteMama(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final kayitlar = VeriYonetici.getMamaKayitlari();
      kayitlar.removeAt(index);
      await VeriYonetici.saveMamaKayitlari(kayitlar);
      setState(() {});
    }
  }

  void _editKaka(int index, Map<String, dynamic> kayit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    String tur = kayit['tur'];
    final DateTime originalTarih = kayit['tarih'];
    TimeOfDay editedTime = TimeOfDay(
      hour: originalTarih.hour,
      minute: originalTarih.minute,
    );
    final notesController = TextEditingController(
      text: kayit['notlar'] as String? ?? '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✏️ ${l10n.editDiaper}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(height: 24),
                // Time picker
                GestureDetector(
                  onTap: () async {
                    final picked = await _showCupertinoTimePicker(ctx, editedTime);
                    if (picked != null) {
                      // Check if selected time would be in the future
                      final now = DateTime.now();
                      final selectedDateTime = DateTime(
                        originalTarih.year,
                        originalTarih.month,
                        originalTarih.day,
                        picked.hour,
                        picked.minute,
                      );
                      if (selectedDateTime.isAfter(now)) {
                        // Don't allow future times - use current time instead
                        setModalState(() {
                          editedTime = TimeOfDay(hour: now.hour, minute: now.minute);
                        });
                      } else {
                        setModalState(() => editedTime = picked);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.purple.shade900.withValues(alpha: 0.3) : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${editedTime.hour.toString().padLeft(2, '0')}:${editedTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _bezEditOptionIcon(
                      Icons.water_drop_outlined,
                      l10n.wet,
                      Dil.islak,
                      Colors.blue,
                      tur,
                      (t) => setModalState(() => tur = t),
                    ),
                    _bezEditOptionIcon(
                      Icons.cloud_outlined,
                      l10n.dirty,
                      Dil.kirli,
                      Colors.brown,
                      tur,
                      (t) => setModalState(() => tur = t),
                    ),
                    _bezEditOptionIcon(
                      Icons.baby_changing_station_outlined,
                      l10n.both,
                      Dil.ikisiBirden,
                      Colors.purple,
                      tur,
                      (t) => setModalState(() => tur = t),
                    ),
                  ],
                ),
                // Editable notes field
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: l10n.addOptionalNote,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    prefixIcon: Icon(
                      Icons.note_outlined,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                _buildSaveButton(() async {
                  final newTarih = DateTime(
                    originalTarih.year,
                    originalTarih.month,
                    originalTarih.day,
                    editedTime.hour,
                    editedTime.minute,
                  );
                  final kayitlar = VeriYonetici.getKakaKayitlari();
                  kayitlar[index] = {
                    'tarih': newTarih,
                    'tur': tur,
                    if (notesController.text.isNotEmpty) 'notlar': notesController.text,
                  };
                  // Re-sort by time descending after editing
                  kayitlar.sort(
                    (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
                  );
                  await VeriYonetici.saveKakaKayitlari(kayitlar);
                  Navigator.pop(ctx);
                  setState(() {});
                }, const Color(0xFF9C27B0), l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteKaka(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final kayitlar = VeriYonetici.getKakaKayitlari();
      kayitlar.removeAt(index);
      await VeriYonetici.saveKakaKayitlari(kayitlar);
      setState(() {});
    }
  }

  void _editUyku(int index, Map<String, dynamic> kayit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    DateTime baslangic = kayit['baslangic'];
    DateTime bitis = kayit['bitis'];
    TimeOfDay baslangicSaat = TimeOfDay(
      hour: baslangic.hour,
      minute: baslangic.minute,
    );
    TimeOfDay bitisSaat = TimeOfDay(hour: bitis.hour, minute: bitis.minute);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✏️ ${l10n.editSleep}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeColumn(
                      l10n.start,
                      baslangicSaat,
                      (picked) {
                        setModalState(() => baslangicSaat = picked);
                      },
                      ctx,
                      isDark,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    _buildTimeColumn(
                      l10n.end,
                      bitisSaat,
                      (picked) {
                        setModalState(() => bitisSaat = picked);
                      },
                      ctx,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSaveButton(() async {
                  final yeniBaslangic = DateTime(
                    baslangic.year,
                    baslangic.month,
                    baslangic.day,
                    baslangicSaat.hour,
                    baslangicSaat.minute,
                  );
                  var yeniBitis = DateTime(
                    bitis.year,
                    bitis.month,
                    bitis.day,
                    bitisSaat.hour,
                    bitisSaat.minute,
                  );
                  if (yeniBitis.isBefore(yeniBaslangic)) {
                    yeniBitis = yeniBitis.add(const Duration(days: 1));
                  }
                  final sure = yeniBitis.difference(yeniBaslangic);
                  final kayitlar = VeriYonetici.getUykuKayitlari();
                  kayitlar[index] = {
                    'baslangic': yeniBaslangic,
                    'bitis': yeniBitis,
                    'sure': sure,
                  };
                  await VeriYonetici.saveUykuKayitlari(kayitlar);
                  Navigator.pop(ctx);
                  setState(() {});
                }, const Color(0xFF3F51B5), l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteUyku(int index) async {
    final confirm = await _showDeleteConfirm();
    if (confirm == true) {
      final kayitlar = VeriYonetici.getUykuKayitlari();
      kayitlar.removeAt(index);
      await VeriYonetici.saveUykuKayitlari(kayitlar);
      setState(() {});
    }
  }

  // ============ HELPER WIDGETS ============

  Widget _buildTurButtonIcon(
    IconData icon,
    String label,
    String value,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationEditor(
    int minutes,
    Function(int) onChanged,
    bool isDark,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await _showCupertinoDurationPicker(
          context,
          Duration(minutes: minutes),
        );
        if (picked != null) {
          onChanged(picked.inMinutes);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.pink.shade900.withValues(alpha: 0.3)
              : Colors.pink.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: isDark ? Colors.pink.shade200 : const Color(0xFFE91E63),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.duration,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Text(
                minutes > 0
                    ? '$minutes ${l10n.minAbbrev}'
                    : l10n.tapToSetTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.pink.shade200 : const Color(0xFFE91E63),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemeRow(
    String label,
    String emoji,
    int dakika,
    Function(int) onChanged,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        _buildCircleButton(
          Icons.remove,
          () => onChanged((dakika - 1).clamp(0, 60)),
        ),
        const SizedBox(width: 12),
        Text(
          '$dakika ${l10n.minAbbrev}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        const SizedBox(width: 12),
        _buildCircleButton(
          Icons.add,
          () => onChanged((dakika + 1).clamp(0, 60)),
        ),
      ],
    );
  }

  Widget _buildMiktarEditor(
    int miktar,
    Function(int) onChanged,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.pink.shade900.withValues(alpha: 0.3)
            : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(
            Icons.remove,
            () => onChanged((miktar - 10).clamp(0, 500)),
          ),
          const SizedBox(width: 24),
          Text(
            '$miktar ${l10n.mlAbbrev}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(width: 24),
          _buildCircleButton(
            Icons.add,
            () => onChanged((miktar + 10).clamp(0, 500)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFE91E63),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  /// Shows a Cupertino-style time picker in a bottom sheet
  Future<TimeOfDay?> _showCupertinoTimePicker(BuildContext context, TimeOfDay initialTime) async {
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
                maximumDate: DateTime.now(),
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
  Future<Duration?> _showCupertinoDurationPicker(BuildContext context, Duration initialDuration) async {
    final l10n = AppLocalizations.of(context)!;
    Duration selectedDuration = initialDuration;

    final result = await showModalBottomSheet<Duration>(
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
            // Header with buttons
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
                    onPressed: () => Navigator.pop(context, selectedDuration),
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
            // Cupertino Timer Picker
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: initialDuration,
                onTimerDurationChanged: (Duration duration) {
                  selectedDuration = duration;
                },
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  Widget _buildTimeSelector(
    TimeOfDay saat,
    Function(TimeOfDay) onChanged,
    BuildContext ctx,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await _showCupertinoTimePicker(ctx, saat);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE91E63), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, color: Color(0xFFE91E63)),
            const SizedBox(width: 8),
            Text(
              '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    TimeOfDay saat,
    Function(TimeOfDay) onChanged,
    BuildContext ctx,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await _showCupertinoTimePicker(ctx, saat);
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(VoidCallback onPressed, Color color, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          '✓ ${l10n.update}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _bezEditOptionIcon(
    IconData icon,
    String label,
    String value,
    Color color,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🗑️ ${l10n.delete}',
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
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
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
