import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';

class IlaclarScreen extends StatefulWidget {
  const IlaclarScreen({super.key});

  @override
  State<IlaclarScreen> createState() => _IlaclarScreenState();
}

class _IlaclarScreenState extends State<IlaclarScreen> {
  static const String _filterAll = 'all';
  static const String _filterDaily = 'daily';
  static const String _filterPrn = 'prn';
  static const String _filterVaccineProtocol = 'vaccine_protocol';

  final ReminderService _reminderService = ReminderService();
  List<Map<String, dynamic>> _medications = [];
  String _activeFilter = _filterAll;
  final Set<String> _recentlyTappedMedicationIds = <String>{};
  final Map<String, DateTime> _doseChipLastTapAt = <String, DateTime>{};

  @override
  void initState() {
    super.initState();
    _loadMedications();
    Future.microtask(_syncAllMedicationReminders);
  }

  void _loadMedications() {
    setState(() {
      _medications = VeriYonetici.getIlacKayitlari();
      _medications.sort((a, b) {
        final aActive = a['isActive'] == true;
        final bActive = b['isActive'] == true;
        if (aActive != bActive) return aActive ? -1 : 1;
        final aDate = a['createdAt'] as DateTime;
        final bDate = b['createdAt'] as DateTime;
        return bDate.compareTo(aDate);
      });
    });
  }

  List<Map<String, dynamic>> _filteredMedications() {
    if (_activeFilter == _filterAll) return _medications;
    return _medications
        .where((m) => (m['scheduleType'] ?? _filterPrn) == _activeFilter)
        .toList();
  }

