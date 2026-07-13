import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/nilico_badge.dart';
import '../widgets/nilico_modal.dart';
import '../widgets/nilico_motion.dart';
import '../widgets/nilico_primary_button.dart';

class IlaclarScreen extends StatefulWidget {
  const IlaclarScreen({super.key, this.embedded = false});

  final bool embedded;

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
      builder: (context) => NilicoDialog(
        title: Text(l10n.attention),
        content: Text(l10n.deleteConfirm),
        actions: [
          NilicoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            label: l10n.no,
          ),
          NilicoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            label: l10n.yes,
            destructive: true,
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

    final dailyTimes = _dailyTimes(medication);
    final scheduled = dailyTimes.isNotEmpty ? dailyTimes.first : null;
    final result = await VeriYonetici.markIlacDozKaydiIfAbsent(
      medicationId: medication['id'] as String,
      vaccineId: medication['scheduleType'] == _filterVaccineProtocol
          ? medication['vaccineId'] as String?
          : null,
      doseIndex: 0,
      scheduledTime: scheduled,
    );
    if (kDebugMode) {
      debugPrint(
        '[IlaclarScreen] onTap logId=${result.logId} exists=${result.alreadyMarked} action=${result.alreadyMarked ? 'skip' : 'create'}',
      );
    }
    if (result.alreadyMarked) {
      _showAlreadyMarkedHint();
      return;
    }
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() {});
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

  int _nextRoutineDoseIndex(Map<String, dynamic> med) {
    final dailyTimes = _dailyTimes(med);
    final todayByIndex = _todayDoseLogsByIndex(med);
    for (int i = 0; i < dailyTimes.length; i++) {
      if (!todayByIndex.containsKey(i)) return i;
    }
    return dailyTimes.isEmpty ? 0 : dailyTimes.length - 1;
  }

  Future<void> _logNextRoutineDose(Map<String, dynamic> med) async {
    if (_isProtocolMedication(med)) {
      final todayProtocolLogs = _todayProtocolLogs(med);
      final nextStep = !todayProtocolLogs.containsKey('before')
          ? 'before'
          : (!todayProtocolLogs.containsKey('after') ? 'after' : 'before');
      await _toggleProtocolStep(med, nextStep);
      return;
    }

    await _toggleDoseChip(med, _nextRoutineDoseIndex(med));
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
    final scheduledTime = doseIndex >= 0 && doseIndex < dailyTimes.length
        ? dailyTimes[doseIndex]
        : null;
    final result = await VeriYonetici.markIlacDozKaydiIfAbsent(
      medicationId: medId,
      vaccineId: med['scheduleType'] == _filterVaccineProtocol
          ? med['vaccineId'] as String?
          : null,
      givenAt: DateTime.now(),
      doseIndex: doseIndex,
      scheduledTime: scheduledTime,
    );
    if (kDebugMode) {
      debugPrint(
        '[IlaclarScreen] onTap logId=${result.logId} exists=${result.alreadyMarked} action=${result.alreadyMarked ? 'skip' : 'create'}',
      );
    }
    if (result.alreadyMarked) {
      _showAlreadyMarkedHint();
      return;
    }
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

    final result = await VeriYonetici.markIlacDozKaydiIfAbsent(
      medicationId: medId,
      vaccineId: med['scheduleType'] == _filterVaccineProtocol
          ? med['vaccineId'] as String?
          : null,
      givenAt: DateTime.now(),
      protocolStep: step,
    );
    if (kDebugMode) {
      debugPrint(
        '[IlaclarScreen] onTap logId=${result.logId} exists=${result.alreadyMarked} action=${result.alreadyMarked ? 'skip' : 'create'}',
      );
    }
    if (result.alreadyMarked) {
      _showAlreadyMarkedHint();
      return;
    }
    if (mounted) setState(() {});
  }

