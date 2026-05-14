import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoDatePicker, CupertinoDatePickerMode;
import 'package:flutter/foundation.dart' show kDebugMode;
import '../theme/app_theme.dart';
import '../models/veri_yonetici.dart';
import '../widgets/decorative_background.dart';
import '../l10n/app_localizations.dart';
import 'allergies_screen.dart';
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
  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _saveErrorMessage(AppLocalizations l10n, Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) return l10n.saveFailedTryAgain;
    return l10n.errorWithMessage(message);
  }

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

  Color _creatorColorFor(String uid) {
    if (uid.isEmpty) return AppColors.lavender;
    if (uid == _currentUid) return AppColors.peach;
    const others = <Color>[AppColors.lavender, AppColors.mint];
    final index = uid.hashCode.abs() % others.length;
    return others[index];
  }

  String? _creatorLabelFor(Map<String, dynamic> kayit) {
    final createdBy = (kayit['createdBy'] ?? '').toString().trim();
    if (createdBy.isEmpty) return null;
    if (createdBy == _currentUid) return 'Sen';
    final createdByName = (kayit['createdByName'] ?? '').toString().trim();
    return createdByName.isNotEmpty ? createdByName : 'Diğer';
  }

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
                      Text(
                        '•',
                        style: const TextStyle(color: Color(0xFF888888)),
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

              final normalizedTur = tur.toLowerCase();
              final isSolid =
                  kategori == 'Solid' || normalizedTur.contains('kat');
              final isNursing = _isNursingMamaRecord(kayit);
              final isBottleFeeding = !isSolid && !isNursing && miktar > 0;
              final showAllergyAction = isSolid || isBottleFeeding;
              if (isSolid) {
                final solidDakika = kayit['solidDakika'] as int? ?? 0;
                title = l10n.solid;
                if (solidDakika > 0) {
                  subtitle =
                      '${l10n.solidFood} • $solidDakika ${l10n.minAbbrev}';
                } else {
                  subtitle = l10n.solidFood;
                }
              } else if (isNursing) {
                title = l10n.breastfeeding;
                final toplamDakika = sol + sag;
                subtitle = '${l10n.total}: $toplamDakika ${l10n.minAbbrev}';
                if (kDebugMode && !_loggedNursingSeparatorSample) {
                  _loggedNursingSeparatorSample = true;
                  debugPrint('[ActivitiesScreen] nursing subtitle="$subtitle"');
                }
              } else {
                title = normalizedTur.contains('form')
                    ? l10n.formula
                    : l10n.bottleBreastMilk;
                subtitle = '$miktar ${l10n.mlAbbrev}';
              }

              return _buildListItem(
                kayit: kayit,
                title: title,
                subtitle: subtitle,
                time: _formatTime(tarih),
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
                secondaryActionLabel: showAllergyAction
                    ? l10n.reportAllergy
                    : null,
                onSecondaryAction: showAllergyAction
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllergiesScreen(),
                          ),
                        );
                      }
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

              String diaperLabel = l10n.both;
              if (tur == 'wet') {
                diaperLabel = l10n.wet;
              } else if (tur == 'dirty') {
                diaperLabel = l10n.dirty;
              } else if (tur == 'both') {
                diaperLabel = l10n.both;
              }

              return _buildListItem(
                kayit: kayit,
                title: diaperLabel,
                subtitle: l10n.diaperChange,
                time: _formatTime(tarih),
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
                kayit: kayit,
                title: l10n.sleep,
                subtitle:
                    '${_formatDuration(sure, l10n)} • ${_formatTime(baslangic)} - ${_formatTime(bitis)}',
                time: _formatTime(bitis),
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
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
          ),
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
    required Map<String, dynamic> kayit,
    required String title,
    required String subtitle,
    required String time,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    String? notes,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
  }) {
    final createdBy = (kayit['createdBy'] ?? '').toString().trim();
    final creatorLabel = _creatorLabelFor(kayit);
    return Dismissible(
      key: ValueKey('$title|$subtitle|$time|${notes ?? ''}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFF6B6B),
          size: 22,
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E0F7).withValues(alpha: 0.38),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE5E0F7).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: subtitleColor.withValues(alpha: 0.76),
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (notes != null && notes.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            notes,
                            style: TextStyle(
                              color: subtitleColor.withValues(alpha: 0.58),
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (creatorLabel != null ||
                            (secondaryActionLabel != null &&
                                onSecondaryAction != null)) ...[
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (creatorLabel != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: _creatorColorFor(createdBy),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 110,
                                      ),
                                      child: Text(
                                        creatorLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: subtitleColor.withValues(
                                            alpha: 0.66,
                                          ),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (secondaryActionLabel != null &&
                                  onSecondaryAction != null)
                                InkWell(
                                  onTap: onSecondaryAction,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFF3EE,
                                      ).withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFFD8C0,
                                        ).withValues(alpha: 0.65),
                                      ),
                                    ),
                                    child: Text(
                                      secondaryActionLabel,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD4897A),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 58,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (time.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF7F1F6,
                              ).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFE5E0F7,
                                ).withValues(alpha: 0.55),
                              ),
                            ),
                            child: Text(
                              time,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: subtitleColor.withValues(alpha: 0.68),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: subtitleColor.withValues(alpha: 0.24),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ EDIT & DELETE FUNCTIONS ============

  _CareEditType _resolveMamaEditType(Map<String, dynamic> kayit) {
    return _isNursingMamaRecord(kayit)
        ? _CareEditType.nursing
        : _CareEditType.feeding;
  }

  bool _isNursingMamaRecord(Map<String, dynamic> kayit) {
    final explicitType = (kayit['type'] ?? '').toString().trim().toLowerCase();
    if (explicitType == 'nursing') return true;

    final kategori = (kayit['kategori'] ?? 'Milk')
        .toString()
        .trim()
        .toLowerCase();
    if (kategori == 'solid') return false;

    final tur = (kayit['tur'] ?? '').toString().trim().toLowerCase();
    final hasNursingSignal =
        tur.contains('anne') ||
        tur.contains('emzir') ||
        tur.contains('nursing') ||
        tur.contains('breastfeeding');
    final isBottle = tur.contains('biberon') || tur.contains('bottle');
    return hasNursingSignal && !isBottle;
  }

  bool _sameDateTimeValue(dynamic a, dynamic b) {
    if (a is DateTime && b is DateTime) return a.isAtSameMomentAs(b);
    return a == b;
  }

  bool _sameMamaIdentity(
    Map<String, dynamic> candidate,
    Map<String, dynamic> original,
  ) {
    return _sameDateTimeValue(candidate['tarih'], original['tarih']) &&
        (candidate['tur'] ?? '').toString() ==
            (original['tur'] ?? '').toString() &&
        (candidate['kategori'] ?? 'Milk').toString() ==
            (original['kategori'] ?? 'Milk').toString() &&
        (candidate['solDakika'] ?? 0) == (original['solDakika'] ?? 0) &&
        (candidate['sagDakika'] ?? 0) == (original['sagDakika'] ?? 0) &&
        (candidate['miktar'] ?? 0) == (original['miktar'] ?? 0);
  }

  Future<bool> _updateMamaRecordPreservingIdentity({
    required String recordId,
    required Map<String, dynamic> original,
    required Map<String, dynamic> updated,
  }) async {
    final kayitlar = VeriYonetici.getMamaKayitlari();
    final normalizedId = recordId.trim();
    var index = normalizedId.isEmpty
        ? -1
        : kayitlar.indexWhere(
            (k) => (k['id'] ?? '').toString().trim() == normalizedId,
          );
    if (index == -1) {
      index = kayitlar.indexWhere((k) => _sameMamaIdentity(k, original));
    }
    if (index == -1) {
      debugPrint(
        '[ActivitiesScreen] mama_edit failed: id=$normalizedId original=$original',
      );
      return false;
    }

    final existing = kayitlar[index];
    final existingId = (existing['id'] ?? normalizedId).toString().trim();
    kayitlar[index] = {
      ...existing,
      ...updated,
      if (existingId.isNotEmpty) 'id': existingId,
      'babyId': existing['babyId'],
    };
    await VeriYonetici.saveMamaKayitlari(
      kayitlar,
      sharedNoopHealRecordId: existingId,
    );
    return true;
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

  Future<DateTime?> _pickEventDate(DateTime initial) async {
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
    final candidate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      initial.hour,
      initial.minute,
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
    required BuildContext sheetContext,
    required String title,
    required Widget child,
    required VoidCallback onSave,
    required bool isSaving,
    bool useFeedingBubbles = false,
    double contentTopSpacing = 10,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(sheetContext);
    final sheetColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFFFB4A2).withValues(alpha: 0.18),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  if (useFeedingBubbles) ...[
                    Positioned(
                      top: -70,
                      right: -44,
                      child: _SheetGlow(
                        size: 156,
                        color: const Color(
                          0xFFFFB4A2,
                        ).withValues(alpha: isDark ? 0.06 : 0.12),
                      ),
                    ),
                    Positioned(
                      top: 76,
                      left: -52,
                      child: _SheetGlow(
                        size: 132,
                        color: const Color(
                          0xFFE5E0F7,
                        ).withValues(alpha: isDark ? 0.05 : 0.14),
                      ),
                    ),
                    Positioned(
                      top: 188,
                      right: -18,
                      child: _SheetGlow(
                        size: 84,
                        color: const Color(
                          0xFFFFF4E5,
                        ).withValues(alpha: isDark ? 0.03 : 0.09),
                      ),
                    ),
                    Positioned(
                      bottom: 92,
                      left: 24,
                      child: _SheetGlow(
                        size: 82,
                        color: const Color(
                          0xFFDCEEF2,
                        ).withValues(alpha: isDark ? 0.04 : 0.1),
                      ),
                    ),
                    Positioned(
                      bottom: -64,
                      right: 64,
                      child: _SheetGlow(
                        size: 122,
                        color: const Color(
                          0xFFF6E4B8,
                        ).withValues(alpha: isDark ? 0.035 : 0.085),
                      ),
                    ),
                  ] else ...[
                    Positioned(
                      top: -56,
                      right: -38,
                      child: _SheetGlow(
                        size: 138,
                        color: const Color(
                          0xFFFFB4A2,
                        ).withValues(alpha: isDark ? 0.07 : 0.13),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: -50,
                      child: _SheetGlow(
                        size: 124,
                        color: const Color(
                          0xFFE5E0F7,
                        ).withValues(alpha: isDark ? 0.06 : 0.16),
                      ),
                    ),
                    Positioned(
                      top: 142,
                      left: media.size.width * 0.26,
                      child: _SheetGlow(
                        size: 116,
                        color: const Color(
                          0xFFF7E9F2,
                        ).withValues(alpha: isDark ? 0.04 : 0.12),
                      ),
                    ),
                    Positioned(
                      bottom: 92,
                      left: 24,
                      child: _SheetGlow(
                        size: 72,
                        color: const Color(
                          0xFFDCEEF2,
                        ).withValues(alpha: isDark ? 0.045 : 0.11),
                      ),
                    ),
                    Positioned(
                      bottom: -54,
                      right: 62,
                      child: _SheetGlow(
                        size: 108,
                        color: const Color(
                          0xFFF6E4B8,
                        ).withValues(alpha: isDark ? 0.04 : 0.09),
                      ),
                    ),
                    Positioned(
                      bottom: 34,
                      right: 92,
                      child: _SheetGlow(
                        size: 144,
                        color: const Color(
                          0xFFFFE9DD,
                        ).withValues(alpha: isDark ? 0.035 : 0.11),
                      ),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, contentTopSpacing, 20, 20),
                    child: AbsorbPointer(
                      absorbing: isSaving,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: media.size.height * 0.9,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 6,
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (isDark
                                            ? Colors.white
                                            : const Color(0xFFF2D9D0))
                                        .withValues(alpha: isDark ? 0.2 : 0.92),
                                    (isDark
                                            ? Colors.white
                                            : const Color(0xFFE6C3B8))
                                        .withValues(
                                          alpha: isDark ? 0.08 : 0.76,
                                        ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? Colors.black
                                                : const Color(0xFFE6C8BF))
                                            .withValues(
                                              alpha: isDark ? 0.26 : 0.28,
                                            ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      height: 1.1,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1C1C1E),
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      Navigator.of(sheetContext).pop(),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.72)
                                        : const Color(0xFF918998),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDark
                                        ? AppColors.textSecondaryDark
                                        : const Color(0xFF8A8494),
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : Colors.white.withValues(alpha: 0.56),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.06,
                                              )
                                            : const Color(
                                                0xFFEEDFD9,
                                              ).withValues(alpha: 0.92),
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    l10n.cancel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.72)
                                          : const Color(0xFF918998),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Flexible(
                              child: SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                child: child,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE39A86,
                                    ).withValues(alpha: isDark ? 0.16 : 0.24),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(
                                      alpha: isDark ? 0.0 : 0.32,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: isSaving ? null : onSave,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFE39A86),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFFE39A86,
                                    ).withValues(alpha: 0.42),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          l10n.save,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetStepper({
    required String title,
    required String value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    IconData? leadingIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF2E5E1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFE7D4CE).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFFFF4EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                leadingIcon,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFFCF866F),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF8F8796),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF4A3F3F),
                  ),
                ),
              ],
            ),
          ),
          _SheetCircleButton(
            icon: Icons.remove_rounded,
            onTap: onDecrease,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFFFFCF9),
            foregroundColor: isDark
                ? Colors.white.withValues(alpha: 0.78)
                : const Color(0xFF8A8393),
            borderColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0E4E1),
            shadowColor: !isDark
                ? const Color(0xFFE6D7D2).withValues(alpha: 0.18)
                : null,
          ),
          const SizedBox(width: 8),
          _SheetCircleButton(
            icon: Icons.add_rounded,
            onTap: onIncrease,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFFFFCF9),
            foregroundColor: const Color(0xFFE08F78),
            borderColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0E4E1),
            shadowColor: !isDark
                ? const Color(0xFFE6D7D2).withValues(alpha: 0.18)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSheetTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 2,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF2E5E1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFE7D4CE).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : const Color(0xFF4A3F3F).withValues(alpha: 0.32),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? Colors.white.withValues(alpha: 0.84)
              : const Color(0xFF4A3F3F).withValues(alpha: 0.84),
        ),
      ),
    );
  }

  Widget _buildSegmentedField({required Widget child, String? label}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2B2B2B)
            : const Color(0xFFFFFCF8).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF2E5E1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFE7D4CE).withValues(alpha: 0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.7),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF8F8796),
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildFeedingSheetSegmentedControl({
    required BuildContext context,
    required String groupValue,
    required Map<String, String> labels,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252530) : const Color(0xFFF6EFF2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFE7D4CE).withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.72),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: Row(
        children: labels.entries
            .map((entry) {
              final value = entry.key;
              final label = entry.value;
              final isSelected = groupValue == value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => onChanged(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: isSelected && !isDark
                            ? const LinearGradient(
                                colors: [Color(0xFFFFFEFB), Color(0xFFFFF5EF)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: isSelected
                            ? (isDark
                                  ? const Color(0xFF3A3A46)
                                  : const Color(0xFFFFFCF7))
                            : Colors.transparent,
                        border: isSelected && !isDark
                            ? Border.all(color: const Color(0xFFF3E2D6))
                            : null,
                        boxShadow: isSelected && !isDark
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFDFC7BE,
                                  ).withValues(alpha: 0.22),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  blurRadius: 8,
                                  offset: const Offset(0, -1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFB86E5A)
                              : isDark
                              ? Colors.white.withValues(alpha: 0.74)
                              : const Color(0xFF6F6878),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  String _formatInlineDate(DateTime value) {
    final l10n = AppLocalizations.of(context)!;
    if (_isToday(value)) return l10n.today;
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }

  Widget _buildInlineDateButton({
    required DateTime value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFFFF4EE),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0E4E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: isDark ? Colors.white70 : const Color(0xFFCF866F),
            ),
            const SizedBox(width: 6),
            Text(
              _formatInlineDate(value),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.82)
                    : const Color(0xFF866F65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingSheetStepper({
    required String title,
    required String value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    IconData? leadingIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF2E5E1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFE7D4CE).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          _SheetCircleButton(
            icon: Icons.remove_rounded,
            onTap: onDecrease,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFFFFCF9),
            foregroundColor: isDark
                ? Colors.white.withValues(alpha: 0.78)
                : const Color(0xFF8A8393),
            borderColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0E4E1),
            shadowColor: !isDark
                ? const Color(0xFFE6D7D2).withValues(alpha: 0.18)
                : null,
          ),
          const SizedBox(width: 14),
          if (leadingIcon != null) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFFFF4EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                leadingIcon,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFFCF866F),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF8F8796),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF4A3F3F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _SheetCircleButton(
            icon: Icons.add_rounded,
            onTap: onIncrease,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFFFFCF9),
            foregroundColor: const Color(0xFFE08F78),
            borderColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0E4E1),
            shadowColor: !isDark
                ? const Color(0xFFE6D7D2).withValues(alpha: 0.18)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingSheetRowTile({
    required String title,
    required String value,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailingAccessory,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFFFFCF8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF2E5E1),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFE7D4CE).withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFFFF4EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFFCF866F),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF8F8796),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF4A3F3F),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF8F8796),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingAccessory != null) ...[
              const SizedBox(width: 10),
              trailingAccessory,
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.48)
                  : const Color(0xFFB2A7AE),
            ),
          ],
        ),
      ),
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
    messenger.hideCurrentSnackBar();

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
      final saved = await action();
      debugPrint(
        '[ActivitiesScreen] care_edit_save result type=$recordType id=$recordId saved=$saved',
      );
      if (!saved) {
        throw StateError(l10n.recordCouldNotBeUpdated);
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
      messenger.showSnackBar(
        SnackBar(content: Text(_saveErrorMessage(l10n, e))),
      );
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
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          sheetContext: ctx,
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
                  'type': 'nursing',
                  'tur': 'Anne Sütü',
                  'solDakika': side == 'left' ? duration : 0,
                  'sagDakika': side == 'right' ? duration : 0,
                  'miktar': 0,
                  'kategori': 'Milk',
                };
                return _updateMamaRecordPreservingIdentity(
                  recordId: recordId,
                  original: kayit,
                  updated: updated,
                );
              },
            );
          },
          child: Column(
            children: [
              _buildSegmentedField(
                label: l10n.breastfeeding,
                child: _buildFeedingSheetSegmentedControl(
                  context: ctx,
                  groupValue: side,
                  labels: <String, String>{
                    'left': l10n.left,
                    'right': l10n.right,
                  },
                  onChanged: (v) {
                    if (v != null) setModalState(() => side = v);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildSheetStepper(
                title: l10n.duration,
                value: '$duration ${l10n.minAbbrev}',
                onDecrease: () => setModalState(
                  () => duration = (duration - 1).clamp(1, 180),
                ),
                onIncrease: () => setModalState(
                  () => duration = (duration + 1).clamp(1, 180),
                ),
              ),
              const SizedBox(height: 12),
              _buildFeedingSheetRowTile(
                title: l10n.time,
                value: _formatTime(eventTime),
                subtitle: _formatInlineDate(eventTime),
                trailingAccessory: _buildInlineDateButton(
                  value: eventTime,
                  onTap: () async {
                    final picked = await _pickEventDate(eventTime);
                    if (picked != null) setModalState(() => eventTime = picked);
                  },
                ),
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
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          sheetContext: ctx,
          title: l10n.editTitleFeeding,
          isSaving: isSaving,
          useFeedingBubbles: true,
          contentTopSpacing: 14,
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
                return _updateMamaRecordPreservingIdentity(
                  recordId: recordId,
                  original: kayit,
                  updated: updated,
                );
              },
            );
          },
          child: Column(
            children: [
              const SizedBox(height: 4),
              _buildSegmentedField(
                label: l10n.healthType,
                child: _buildFeedingSheetSegmentedControl(
                  context: ctx,
                  groupValue: selectedType,
                  labels: <String, String>{
                    'formula': l10n.formula,
                    'bottleMilk': l10n.breastMilk,
                    'solid': l10n.solid,
                  },
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedType = v);
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (selectedType == 'solid')
                _buildSheetStepper(
                  title: l10n.duration,
                  value: '$solidDuration ${l10n.minAbbrev}',
                  onDecrease: () => setModalState(
                    () => solidDuration = (solidDuration - 5).clamp(0, 180),
                  ),
                  onIncrease: () => setModalState(
                    () => solidDuration = (solidDuration + 5).clamp(0, 180),
                  ),
                )
              else
                _buildFeedingSheetStepper(
                  title: l10n.amount,
                  value: '$amount ${l10n.mlAbbrev}',
                  leadingIcon: Icons.local_drink_outlined,
                  onDecrease: () =>
                      setModalState(() => amount = (amount - 10).clamp(0, 500)),
                  onIncrease: () =>
                      setModalState(() => amount = (amount + 10).clamp(0, 500)),
                ),
              if (selectedType == 'solid') ...[
                const SizedBox(height: 14),
                _buildSheetTextField(
                  controller: noteController,
                  hintText: l10n.solidFoodHint,
                ),
              ],
              const SizedBox(height: 14),
              _buildFeedingSheetRowTile(
                title: l10n.time,
                value: _formatTime(eventTime),
                subtitle: _formatInlineDate(eventTime),
                trailingAccessory: _buildInlineDateButton(
                  value: eventTime,
                  onTap: () async {
                    final picked = await _pickEventDate(eventTime);
                    if (picked != null) setModalState(() => eventTime = picked);
                  },
                ),
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
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          sheetContext: ctx,
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
                final Map<String, dynamic> updated = {
                  'id': recordId,
                  'tarih': eventTime,
                  'tur': normalized,
                  'diaperType': normalized,
                  'eventType': VeriYonetici.diaperEventType,
                  'notlar': noteController.text,
                };
                debugPrint(
                  '[ActivitiesScreen] diaper_edit payload '
                  'type=diaper id=$recordId updated=$updated',
                );
                return VeriYonetici.updateKakaKaydiById(recordId, updated);
              },
            );
          },
          child: Column(
            children: [
              _buildSegmentedField(
                label: l10n.diaperChange,
                child: _buildFeedingSheetSegmentedControl(
                  context: ctx,
                  groupValue: type,
                  labels: <String, String>{
                    'wet': l10n.diaperWet,
                    'dirty': l10n.diaperDirty,
                    'both': l10n.diaperBoth,
                  },
                  onChanged: (v) {
                    if (v != null) setModalState(() => type = v);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildFeedingSheetRowTile(
                title: l10n.time,
                value: _formatTime(eventTime),
                subtitle: _formatInlineDate(eventTime),
                trailingAccessory: _buildInlineDateButton(
                  value: eventTime,
                  onTap: () async {
                    final picked = await _pickEventDate(eventTime);
                    if (picked != null) setModalState(() => eventTime = picked);
                  },
                ),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(eventTime);
                  if (picked != null) setModalState(() => eventTime = picked);
                },
              ),
              const SizedBox(height: 12),
              _buildSheetTextField(
                controller: noteController,
                hintText: l10n.addOptionalNote,
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
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildSheetScaffold(
          sheetContext: ctx,
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
                final Map<String, dynamic> updated = {
                  'id': recordId,
                  'baslangic': start,
                  'bitis': normalizedEnd,
                  'sure': normalizedEnd.difference(start),
                };
                debugPrint(
                  '[ActivitiesScreen] sleep_edit payload '
                  'type=sleep id=$recordId updated=$updated',
                );
                return VeriYonetici.updateUykuKaydiById(recordId, updated);
              },
            );
          },
          child: Column(
            children: [
              _buildFeedingSheetRowTile(
                title: l10n.start,
                value: _formatTime(start),
                subtitle: _formatInlineDate(start),
                trailingAccessory: _buildInlineDateButton(
                  value: start,
                  onTap: () async {
                    final picked = await _pickEventDate(start);
                    if (picked != null) setModalState(() => start = picked);
                  },
                ),
                onTap: () async {
                  final picked = await _pickNormalizedDateTime(start);
                  if (picked != null) setModalState(() => start = picked);
                },
              ),
              const SizedBox(height: 12),
              _buildFeedingSheetRowTile(
                title: l10n.end,
                value: _formatTime(end),
                subtitle: _formatInlineDate(end),
                trailingAccessory: _buildInlineDateButton(
                  value: end,
                  onTap: () async {
                    final picked = await _pickEventDate(end);
                    if (picked != null) setModalState(() => end = picked);
                  },
                ),
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
          l10n.delete,
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

class _SheetGlow extends StatelessWidget {
  const _SheetGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _SheetCircleButton extends StatelessWidget {
  const _SheetCircleButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.shadowColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? const Color(0xFF3A3A46) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                borderColor ??
                (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE5E0F7).withValues(alpha: 0.7)),
          ),
          boxShadow: shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor!,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              foregroundColor ??
              (isDark ? Colors.white : const Color(0xFF6F6F6F)),
        ),
      ),
    );
  }
}