  Future<void> _addMedication() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const _MedicationFormScreen()),
    );
    if (result == true) {
      _loadMedications();
      await _syncAllMedicationReminders();
    }
  }

  Future<void> _editMedication(Map<String, dynamic> medication) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => _MedicationFormScreen(medication: medication),
      ),
    );
    if (result == true) {
      _loadMedications();
      await _syncAllMedicationReminders();
    }
  }

  Future<void> _deleteMedication(Map<String, dynamic> medication) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.attention),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _cancelRemindersForMedication(medication);
    _medications.removeWhere((m) => m['id'] == medication['id']);
    await VeriYonetici.saveIlacKayitlari(_medications);
    _loadMedications();
  }

  Future<void> _toggleActive(Map<String, dynamic> medication) async {
    final index = _medications.indexWhere((m) => m['id'] == medication['id']);
    if (index == -1) return;
    _medications[index]['isActive'] = !(medication['isActive'] == true);
    await VeriYonetici.saveIlacKayitlari(_medications);
    await _syncMedicationReminders(_medications[index]);
    _loadMedications();
  }

  List<String> _dailyTimes(Map<String, dynamic> med) {
    final raw = med['dailyTimes'];
    if (raw is! List) return const [];
    return raw
        .map((e) => e?.toString() ?? '')
        .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
        .toList();
  }

  String _scheduleSubtitle(Map<String, dynamic> med, AppLocalizations l10n) {
    final scheduleType = (med['scheduleType'] as String?) ?? _filterPrn;
    if (scheduleType == _filterDaily) {
      final times = _dailyTimes(med);
      return '${l10n.everyDay} • ${(times.isEmpty ? ['09:00'] : times).join(', ')}';
    }
    if (scheduleType == _filterVaccineProtocol) {
      final vaccineId = med['vaccineId'] as String?;
      final vaccine = VeriYonetici.getAsiKayitlari()
          .where((v) => v['id'] == vaccineId)
          .firstOrNull;
      final vaccineDate = vaccine?['tarih'] as DateTime?;
      final linked = vaccine == null
          ? l10n.noVaccineLink
          : '${vaccine['ad']} (${vaccineDate == null ? l10n.selectDate : formatLocalizedDate(context, vaccineDate)})';
      return '${l10n.vaccineProtocolLabel} • ${l10n.linkedToVaccine(linked)}';
    }
    return l10n.asNeeded;
  }

  Future<void> _logGivenNow(Map<String, dynamic> medication) async {
    final medId = medication['id'] as String;
    if (_recentlyTappedMedicationIds.contains(medId)) return;
    _recentlyTappedMedicationIds.add(medId);
    if (mounted) setState(() {});
    Future.delayed(const Duration(seconds: 1), () {
      _recentlyTappedMedicationIds.remove(medId);
      if (mounted) setState(() {});
    });

    final l10n = AppLocalizations.of(context)!;
    final doseId = await VeriYonetici.upsertIlacDozKaydi(
      medicationId: medication['id'] as String,
      vaccineId: medication['scheduleType'] == _filterVaccineProtocol
          ? medication['vaccineId'] as String?
          : null,
      doseIndex: 0,
    );
    HapticFeedback.selectionClick();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.savedMessage),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            await VeriYonetici.deleteIlacDozKaydi(doseId);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
    setState(() {});
  }

  int _doseCount(Map<String, dynamic> med) {
    return _uniqueDoseLogs(med).length;
  }

  List<Map<String, dynamic>> _doseLogs(Map<String, dynamic> med) {
    final logs = VeriYonetici.getIlacDozKayitlari(
      medicationId: med['id'] as String,
    ).toList();
    logs.sort(
      (a, b) => (b['givenAt'] as DateTime).compareTo(a['givenAt'] as DateTime),
    );
    return logs;
  }

  List<Map<String, dynamic>> _uniqueDoseLogs(Map<String, dynamic> med) {
    final logs = _doseLogs(med);
    if (_isProtocolMedication(med)) {
      final seen = <String>{};
      final unique = <Map<String, dynamic>>[];
      for (final log in logs) {
        final givenAt = log['givenAt'] as DateTime;
        final day = dateOnly(givenAt);
        final step = _protocolStepForLog(log) ?? '';
        final key = '${day.toIso8601String()}::$step';
        if (seen.contains(key)) continue;
        seen.add(key);
        unique.add(log);
      }
      return unique;
    }
    final dailyTimes = _dailyTimes(med);
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final log in logs) {
      final givenAt = log['givenAt'] as DateTime;
      final day = dateOnly(givenAt);
      final doseIndex = _doseIndexForLog(log, dailyTimes) ?? 0;
      final key = '${day.toIso8601String()}::$doseIndex';
      if (seen.contains(key)) continue;
      seen.add(key);
      unique.add(log);
    }
    return unique;
  }

  DateTime? _lastGivenAt(Map<String, dynamic> med) {
    final logs = _uniqueDoseLogs(med);
    if (logs.isEmpty) return null;
    return logs.first['givenAt'] as DateTime;
  }

  bool _isMultiDoseRoutine(Map<String, dynamic> med) {
    return ((med['scheduleType'] as String?) ?? _filterPrn) == _filterDaily &&
        _dailyTimes(med).length > 1;
  }

  bool _isProtocolMedication(Map<String, dynamic> med) {
    return ((med['scheduleType'] as String?) ?? _filterPrn) ==
        _filterVaccineProtocol;
  }

  int? _doseIndexForLog(Map<String, dynamic> log, List<String> dailyTimes) {
    final rawIndex = log['doseIndex'];
    if (rawIndex is int && rawIndex >= 0 && rawIndex < dailyTimes.length) {
      return rawIndex;
    }
    if (rawIndex is num) {
      final idx = rawIndex.toInt();
      if (idx >= 0 && idx < dailyTimes.length) return idx;
    }
    final scheduled = log['scheduledTime']?.toString();
    if (scheduled != null) {
      final idx = dailyTimes.indexOf(scheduled);
      if (idx >= 0) return idx;
    }
    return null;
  }

  String? _protocolStepForLog(Map<String, dynamic> log) {
    final step = log['protocolStep']?.toString().trim().toLowerCase();
    if (step == 'before' || step == 'after') return step;
    return null;
  }

  Map<int, Map<String, dynamic>> _todayDoseLogsByIndex(
    Map<String, dynamic> med,
  ) {
    final today = dateOnly(DateTime.now());
    final dailyTimes = _dailyTimes(med);
    final byIndex = <int, Map<String, dynamic>>{};
    for (final log in _doseLogs(med)) {
      final givenAt = log['givenAt'] as DateTime;
      if (dateOnly(givenAt) != today) continue;
      final idx = _doseIndexForLog(log, dailyTimes);
      if (idx == null) continue;
      byIndex.putIfAbsent(idx, () => log);
    }
    return byIndex;
  }

  Map<String, Map<String, dynamic>> _todayProtocolLogs(
    Map<String, dynamic> med,
  ) {
    final today = dateOnly(DateTime.now());
    final byStep = <String, Map<String, dynamic>>{};
    for (final log in _doseLogs(med)) {
      final givenAt = log['givenAt'] as DateTime;
      if (dateOnly(givenAt) != today) continue;
      final step = _protocolStepForLog(log);
      if (step == null) continue;
      byStep.putIfAbsent(step, () => log);
    }
    return byStep;
  }

  int _targetDailyDoseCount(Map<String, dynamic> med) {
    if (_isProtocolMedication(med)) return 2;
    final times = _dailyTimes(med);
    if (times.isNotEmpty) return times.length;
    return 1;
  }

  String? _last7DaysSummary(Map<String, dynamic> med, AppLocalizations l10n) {
    if (!_isMultiDoseRoutine(med)) return null;
    final now = DateTime.now();
    final target = _targetDailyDoseCount(med);
    final dailyTimes = _dailyTimes(med);
    final counts = <DateTime, Set<int>>{};
    for (final log in _doseLogs(med)) {
      final givenAt = log['givenAt'] as DateTime;
      final day = dateOnly(givenAt);
      final daysBack = dateOnly(now).difference(day).inDays;
      if (daysBack < 1 || daysBack > 7) continue;
      final idx = _doseIndexForLog(log, dailyTimes) ?? 0;
      counts.putIfAbsent(day, () => <int>{}).add(idx);
    }
    if (counts.isEmpty) return null;

    final days = counts.keys.toList()..sort((a, b) => b.compareTo(a));
    final items = <String>[];
    for (final day in days.take(3)) {
      final label = day == dateOnly(now).subtract(const Duration(days: 1))
          ? l10n.yesterday
          : formatLocalizedDate(context, day);
      items.add('$label ${counts[day]!.length}/$target');
    }
    return items.join(' • ');
  }

  Future<void> _toggleDoseChip(Map<String, dynamic> med, int doseIndex) async {
    final medId = med['id'] as String;
    final key = '$medId:$doseIndex';
    final now = DateTime.now();
    final lastTap = _doseChipLastTapAt[key];
    if (lastTap != null &&
        now.difference(lastTap) < const Duration(seconds: 1)) {
      return;
    }
    _doseChipLastTapAt[key] = now;

    final dailyTimes = _dailyTimes(med);
    await VeriYonetici.upsertIlacDozKaydi(
      medicationId: medId,
      vaccineId: med['scheduleType'] == _filterVaccineProtocol
          ? med['vaccineId'] as String?
          : null,
      givenAt: DateTime.now(),
      doseIndex: doseIndex,
      scheduledTime: doseIndex >= 0 && doseIndex < dailyTimes.length
          ? dailyTimes[doseIndex]
          : null,
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleProtocolStep(
    Map<String, dynamic> med,
    String step,
  ) async {
    final medId = med['id'] as String;
    final key = '$medId:protocol:$step';
    final now = DateTime.now();
    final lastTap = _doseChipLastTapAt[key];
    if (lastTap != null &&
        now.difference(lastTap) < const Duration(seconds: 1)) {
      return;
    }
    _doseChipLastTapAt[key] = now;

    await VeriYonetici.upsertIlacDozKaydi(
      medicationId: medId,
      vaccineId: med['scheduleType'] == _filterVaccineProtocol
          ? med['vaccineId'] as String?
          : null,
      givenAt: DateTime.now(),
      protocolStep: step,
    );
    if (mounted) setState(() {});
  }

  bool _givenToday(Map<String, dynamic> med) {
    final last = _lastGivenAt(med);
    if (last == null) return false;
    return dateOnly(last) == dateOnly(DateTime.now());
  }

  String _formatLastGiven(DateTime? lastGivenAt, AppLocalizations l10n) {
    if (lastGivenAt == null) return l10n.notGivenYet;
    final now = DateTime.now();
    final today = dateOnly(now);
    final target = dateOnly(lastGivenAt);
    final timeText = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(lastGivenAt));

    if (target == today) {
      return '${l10n.today} $timeText';
    }
    if (target == today.subtract(const Duration(days: 1))) {
      return '${l10n.yesterday} $timeText';
    }
    return '${formatLocalizedDate(context, lastGivenAt)} $timeText';
  }

  Future<void> _showMedicationHistory(Map<String, dynamic> med) async {
    final l10n = AppLocalizations.of(context)!;
    final logs = _uniqueDoseLogs(med).take(30).toList();
    final dailyTarget = _targetDailyDoseCount(med);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = <DateTime, List<Map<String, dynamic>>>{};
    for (final log in logs) {
      final day = dateOnly(log['givenAt'] as DateTime);
      grouped.putIfAbsent(day, () => <Map<String, dynamic>>[]).add(log);
    }
    final orderedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(l10n.viewHistory, style: AppTypography.h3(context)),
              const SizedBox(height: 8),
              if (logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(l10n.noMedicationHistory),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: orderedDays.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final day = orderedDays[index];
                      final dayLogs = grouped[day]!;
                      final dayLabel = day == dateOnly(DateTime.now())
                          ? l10n.today
                          : (day ==
                                    dateOnly(
                                      DateTime.now(),
                                    ).subtract(const Duration(days: 1))
                                ? l10n.yesterday
                                : formatLocalizedDate(context, day));
                      if (_isProtocolMedication(med)) {
                        final before = dayLogs
                            .where((l) => _protocolStepForLog(l) == 'before')
                            .firstOrNull;
                        final after = dayLogs
                            .where((l) => _protocolStepForLog(l) == 'after')
                            .firstOrNull;
                        final beforeTime = before == null
                            ? ''
                            : MaterialLocalizations.of(context).formatTimeOfDay(
                                TimeOfDay.fromDateTime(
                                  before['givenAt'] as DateTime,
                                ),
                              );
                        final afterTime = after == null
                            ? ''
                            : MaterialLocalizations.of(context).formatTimeOfDay(
                                TimeOfDay.fromDateTime(
                                  after['givenAt'] as DateTime,
                                ),
                              );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '$dayLabel önce ${before == null ? '☐' : '✓ $beforeTime'}, sonra ${after == null ? '☐' : '✓ $afterTime'}',
                            style: AppTypography.caption(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$dayLabel ${dayLogs.length}/$dailyTarget',
                              style: AppTypography.caption(
                                context,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                for (final log in dayLogs)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.bgDark.withOpacity(0.25)
                                          : const Color(0xFFF7EEE9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      MaterialLocalizations.of(
                                        context,
                                      ).formatTimeOfDay(
                                        TimeOfDay.fromDateTime(
                                          log['givenAt'] as DateTime,
                                        ),
                                      ),
                                      style: AppTypography.caption(context),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _dailyReminderId(String medicationId, int index) {
    final seed = 'daily_${medicationId}_$index'.hashCode.abs();
    return ReminderService.medicationReminderBaseId + (seed % 60000);
  }

  int _protocolReminderId(
    String medicationId,
    String vaccineId,
    String kind,
    int minutes,
    int index,
  ) {
    final seed =
        'protocol_${medicationId}_${vaccineId}_${kind}_${minutes}_$index'
            .hashCode
            .abs();
    return ReminderService.medicationReminderBaseId + (seed % 60000);
  }

  Future<void> _cancelRemindersForMedication(Map<String, dynamic> med) async {
    await _reminderService.initialize();
    final dailyTimes = _dailyTimes(med);
    for (int i = 0; i < dailyTimes.length; i++) {
      await _reminderService.cancelMedicationReminder(
        _dailyReminderId(med['id'] as String, i),
      );
    }

    final offsets = (med['protocolOffsets'] as List?) ?? const [];
    final vaccineId = med['vaccineId'] as String?;
    if (vaccineId == null) return;

    for (int i = 0; i < offsets.length; i++) {
      final item = Map<String, dynamic>.from(offsets[i] as Map);
      await _reminderService.cancelMedicationReminder(
        _protocolReminderId(
          med['id'] as String,
          vaccineId,
          (item['kind'] as String?) ?? 'after',
          (item['minutes'] as num?)?.toInt() ?? 0,
          i,
        ),
      );
    }
  }

  Future<void> _syncMedicationReminders(Map<String, dynamic> med) async {
    await _cancelRemindersForMedication(med);
    if (med['isActive'] != true) return;
    await _reminderService.requestPermissions();

    final l10n = AppLocalizations.of(context)!;
    final title = l10n.medicationReminderTitle(med['name'] ?? '');
    final body = med['dosage']?.toString().trim().isNotEmpty == true
        ? l10n.medicationReminderBodyWithDose(med['dosage'])
        : l10n.medicationReminderBody;
    final scheduleType = (med['scheduleType'] as String?) ?? _filterPrn;

    if (scheduleType == _filterDaily) {
      final times = _dailyTimes(med);
      for (int i = 0; i < times.length; i++) {
        final parts = times[i].split(':');
        await _reminderService.scheduleMedicationReminderDaily(
          id: _dailyReminderId(med['id'] as String, i),
          title: title,
          body: body,
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
      return;
    }

    if (scheduleType != _filterVaccineProtocol) return;
    final vaccineId = med['vaccineId'] as String?;
    if (vaccineId == null) return;
    final vaccine = VeriYonetici.getAsiKayitlari()
        .where((v) => v['id'] == vaccineId)
        .firstOrNull;
    final vaccineTime = vaccine?['tarih'] as DateTime?;
    if (vaccineTime == null) return;

    final offsets = (med['protocolOffsets'] as List?) ?? const [];
    for (int i = 0; i < offsets.length; i++) {
      final offset = Map<String, dynamic>.from(offsets[i] as Map);
      final kind = (offset['kind'] as String?) == 'before' ? 'before' : 'after';
      final minutes = (offset['minutes'] as num?)?.toInt() ?? 0;
      final scheduledAt = kind == 'before'
          ? vaccineTime.subtract(Duration(minutes: minutes))
          : vaccineTime.add(Duration(minutes: minutes));
      await _reminderService.scheduleMedicationReminderAt(
        id: _protocolReminderId(
          med['id'] as String,
          vaccineId,
          kind,
          minutes,
          i,
        ),
        title: title,
        body: body,
        scheduledAt: scheduledAt,
      );
    }
  }

  Future<void> _syncAllMedicationReminders() async {
    for (final med in VeriYonetici.getIlacKayitlari()) {
      await _syncMedicationReminders(med);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final meds = _filteredMedications();

    if (_medications.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noMedications,
                    style: AppTypography.h3(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: _buildAddButton(l10n),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            _buildFilterChips(l10n, isDark),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                itemCount: meds.length,
                itemBuilder: (context, index) {
                  final med = meds[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMedicationCard(med, isDark, l10n),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 32,
          left: 24,
          right: 24,
          child: _buildAddButton(l10n),
        ),
      ],
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n, bool isDark) {
    final filters = [
      (_filterAll, l10n.allLabel),
      (_filterDaily, l10n.routineFilter),
      (_filterPrn, l10n.asNeededFilter),
      (_filterVaccineProtocol, l10n.vaccineProtocolsFilter),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = filters[index].$1;
          final label = filters[index].$2;
          final selected = _activeFilter == value;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _activeFilter = value),
            selectedColor: AppColors.primary,
            backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF866F65)),
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(
    Map<String, dynamic> med,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isActive = med['isActive'] == true;
    final isMedication = med['type'] == 'medication';
    final typeBadge = isMedication ? l10n.medication : l10n.supplement;
    final subtitle = _scheduleSubtitle(med, l10n);
    final lastGivenAt = _lastGivenAt(med);
    final givenToday = _givenToday(med);
    final isMultiDoseRoutine = _isMultiDoseRoutine(med);
    final isProtocolMedication = _isProtocolMedication(med);
    final todayByIndex = _todayDoseLogsByIndex(med);
    final todayProtocolLogs = _todayProtocolLogs(med);
    final last7Summary = _last7DaysSummary(med, l10n);
    final dailyTimes = _dailyTimes(med);

    return GestureDetector(
      onTap: () => _editMedication(med),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withOpacity(isActive ? 0.9 : 0.5)
              : Colors.white.withOpacity(isActive ? 0.9 : 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB4A2).withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isMedication ? Icons.medication_outlined : Icons.eco_outlined,
                  color: isActive ? const Color(0xFFFFB4A2) : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              med['name'] ?? '',
                              style: AppTypography.h3(
                                context,
                              ).copyWith(fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isMedication
                                  ? AppColors.primary.withOpacity(0.15)
                                  : const Color(0xFFE5E0F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              typeBadge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isMedication
                                    ? AppColors.primary
                                    : const Color(0xFF6B5B95),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.caption(context).copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
                        ),
                      ),
                      if (!isMultiDoseRoutine && !isProtocolMedication)
                        Text(
                          l10n.doseCountLabel(_doseCount(med)),
                          style: AppTypography.caption(context).copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : const Color(0xFF866F65),
                          ),
                        ),
                      if (isMultiDoseRoutine)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (int i = 0; i < dailyTimes.length; i++)
                                Builder(
                                  builder: (context) {
                                    final log = todayByIndex[i];
                                    final active = log != null;
                                    final timeText = active
                                        ? MaterialLocalizations.of(
                                            context,
                                          ).formatTimeOfDay(
                                            TimeOfDay.fromDateTime(
                                              log['givenAt'] as DateTime,
                                            ),
                                          )
                                        : null;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: isActive
                                          ? () => _toggleDoseChip(med, i)
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? AppColors.primary.withOpacity(
                                                  0.2,
                                                )
                                              : (isDark
                                                    ? AppColors.bgDark
                                                          .withOpacity(0.25)
                                                    : const Color(0xFFF7EEE9)),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: active
                                                ? AppColors.primary
                                                : const Color(0xFFFFD8CC),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (active)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            Text(
                                              '${i + 1}. Doz',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: active
                                                    ? AppColors.primary
                                                    : (isDark
                                                          ? AppColors
                                                                .textPrimaryDark
                                                          : const Color(
                                                              0xFF6D4C41,
                                                            )),
                                              ),
                                            ),
                                            if (active && timeText != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                child: Text(
                                                  timeText,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      if (isProtocolMedication)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              for (final step in const ['before', 'after'])
                                Builder(
                                  builder: (context) {
                                    final log = todayProtocolLogs[step];
                                    final active = log != null;
                                    final timeText = active
                                        ? MaterialLocalizations.of(
                                            context,
                                          ).formatTimeOfDay(
                                            TimeOfDay.fromDateTime(
                                              log['givenAt'] as DateTime,
                                            ),
                                          )
                                        : null;
                                    final label = step == 'before'
                                        ? 'Önce'
                                        : 'Sonra';
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          onTap: isActive
                                              ? () => _toggleProtocolStep(
                                                  med,
                                                  step,
                                                )
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: active
                                                  ? AppColors.primary
                                                        .withOpacity(0.2)
                                                  : (isDark
                                                        ? AppColors.bgDark
                                                              .withOpacity(0.25)
                                                        : const Color(
                                                            0xFFF7EEE9,
                                                          )),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: active
                                                    ? AppColors.primary
                                                    : const Color(0xFFFFD8CC),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (active)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 6,
                                                        ),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 14,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                Text(
                                                  label,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: active
                                                        ? AppColors.primary
                                                        : (isDark
                                                              ? AppColors
                                                                    .textPrimaryDark
                                                              : const Color(
                                                                  0xFF6D4C41,
                                                                )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (active && timeText != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                              left: 4,
                                            ),
                                            child: Text(
                                              timeText,
                                              style:
                                                  AppTypography.caption(
                                                    context,
                                                  ).copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      if (last7Summary != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            last7Summary,
                            style: AppTypography.caption(context).copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : const Color(0xFF866F65),
                            ),
                          ),
                        ),
                      Text(
                        l10n.lastGivenLabel(
                          _formatLastGiven(lastGivenAt, l10n),
                        ),
                        style: AppTypography.caption(context).copyWith(
                          color: givenToday
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF866F65)),
                          fontWeight: givenToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editMedication(med);
                        break;
                      case 'toggle':
                        _toggleActive(med);
                        break;
                      case 'delete':
                        _deleteMedication(med);
                        break;
                      case 'history':
                        _showMedicationHistory(med);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(
                      value: 'history',
                      child: Text(l10n.viewHistory),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(isActive ? l10n.deactivate : l10n.activate),
                    ),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!isMultiDoseRoutine && !isProtocolMedication)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed:
                      isActive &&
                          !_recentlyTappedMedicationIds.contains(med['id'])
                      ? () => _logGivenNow(med)
                      : null,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(l10n.logGivenNow),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _addMedication,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.addMedication,
              style: AppTypography.button().copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? medication;

  const _MedicationFormScreen({this.medication});

  @override
  State<_MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<_MedicationFormScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'medication';
  String _scheduleType = 'prn';
  List<String> _dailyTimes = ['09:00'];
  String? _vaccineId;
  int _beforeHours = 2;
  int _afterHours = 4;
  bool _isActive = true;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final med = widget.medication!;
      _nameController.text = med['name'] ?? '';
      _dosageController.text = med['dosage'] ?? '';
      _notesController.text = med['notes'] ?? '';
      _type = med['type'] ?? 'medication';
      _isActive = med['isActive'] ?? true;
      _scheduleType = med['scheduleType'] ?? 'prn';
      _vaccineId = med['vaccineId'] as String?;
      final daily = med['dailyTimes'];
      if (daily is List) {
        final parsed = daily
            .map((e) => e?.toString() ?? '')
            .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
            .toList();
        if (parsed.isNotEmpty) _dailyTimes = parsed;
      }
      final offsets = (med['protocolOffsets'] as List?) ?? const [];
      for (final item in offsets) {
        final map = Map<String, dynamic>.from(item as Map);
        final kind = (map['kind'] as String?) ?? 'after';
        final minutes = (map['minutes'] as num?)?.toInt() ?? 0;
        if (kind == 'before') _beforeHours = (minutes / 60).round();
        if (kind == 'after') _afterHours = (minutes / 60).round();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  TimeOfDay _timeFromString(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDailyTime({int? index}) async {
    final initial = index == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : _timeFromString(_dailyTimes[index]);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (index == null) {
        _dailyTimes.add(_timeToString(picked));
      } else {
        _dailyTimes[index] = _timeToString(picked);
      }
      _dailyTimes = _dailyTimes.toSet().toList()..sort();
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.medicationNameRequired)));
      return;
    }

    if (_scheduleType == 'daily' && _dailyTimes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dailyTimeRequired)));
      return;
    }

    if (_scheduleType == 'vaccine_protocol' && _vaccineId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectVaccine)));
      return;
    }

    final medications = VeriYonetici.getIlacKayitlari();
    final payload = {
      'name': name,
      'type': _type,
      'dosage': _dosageController.text.trim().isEmpty
          ? null
          : _dosageController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'isActive': _isActive,
      'scheduleType': _scheduleType,
      'dailyTimes': _scheduleType == 'daily' ? _dailyTimes : null,
      'vaccineId': _scheduleType == 'vaccine_protocol' ? _vaccineId : null,
      'protocolOffsets': _scheduleType == 'vaccine_protocol'
          ? [
              {'kind': 'before', 'minutes': _beforeHours * 60},
              {'kind': 'after', 'minutes': _afterHours * 60},
            ]
          : null,
      'repeatEveryHours': null,
      'maxDoses': null,
      'scheduleText': _scheduleType == 'daily'
          ? '${l10n.everyDay} • ${_dailyTimes.join(', ')}'
          : (_scheduleType == 'prn'
                ? l10n.asNeeded
                : l10n.vaccineProtocolLabel),
    };

    if (_isEditing) {
      final index = medications.indexWhere(
        (m) => m['id'] == widget.medication!['id'],
      );
      if (index != -1) medications[index] = {...medications[index], ...payload};
    } else {
      medications.add({
        'id': 'ilac_${DateTime.now().millisecondsSinceEpoch}',
        'babyId': VeriYonetici.getActiveBabyId(),
        ...payload,
        'createdAt': DateTime.now(),
      });
    }

    await VeriYonetici.saveIlacKayitlari(medications);
    HapticFeedback.lightImpact();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final vaccines = VeriYonetici.getAsiKayitlari();

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editMedication : l10n.addMedication,
          style: AppTypography.h2(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.medicationName, style: AppTypography.label(context)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration(isDark),
            ),
            const SizedBox(height: 16),
            Text(l10n.type, style: AppTypography.label(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _typeChip(l10n.medication, 'medication')),
                const SizedBox(width: 8),
                Expanded(child: _typeChip(l10n.supplement, 'supplement')),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.scheduleType, style: AppTypography.label(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _scheduleChip(l10n.dailySchedule, 'daily'),
                _scheduleChip(l10n.prnSchedule, 'prn'),
                _scheduleChip(l10n.vaccineProtocolLabel, 'vaccine_protocol'),
              ],
            ),
            if (_scheduleType == 'daily') ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < _dailyTimes.length; i++)
                    InputChip(
                      label: Text(_dailyTimes[i]),
                      onPressed: () => _pickDailyTime(index: i),
                      onDeleted: _dailyTimes.length == 1
                          ? null
                          : () => setState(() => _dailyTimes.removeAt(i)),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text(l10n.selectTime),
                    onPressed: () => _pickDailyTime(),
                  ),
                ],
              ),
            ],
            if (_scheduleType == 'vaccine_protocol') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _vaccineId,
                items: vaccines
                    .map(
                      (v) => DropdownMenuItem<String>(
                        value: v['id'] as String,
                        child: Text(
                          '${v['ad']} (${(v['tarih'] as DateTime?) == null ? l10n.selectDate : formatLocalizedDate(context, v['tarih'] as DateTime)})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _vaccineId = value),
                decoration: _inputDecoration(isDark, hint: l10n.selectVaccine),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _beforeHours,
                      items: List.generate(13, (i) => i)
                          .map(
                            (h) => DropdownMenuItem<int>(
                              value: h,
                              child: Text(l10n.beforeHours(h)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _beforeHours = value ?? 0),
                      decoration: _inputDecoration(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _afterHours,
                      items: List.generate(25, (i) => i)
                          .map(
                            (h) => DropdownMenuItem<int>(
                              value: h,
                              child: Text(l10n.afterHours(h)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _afterHours = value ?? 0),
                      decoration: _inputDecoration(isDark),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.dosage, style: AppTypography.label(context)),
            const SizedBox(height: 8),
            TextField(
              controller: _dosageController,
              decoration: _inputDecoration(isDark),
            ),
            const SizedBox(height: 16),
            Text(l10n.notes, style: AppTypography.label(context)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: _inputDecoration(isDark),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
              title: Text(_isActive ? l10n.active : l10n.inactive),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value) {
    final selected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Center(child: Text(label)),
      ),
    );
  }

  Widget _scheduleChip(String label, String value) {
    final selected = _scheduleType == value;
    return InkWell(
      onTap: () => setState(() => _scheduleType = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.bgDarkCard : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