  void _showAlreadyMarkedHint() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.medicationAlreadyMarkedHint),
        duration: const Duration(seconds: 2),
      ),
    );
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
      return '${l10n.today} • $timeText';
    }
    if (target == today.subtract(const Duration(days: 1))) {
      return '${l10n.yesterday} • $timeText';
    }
    return '${formatLocalizedDate(context, lastGivenAt)} • $timeText';
  }

  Future<void> _cancelRemindersForMedication(Map<String, dynamic> med) async {
    await _reminderService.initialize();
    await _reminderService.cancelMedicationReminders(
      med['id'] as String,
      dailyTimes: _dailyTimes(med),
      protocolOffsets: ((med['protocolOffsets'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      vaccineId: med['vaccineId'] as String?,
    );
  }

  Future<void> _syncMedicationReminders(
    Map<String, dynamic> med, {
    bool interactive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    await _cancelRemindersForMedication(med);
    if (med['isActive'] != true) return;
    if (VeriYonetici.isMedicationReminderEnabled() != true) {
      if (interactive && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.notificationsDisabled)));
      }
      return;
    }
    if (med['remindersEnabled'] != true) return;

    if (interactive) {
      final granted = await _reminderService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.permissionDenied)));
        }
        return;
      }
    }

    final scheduleType = (med['scheduleType'] as String?) ?? _filterPrn;

    DateTime? vaccineDate;
    if (scheduleType == _filterVaccineProtocol) {
      final vaccineId = med['vaccineId'] as String?;
      if (vaccineId != null) {
        final vaccine = VeriYonetici.getAsiKayitlari()
            .where((v) => v['id'] == vaccineId)
            .firstOrNull;
        vaccineDate = vaccine?['tarih'] as DateTime?;
      }
    }

    await _reminderService.scheduleMedicationReminders(
      med,
      vaccineDate: vaccineDate,
    );
    if (interactive && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reminderScheduled)));
    }
  }

  Future<void> _syncAllMedicationReminders() async {
    for (final med in VeriYonetici.getIlacKayitlari()) {
      await _syncMedicationReminders(med);
    }
  }

  Future<void> _showMedicationReminderSheet(Map<String, dynamic> med) async {
    final l10n = AppLocalizations.of(context)!;
    TimeOfDay reminderTime = TimeOfDay.now();
    var repeatDaily = true;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.bgDarkCard
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.medicationSetReminder,
                    style: AppTypography.sheetTitle(context),
                  ),
                  subtitle: Text(
                    med['name']?.toString() ?? '',
                    style: AppTypography.bodySmall(context),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_rounded),
                  title: Text(
                    l10n.reminderTime,
                    style: AppTypography.body(context),
                  ),
                  trailing: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatTimeOfDay(reminderTime),
                    style: AppTypography.label(context),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: reminderTime,
                    );
                    if (picked != null) {
                      setSheetState(() => reminderTime = picked);
                    }
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.repeatDaily,
                    style: AppTypography.body(context),
                  ),
                  value: repeatDaily,
                  onChanged: (value) =>
                      setSheetState(() => repeatDaily = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      l10n.medicationSetReminder,
                      style: AppTypography.button(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved != true) return;

    await _reminderService.initialize();
    final granted = await _reminderService.requestPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.permissionDenied)));
      }
      return;
    }

    final now = DateTime.now();
    var scheduledAt = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    if (!scheduledAt.isAfter(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }
    if (repeatDaily) {
      await _reminderService.scheduleMedicationReminderDaily(
        id: ReminderService.medicationReminderId(
          medicationId: med['id'] as String,
          slotKey: 'local_daily',
        ),
        medicationName: med['name']?.toString() ?? '',
        dosage: med['dosage']?.toString(),
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.reminderScheduled)));
      }
      return;
    }

    await _reminderService.scheduleMedicationReminderAt(
      id: ReminderService.medicationReminderId(
        medicationId: med['id'] as String,
        slotKey: 'once_${scheduledAt.millisecondsSinceEpoch}',
      ),
      medicationName: med['name']?.toString() ?? '',
      dosage: med['dosage']?.toString(),
      scheduledAt: scheduledAt,
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reminderScheduled)));
    }
  }

  int _givenTodayCount(Map<String, dynamic> med) {
    if (_isProtocolMedication(med)) {
      return _todayProtocolLogs(med).length;
    }
    return _todayDoseLogsByIndex(med).length;
  }

  int _plannedDoseCount(Map<String, dynamic> med) {
    if (_isProtocolMedication(med)) {
      final offsets = (med['protocolOffsets'] as List?) ?? const [];
      return offsets.isEmpty ? 2 : offsets.length;
    }
    final count = _dailyTimes(med).length;
    return count == 0 ? 1 : count;
  }

  String _primaryActionLabel(Map<String, dynamic> med, AppLocalizations l10n) {
    final scheduleType = (med['scheduleType'] as String?) ?? _filterPrn;
    return scheduleType == _filterPrn
        ? l10n.medicationGiveNow
        : l10n.logGivenNow;
  }

  String _progressLabel(Map<String, dynamic> med, AppLocalizations l10n) {
    final scheduleType = (med['scheduleType'] as String?) ?? _filterPrn;
    final done = _givenTodayCount(med);
    if (scheduleType == _filterPrn) {
      return done == 0 ? l10n.noMedicationHistory : l10n.givenTodayCount(done);
    }
    final total = _plannedDoseCount(med);
    if (done >= total) {
      return l10n.allDoneToday;
    }
    return l10n.todayProgressLabel(done, total);
  }

  DateTime? _nextReminderAt(Map<String, dynamic> med) {
    if (med['isActive'] != true) return null;
    if (VeriYonetici.isMedicationReminderEnabled() != true) return null;

    final scheduleType = (med['scheduleType'] as String?) ?? _filterPrn;
    if (scheduleType == _filterPrn) return null;
    if (med['remindersEnabled'] != true) return null;

    final now = DateTime.now();
    if (scheduleType == _filterDaily) {
      final times = _dailyTimes(med);
      if (times.isEmpty) return null;
      DateTime? best;
      for (final time in times) {
        final parts = time.split(':');
        if (parts.length != 2) continue;
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;
        var candidate = DateTime(now.year, now.month, now.day, hour, minute);
        if (!candidate.isAfter(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        if (best == null || candidate.isBefore(best)) {
          best = candidate;
        }
      }
      return best;
    }

    if (scheduleType == _filterVaccineProtocol) {
      final vaccineId = med['vaccineId'] as String?;
      final vaccine = VeriYonetici.getAsiKayitlari()
          .where((v) => v['id'] == vaccineId)
          .firstOrNull;
      final vaccineDate = vaccine?['tarih'] as DateTime?;
      if (vaccineDate == null) return null;

      final offsets = ((med['protocolOffsets'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      DateTime? best;
      for (final offset in offsets) {
        final kind = (offset['kind'] as String?) == 'before'
            ? 'before'
            : 'after';
        final minutes = (offset['minutes'] as num?)?.toInt() ?? 0;
        final candidate = kind == 'before'
            ? vaccineDate.subtract(Duration(minutes: minutes))
            : vaccineDate.add(Duration(minutes: minutes));
        if (!candidate.isAfter(now)) continue;
        if (best == null || candidate.isBefore(best)) {
          best = candidate;
        }
      }
      return best;
    }

    return null;
  }

  String _formatReminderDateTime(DateTime when, AppLocalizations l10n) {
    final today = dateOnly(DateTime.now());
    final target = dateOnly(when);
    final timeText = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(when));
    if (target == today) {
      return '${l10n.today} $timeText';
    }
    return '${formatLocalizedDate(context, when)} $timeText';
  }

  Future<void> _showMedicationActionSheet(Map<String, dynamic> med) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = med['isActive'] == true;
    final isMedication = med['type'] == 'medication';
    final lastGivenAt = _lastGivenAt(med);
    final nextReminderAt = _nextReminderAt(med);
    final primaryLabel = _primaryActionLabel(med, l10n);
    final primaryAction =
        ((med['scheduleType'] as String?) ?? _filterPrn) == _filterPrn
        ? () => _logGivenNow(med)
        : () => _logNextRoutineDose(med);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final surface = isDark ? AppColors.bgDarkCard : const Color(0xFFFFFBF8);
        final secondaryText = isDark
            ? AppColors.textSecondaryDark
            : const Color(0xFF8B766B);
        final accentSoft = isMedication
            ? AppColors.primary.withValues(alpha: 0.12)
            : const Color(0xFFEDE7F7);

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryText.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med['name']?.toString() ?? '',
                                style: AppTypography.sheetTitle(
                                  context,
                                ).copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _MedicationTypeBadge(
                                    typeBadge: isMedication
                                        ? l10n.medication
                                        : l10n.supplement,
                                    isMedication: isMedication,
                                  ),
                                  _MedicationStatusBadge(
                                    label: isActive
                                        ? l10n.active
                                        : l10n.inactive,
                                    isActive: isActive,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isMedication
                                ? Icons.medication_outlined
                                : Icons.health_and_safety_outlined,
                            color: isMedication
                                ? AppColors.primary
                                : const Color(0xFF6B5B95),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _MedicationInfoRow(
                      icon: Icons.schedule_rounded,
                      text: _scheduleSubtitle(med, l10n),
                    ),
                    const SizedBox(height: 10),
                    _MedicationInfoRow(
                      icon: Icons.check_circle_outline,
                      text: l10n.lastGivenLabel(
                        _formatLastGiven(lastGivenAt, l10n),
                      ),
                    ),
                    if (nextReminderAt != null) ...[
                      const SizedBox(height: 10),
                      _MedicationInfoRow(
                        icon: Icons.notifications_none_rounded,
                        text:
                            '${l10n.reminderTime}: ${_formatReminderDateTime(nextReminderAt, l10n)}',
                      ),
                    ],
                    const SizedBox(height: 10),
                    _MedicationInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: _progressLabel(med, l10n),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            isActive &&
                                !_recentlyTappedMedicationIds.contains(
                                  med['id'],
                                )
                            ? () async {
                                Navigator.pop(sheetContext);
                                await primaryAction();
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.28,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          primaryLabel,
                          style: AppTypography.button(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _MedicationSheetActionRow(
                      icon: Icons.notifications_none_rounded,
                      label: l10n.medicationSetReminder,
                      onTap: isActive
                          ? () async {
                              Navigator.pop(sheetContext);
                              await _showMedicationReminderSheet(med);
                            }
                          : null,
                    ),
                    _MedicationSheetActionRow(
                      icon: Icons.edit_outlined,
                      label: l10n.edit,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _editMedication(med);
                      },
                    ),
                    _MedicationSheetActionRow(
                      icon: isActive
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      label: isActive ? l10n.deactivate : l10n.activate,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _toggleActive(med);
                      },
                    ),
                    _MedicationSheetActionRow(
                      icon: Icons.delete_outline,
                      label: l10n.delete,
                      isDestructive: true,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _deleteMedication(med);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
            child: NilicoEntrance(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  32,
                  widget.embedded ? 16 : 32,
                  32,
                  32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMedications,
                      style: AppTypography.sheetTitle(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
            SizedBox(height: widget.embedded ? 8 : 16),
            _buildMedicationHeader(l10n, isDark),
            Expanded(
              child: meds.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          l10n.noMedications,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(context).copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : const Color(0xFF866F65),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                      itemCount: meds.length,
                      itemBuilder: (context, index) {
                        final med = meds[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NilicoEntrance(
                            key: ValueKey(med['id'] ?? index),
                            child: _buildMedicationListCard(med, isDark, l10n),
                          ),
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

  Widget _buildMedicationHeader(AppLocalizations l10n, bool isDark) {
    final filters = [
      (_filterAll, l10n.allLabel),
      (_filterDaily, l10n.routineFilter),
      (_filterPrn, l10n.asNeededFilter),
      (_filterVaccineProtocol, l10n.vaccineProtocolsFilter),
    ];

    final selectedLabel = filters
        .firstWhere(
          (entry) => entry.$1 == _activeFilter,
          orElse: () => filters.first,
        )
        .$2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!widget.embedded)
            Expanded(
              child: Text(l10n.medications, style: AppTypography.h2(context)),
            )
          else
            const Spacer(),
          PopupMenuButton<String>(
            initialValue: _activeFilter,
            onSelected: (value) => setState(() => _activeFilter = value),
            itemBuilder: (context) => filters
                .map(
                  (entry) => PopupMenuItem<String>(
                    value: entry.$1,
                    child: Text(entry.$2),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.bgDarkCard.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    selectedLabel,
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationListCard(
    Map<String, dynamic> med,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isActive = med['isActive'] == true;
    final isMedication = med['type'] == 'medication';
    final typeBadge = isMedication ? l10n.medication : l10n.supplement;
    final lastGivenAt = _lastGivenAt(med);
    final scheduleText = _scheduleSubtitle(med, l10n);
    final progressText = _progressLabel(med, l10n);
    final nextReminderAt = _nextReminderAt(med);
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showMedicationActionSheet(med),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: isActive ? 0.92 : 0.58)
              : const Color(
                  0xFFFFFBF8,
                ).withValues(alpha: isActive ? 0.96 : 0.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFFC9B8).withValues(alpha: 0.34)
                : const Color(0xFFD8CEC9).withValues(alpha: 0.22),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFFFD8CC).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF73C7A6)
                        : secondaryText.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med['name'] ?? '',
                        style: AppTypography.compactTitle(
                          context,
                        ).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MedicationTypeBadge(
                            typeBadge: typeBadge,
                            isMedication: isMedication,
                          ),
                          _MedicationStatusBadge(
                            label: isActive ? l10n.active : l10n.inactive,
                            isActive: isActive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: secondaryText.withValues(alpha: 0.8),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              scheduleText,
              style: AppTypography.caption(
                context,
              ).copyWith(color: secondaryText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.lastGivenLabel(_formatLastGiven(lastGivenAt, l10n)),
              style: AppTypography.caption(
                context,
              ).copyWith(color: secondaryText),
            ),
            if (nextReminderAt != null) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.reminderTime}: ${_formatReminderDateTime(nextReminderAt, l10n)}',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: secondaryText),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      progressText,
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
    return NilicoPrimaryButton(
      label: l10n.addMedication,
      icon: Icons.add_circle,
      onPressed: _addMedication,
    );
  }
}

class RoutineMedicationCard extends StatelessWidget {
  const RoutineMedicationCard({
    super.key,
    required this.isDark,
    required this.name,
    required this.typeBadge,
    required this.scheduleSummary,
    required this.lastGivenLabel,
    required this.primaryButtonLabel,
    required this.secondaryButtonLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool isDark;
  final String name;
  final String typeBadge;
  final String scheduleSummary;
  final String lastGivenLabel;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final muted = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTypography.compactTitle(
                  context,
                ).copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            _MedicationTypeBadge(
              typeBadge: typeBadge,
              isMedication:
                  typeBadge == AppLocalizations.of(context)!.medication,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          scheduleSummary,
          style: AppTypography.caption(context).copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        Text(
          lastGivenLabel,
          style: AppTypography.caption(context).copyWith(color: muted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.3,
                  ),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(primaryButtonLabel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                onPressed: onSecondaryPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary.withValues(alpha: 0.82),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                  disabledForegroundColor: muted.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: AppTypography.dialogAction(context),
                ),
                icon: const Icon(Icons.notifications_none_rounded, size: 17),
                label: Text(secondaryButtonLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AsNeededMedicationCard extends StatelessWidget {
  const AsNeededMedicationCard({
    super.key,
    required this.isDark,
    required this.name,
    required this.typeBadge,
    required this.asNeededLabel,
    required this.lastGivenLabel,
    required this.primaryButtonLabel,
    required this.secondaryButtonLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool isDark;
  final String name;
  final String typeBadge;
  final String asNeededLabel;
  final String lastGivenLabel;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final muted = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTypography.compactTitle(
                  context,
                ).copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            _MedicationTypeBadge(
              typeBadge: typeBadge,
              isMedication:
                  typeBadge == AppLocalizations.of(context)!.medication,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          asNeededLabel,
          style: AppTypography.caption(
            context,
          ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          lastGivenLabel,
          style: AppTypography.caption(context).copyWith(color: muted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.3,
                  ),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(primaryButtonLabel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                onPressed: onSecondaryPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary.withValues(alpha: 0.82),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                  disabledForegroundColor: muted.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: AppTypography.dialogAction(context),
                ),
                icon: const Icon(Icons.notifications_none_rounded, size: 17),
                label: Text(secondaryButtonLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MedicationTypeBadge extends StatelessWidget {
  const _MedicationTypeBadge({
    required this.typeBadge,
    required this.isMedication,
  });

  final String typeBadge;
  final bool isMedication;

  @override
  Widget build(BuildContext context) {
    return NilicoBadge(
      label: typeBadge,
      variant: isMedication
          ? NilicoBadgeVariant.status
          : NilicoBadgeVariant.type,
    );
  }
}

class _MedicationStatusBadge extends StatelessWidget {
  const _MedicationStatusBadge({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return NilicoBadge(
      label: label,
      variant: isActive
          ? NilicoBadgeVariant.success
          : NilicoBadgeVariant.inactive,
    );
  }
}

class _MedicationInfoRow extends StatelessWidget {
  const _MedicationInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF8B766B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: secondaryText),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption(
              context,
            ).copyWith(color: secondaryText, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _MedicationSheetActionRow extends StatelessWidget {
  const _MedicationSheetActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? const Color(0xFFD85C5C)
        : (isDark ? Colors.white : const Color(0xFF2D1A18));
    final bg = isDestructive
        ? const Color(0xFFD85C5C).withValues(alpha: 0.10)
        : (isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF7F0EB));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body(
                      context,
                    ).copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.72),
                ),
              ],
            ),
          ),
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
  final ReminderService _reminderService = ReminderService();

  String _type = 'medication';
  String _scheduleType = 'prn';
  List<String> _dailyTimes = ['09:00'];
  String? _vaccineId;
  int _beforeHours = 2;
  int _afterHours = 4;
  bool _isActive = true;
  bool _isSaving = false;

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
    if (_isSaving) return;
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

    setState(() => _isSaving = true);
    try {
      final medications = VeriYonetici.getIlacKayitlari();
      final editingId = widget.medication?['id'] as String?;
      final existingIndex = editingId == null
          ? -1
          : medications.indexWhere((m) => m['id'] == editingId);
      final existing = existingIndex >= 0
          ? Map<String, dynamic>.from(medications[existingIndex])
          : null;
      final medicationId =
          existing?['id'] as String? ??
          'ilac_${DateTime.now().millisecondsSinceEpoch}';

      bool remindersEnabled = existing?['remindersEnabled'] == true;
      if (_scheduleType == 'prn') {
        remindersEnabled = false;
      } else if (!_isEditing || remindersEnabled != true) {
        final optIn = await _askMedicationReminder();
        if (optIn == null) return;
        remindersEnabled = optIn;
      }

      final payload = {
        'id': medicationId,
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
        'remindersEnabled': remindersEnabled,
        'scheduleText': _scheduleType == 'daily'
            ? '${l10n.everyDay} • ${_dailyTimes.join(', ')}'
            : (_scheduleType == 'prn'
                  ? l10n.asNeeded
                  : l10n.vaccineProtocolLabel),
      };

      if (_isEditing && existingIndex != -1) {
        medications[existingIndex] = {
          ...medications[existingIndex],
          ...payload,
        };
      } else {
        medications.add({
          'babyId': VeriYonetici.getActiveBabyId(),
          ...payload,
          'createdAt': DateTime.now(),
        });
      }

      await VeriYonetici.saveIlacKayitlari(medications);
      final saved = medications.firstWhere((m) => m['id'] == medicationId);

      try {
        await _syncSavedMedicationReminder(
          oldMedication: existing,
          savedMedication: Map<String, dynamic>.from(saved),
        );
      } catch (e) {
        debugPrint('Medication reminder sync failed: $e');
      }

      HapticFeedback.lightImpact();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool?> _askMedicationReminder() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => NilicoDialog(
        title: Text(l10n.medicationSetRemindersTitle),
        content: Text(l10n.medicationSetRemindersBody),
        actions: [
          NilicoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            label: l10n.no,
          ),
          NilicoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, true),
            label: l10n.yes,
          ),
        ],
      ),
    );
  }

  Future<void> _syncSavedMedicationReminder({
    Map<String, dynamic>? oldMedication,
    required Map<String, dynamic> savedMedication,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await _reminderService.initialize();

    if (oldMedication != null) {
      await _reminderService.cancelMedicationReminders(
        oldMedication['id'] as String,
        dailyTimes: _extractDailyTimes(oldMedication),
        protocolOffsets: _extractProtocolOffsets(oldMedication),
        vaccineId: oldMedication['vaccineId'] as String?,
      );
    }
    await _reminderService.cancelMedicationReminders(
      savedMedication['id'] as String,
      dailyTimes: _extractDailyTimes(savedMedication),
      protocolOffsets: _extractProtocolOffsets(savedMedication),
      vaccineId: savedMedication['vaccineId'] as String?,
    );

    final globalEnabled = VeriYonetici.isMedicationReminderEnabled();
    final medEnabled = savedMedication['remindersEnabled'] == true;
    final active = savedMedication['isActive'] == true;
    final scheduleType = (savedMedication['scheduleType'] as String?) ?? 'prn';
    if (!globalEnabled || !medEnabled || !active || scheduleType == 'prn') {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.notificationsDisabled)),
        );
      }
      return;
    }

    final granted = await _reminderService.requestPermission();
    if (!granted) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.permissionDenied)));
      }
      return;
    }

    DateTime? vaccineDate;
    if (scheduleType == 'vaccine_protocol') {
      final vaccineId = savedMedication['vaccineId'] as String?;
      if (vaccineId != null) {
        final vaccine = VeriYonetici.getAsiKayitlari()
            .where((v) => v['id'] == vaccineId)
            .firstOrNull;
        vaccineDate = vaccine?['tarih'] as DateTime?;
      }
    }

    await _reminderService.scheduleMedicationReminders(
      savedMedication,
      vaccineDate: vaccineDate,
    );
    if (mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reminderScheduled)));
    }
  }

  List<String> _extractDailyTimes(Map<String, dynamic> med) {
    final raw = med['dailyTimes'];
    if (raw is! List) return const <String>[];
    return raw
        .map((e) => e?.toString() ?? '')
        .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
        .toList();
  }

  List<Map<String, dynamic>> _extractProtocolOffsets(Map<String, dynamic> med) {
    final raw = med['protocolOffsets'];
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
              style: AppTypography.body(context),
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
                initialValue: _vaccineId,
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
                      initialValue: _beforeHours,
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
                      initialValue: _afterHours,
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
              style: AppTypography.body(context),
              decoration: _inputDecoration(isDark),
            ),
            const SizedBox(height: 16),
            Text(l10n.notes, style: AppTypography.label(context)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: AppTypography.body(context),
              maxLines: 3,
              decoration: _inputDecoration(isDark),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
              title: Text(
                _isActive ? l10n.active : l10n.inactive,
                style: AppTypography.body(context),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(l10n.save, style: AppTypography.button()),
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
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
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
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
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
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
