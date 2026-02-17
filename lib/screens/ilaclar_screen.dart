import 'package:flutter/material.dart';
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
    await VeriYonetici.addIlacDozKaydi(
      medicationId: medication['id'] as String,
      vaccineId: medication['scheduleType'] == _filterVaccineProtocol
          ? medication['vaccineId'] as String?
          : null,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.medicationDoseLogged)));
    setState(() {});
  }

  int _doseCount(Map<String, dynamic> med) {
    return VeriYonetici.getIlacDozKayitlari(
      medicationId: med['id'] as String,
    ).length;
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
                      Text(
                        l10n.doseCountLabel(_doseCount(med)),
                        style: AppTypography.caption(context).copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
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
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
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
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: isActive ? () => _logGivenNow(med) : null,
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
