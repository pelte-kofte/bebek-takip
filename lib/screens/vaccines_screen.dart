import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../models/asi_veri.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/decorative_background.dart';
import 'add_vaccine_screen.dart';

class VaccinesScreen extends StatefulWidget {
  final bool embedded;
  const VaccinesScreen({super.key, this.embedded = false});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  List<Map<String, dynamic>> _vaccines = [];
  int? _selectedMonth; // null means show all, 0-60 for specific month

  // There is no baby country/preset field in the current model, so the
  // Turkey vaccine calendar stays opt-in unless a future profile field exists.
  bool get _showTurkishPresetByDefault => false;

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  void _loadVaccines() {
    setState(() {
      _vaccines = VeriYonetici.getAsiKayitlari();
    });
  }

  /// Extracts month number from 'donem' field
  /// Returns null if cannot parse (e.g., "4-6 Yaş")
  int? _getMonthFromDonem(String donem) {
    return parseVaccineMonth(donem);
  }

  /// Returns vaccines filtered by selected month
  List<Map<String, dynamic>> _getFilteredVaccines() {
    if (_selectedMonth == null) return _vaccines;
    return _vaccines.where((v) {
      final month = _getMonthFromDonem(v['donem'] ?? '');
      return month == _selectedMonth;
    }).toList();
  }

  String _getChildAge() {
    return formatLocalizedAge(context, VeriYonetici.getBirthDate());
  }

  String _getBabyName() {
    return VeriYonetici.getBabyName();
  }

  void _deleteVaccine(int index) async {
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

    if (confirmed == true) {
      setState(() {
        _vaccines.removeAt(index);
      });
      await VeriYonetici.saveAsiKayitlari(_vaccines);
    }
  }

  void _editVaccine(Map<String, dynamic> vaccine, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVaccineScreen(vaccine: vaccine, index: index),
      ),
    );

    if (result == true) {
      _loadVaccines();
    }
  }

  List<Map<String, dynamic>> _protocolsForVaccine(String vaccineId) {
    return VeriYonetici.getIlacKayitlari()
        .where(
          (m) =>
              m['scheduleType'] == 'vaccine_protocol' &&
              m['vaccineId'] == vaccineId,
        )
        .toList();
  }

  Future<void> _scheduleProtocolReminders(Map<String, dynamic> med) async {
    final service = ReminderService();
    await service.initialize();
    await service.requestPermissions();

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
      final seed = 'protocol_${med['id']}_${vaccineId}_${kind}_${minutes}_$i'
          .hashCode
          .abs();
      final reminderId =
          ReminderService.medicationReminderBaseId + (seed % 60000);
      final scheduledAt = kind == 'before'
          ? vaccineTime.subtract(Duration(minutes: minutes))
          : vaccineTime.add(Duration(minutes: minutes));
      await service.scheduleMedicationReminderAt(
        id: reminderId,
        medicationName: med['name']?.toString() ?? '',
        dosage: med['dosage']?.toString(),
        scheduledAt: scheduledAt,
      );
    }
  }

  Future<void> _addVaccineProtocol(Map<String, dynamic> vaccine) async {
    final l10n = AppLocalizations.of(context)!;
    final medications = VeriYonetici.getIlacKayitlari();
    final candidates = medications
        .where((m) => m['type'] == 'medication' || m['type'] == 'supplement')
        .toList();
    String source = 'new';
    String? selectedMedicationId = candidates.isNotEmpty
        ? candidates.first['id'] as String
        : null;
    final nameController = TextEditingController();
    int beforeHours = 2;
    int afterHours = 4;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(l10n.addVaccineProtocol),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: source,
                      items: [
                        DropdownMenuItem(
                          value: 'new',
                          child: Text(l10n.createNew),
                        ),
                        DropdownMenuItem(
                          value: 'existing',
                          child: Text(l10n.chooseExistingMedication),
                        ),
                      ],
                      onChanged: (v) =>
                          setModalState(() => source = v ?? 'new'),
                    ),
                    const SizedBox(height: 12),
                    if (source == 'new')
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.medicationName,
                          hintText: l10n.feverReducerHint,
                        ),
                      ),
                    if (source == 'existing')
                      DropdownButtonFormField<String>(
                        initialValue: selectedMedicationId,
                        items: candidates
                            .map(
                              (m) => DropdownMenuItem<String>(
                                value: m['id'] as String,
                                child: Text(m['name'] as String? ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => selectedMedicationId = v),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: beforeHours,
                      items: List.generate(13, (i) => i)
                          .map(
                            (h) => DropdownMenuItem<int>(
                              value: h,
                              child: Text(l10n.beforeHours(h)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => beforeHours = v ?? 0),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: afterHours,
                      items: List.generate(25, (i) => i)
                          .map(
                            (h) => DropdownMenuItem<int>(
                              value: h,
                              child: Text(l10n.afterHours(h)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => afterHours = v ?? 0),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;

    Map<String, dynamic>? baseMedication;
    if (source == 'existing' && selectedMedicationId != null) {
      baseMedication = medications
          .where((m) => m['id'] == selectedMedicationId)
          .firstOrNull;
    }
    final fallbackName = baseMedication?['name']?.toString().trim() ?? '';
    final enteredName = nameController.text.trim();
    final medName = enteredName.isNotEmpty
        ? enteredName
        : (fallbackName.isNotEmpty ? fallbackName : l10n.feverReducerHint);

    final protocolMedication = {
      'id': 'ilac_${DateTime.now().millisecondsSinceEpoch}',
      'babyId': VeriYonetici.getActiveBabyId(),
      'name': medName,
      'type': baseMedication?['type'] ?? 'medication',
      'dosage': baseMedication?['dosage'],
      'scheduleType': 'vaccine_protocol',
      'scheduleText': l10n.vaccineProtocolLabel,
      'vaccineId': vaccine['id'],
      'protocolOffsets': [
        {'kind': 'before', 'minutes': beforeHours * 60},
        {'kind': 'after', 'minutes': afterHours * 60},
      ],
      'repeatEveryHours': null,
      'maxDoses': null,
      'notes': baseMedication?['notes'],
      'isActive': true,
      'createdAt': DateTime.now(),
    };

    medications.add(protocolMedication);
    await VeriYonetici.saveIlacKayitlari(medications);
    await _scheduleProtocolReminders(protocolMedication);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.vaccineProtocolAdded)));
    }
  }

  void _showVaccineOptions(Map<String, dynamic> vaccine, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.primary),
                title: Text(l10n.edit),
                onTap: () {
                  Navigator.pop(context);
                  _editVaccine(vaccine, index);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.medication_liquid_outlined,
                  color: AppColors.primary,
                ),
                title: Text(l10n.addVaccineProtocol),
                onTap: () {
                  Navigator.pop(context);
                  _addVaccineProtocol(vaccine);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteVaccine(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      // Adjust indices to account for baby info card at index 0
      oldIndex -= 1;
      newIndex -= 1;

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _vaccines.removeAt(oldIndex);
      _vaccines.insert(newIndex, item);
    });
    await VeriYonetici.saveAsiKayitlari(_vaccines);
  }

  void _initializeDefaultVaccines() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.loadCalendarTitle),
        content: Text(l10n.loadCalendarDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final defaultVaccines = AsiVeri.getTurkiyeAsiTakvimi();
      final existingVaccines = VeriYonetici.getAsiKayitlari();

      final existingIds = existingVaccines.map((v) => v['id']).toSet();
      final newVaccines = defaultVaccines
          .where((v) => !existingIds.contains(v['id']))
          .toList();

      existingVaccines.addAll(newVaccines);
      await VeriYonetici.saveAsiKayitlari(existingVaccines);
      _loadVaccines();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.vaccinesAdded(newVaccines.length))),
        );
      }
    }
  }

  /// Checks if a vaccine already exists in user's list (same name + same period)
  bool _isDuplicateVaccine(Map<String, dynamic> vaccine) {
    return _vaccines.any(
      (v) => v['ad'] == vaccine['ad'] && v['donem'] == vaccine['donem'],
    );
  }

  void _showNationalVaccineSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final nationalVaccines = AsiVeri.getTurkiyeAsiTakvimi();

    // Track which vaccines are selected (initially none)
    final selectedVaccines = <String, bool>{};
    for (final vaccine in nationalVaccines) {
      selectedVaccines[vaccine['id']] = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Count selected and available (non-duplicate) vaccines
          int availableCount = 0;
          int selectedCount = 0;
          for (final vaccine in nationalVaccines) {
            if (!_isDuplicateVaccine(vaccine)) {
              availableCount++;
              if (selectedVaccines[vaccine['id']] == true) {
                selectedCount++;
              }
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : const Color(0xFFFFFBF5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAB9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('🇹🇷', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.turkishVaccineCalendar,
                              style: AppTypography.h2(context),
                            ),
                            Text(
                              l10n.vaccinesAvailable(availableCount),
                              style: AppTypography.caption(context).copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF866F65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
                        ),
                      ),
                    ],
                  ),
                ),
                // Select All / Deselect All buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: availableCount > 0
                              ? () {
                                  setModalState(() {
                                    for (final vaccine in nationalVaccines) {
                                      if (!_isDuplicateVaccine(vaccine)) {
                                        selectedVaccines[vaccine['id']] = true;
                                      }
                                    }
                                  });
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.selectAll),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: selectedCount > 0
                              ? () {
                                  setModalState(() {
                                    for (final id in selectedVaccines.keys) {
                                      selectedVaccines[id] = false;
                                    }
                                  });
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF866F65),
                            side: BorderSide(
                              color: const Color(
                                0xFF866F65,
                              ).withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.clear),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Vaccine list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: nationalVaccines.length,
                    itemBuilder: (context, index) {
                      final vaccine = nationalVaccines[index];
                      final isDuplicate = _isDuplicateVaccine(vaccine);
                      final isSelected =
                          selectedVaccines[vaccine['id']] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDuplicate
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : isSelected
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: isDuplicate
                                ? null
                                : (value) {
                                    setModalState(() {
                                      selectedVaccines[vaccine['id']] =
                                          value ?? false;
                                    });
                                  },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.primary,
                            title: Text(
                              vaccine['ad'],
                              style: AppTypography.body(context).copyWith(
                                color: isDuplicate
                                    ? (isDark
                                          ? AppColors.textSecondaryDark
                                                .withValues(alpha: 0.5)
                                          : const Color(
                                              0xFF866F65,
                                            ).withValues(alpha: 0.5))
                                    : null,
                                decoration: isDuplicate
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              isDuplicate
                                  ? '${localizedPeriodLabel(l10n, vaccine['donem'])} • ${l10n.alreadyAdded}'
                                  : '${localizedPeriodLabel(l10n, vaccine['donem'])}${vaccine['notlar']?.isNotEmpty == true ? ' • ${vaccine['notlar']}' : ''}',
                              style: AppTypography.caption(context).copyWith(
                                color: isDuplicate
                                    ? (isDark
                                          ? AppColors.textSecondaryDark
                                                .withValues(alpha: 0.4)
                                          : const Color(
                                              0xFF866F65,
                                            ).withValues(alpha: 0.4))
                                    : (isDark
                                          ? AppColors.textSecondaryDark
                                          : const Color(0xFF866F65)),
                              ),
                            ),
                            secondary: isDuplicate
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.accentGreen.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Add button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedCount > 0
                            ? () async {
                                // Gather selected vaccines
                                final toAdd = nationalVaccines
                                    .where(
                                      (v) =>
                                          selectedVaccines[v['id']] == true &&
                                          !_isDuplicateVaccine(v),
                                    )
                                    .toList();

                                if (toAdd.isEmpty) {
                                  Navigator.pop(context);
                                  return;
                                }

                                // Add vaccines with new unique IDs to avoid conflicts
                                final existingVaccines =
                                    VeriYonetici.getAsiKayitlari();
                                for (final vaccine in toAdd) {
                                  final newVaccine = Map<String, dynamic>.from(
                                    vaccine,
                                  );
                                  // Generate a unique ID to prevent ID conflicts
                                  newVaccine['id'] =
                                      '${vaccine['id']}_${DateTime.now().millisecondsSinceEpoch}_${existingVaccines.length}';
                                  existingVaccines.add(newVaccine);
                                }

                                await VeriYonetici.saveAsiKayitlari(
                                  existingVaccines,
                                );
                                _loadVaccines();

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.vaccinesAdded(toAdd.length),
                                      ),
                                      backgroundColor: AppColors.accentGreen,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.3,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          selectedCount > 0
                              ? l10n.addVaccines(selectedCount)
                              : l10n.selectVaccine,
                          style: AppTypography.button(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleTurkishCalendarMenuAction(String value) {
    if (value == 'selector') {
      _showNationalVaccineSelector();
    }
  }

  Widget _buildContent(bool isDark) {
    return SafeArea(
      top: !widget.embedded,
      bottom: !widget.embedded,
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(isDark),
              _buildMonthSelector(isDark),
              const SizedBox(height: 16),
              Expanded(
                child: _vaccines.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBabyInfoCard(isDark),
                            const SizedBox(height: 32),
                            _buildEmptyState(isDark),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        buildDefaultDragHandles: false,
                        onReorder: _onReorder,
                        itemCount: _getFilteredVaccines().length + 1,
                        itemBuilder: (context, index) {
                          final filteredVaccines = _getFilteredVaccines();
                          if (index == 0) {
                            return Padding(
                              key: const ValueKey('baby_info'),
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildBabyInfoCard(isDark),
                            );
                          }
                          final vaccineIndex = index - 1;
                          final vaccine = filteredVaccines[vaccineIndex];
                          final actualIndex = _vaccines.indexOf(vaccine);
                          final isCompleted = vaccine['durum'] == 'uygulandi';
                          return Padding(
                            key: ValueKey(vaccine['id'] ?? actualIndex),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildReorderableVaccineCard(
                              vaccine,
                              actualIndex,
                              isDark,
                              isCompleted,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          Positioned(bottom: 32, left: 24, right: 24, child: _buildAddButton()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.embedded) {
      return _buildContent(isDark);
    }

    return DecorativeBackground(
      preset: BackgroundPreset.vaccines,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildContent(isDark),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final canPop = Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          if (canPop) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDarkCard : Colors.white,
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
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF2D1A18),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(l10n.myVaccines, style: AppTypography.h1(context)),
          ),
          // National vaccine selector button
          if (_showTurkishPresetByDefault)
            GestureDetector(
            onTap: _showNationalVaccineSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.bgDarkCard
                    : const Color(0xFFFFDAB9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇹🇷', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.calendar,
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          else
            PopupMenuButton<String>(
              tooltip: l10n.loadTurkishVaccineCalendar,
              onSelected: _handleTurkishCalendarMenuAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'selector',
                  child: Text(l10n.loadTurkishVaccineCalendar),
                ),
              ],
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDarkCard : Colors.white,
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
                  Icons.more_horiz,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF2D1A18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAB9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.child_care,
              color: const Color(0xFFFFB4A2),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getBabyName(), style: AppTypography.h2(context)),
              const SizedBox(height: 4),
              Text(
                _getChildAge(),
                style: AppTypography.bodySmall(context).copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF866F65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolSummary(Map<String, dynamic> vaccine, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final protocols = _protocolsForVaccine(vaccine['id'] as String);
    if (protocols.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: protocols.map((p) {
          final doseCount = VeriYonetici.getIlacDozKayitlari(
            medicationId: p['id'] as String,
            vaccineId: vaccine['id'] as String,
          ).length;
          return Text(
            '• ${p['name']} — ${l10n.doseCountLabel(doseCount)}',
            style: AppTypography.caption(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReorderableVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
    bool isCompleted,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = vaccine['tarih'] != null
        ? formatLocalizedDate(context, vaccine['tarih'] as DateTime)
        : '';

    return GestureDetector(
      onTap: () => _editVaccine(vaccine, index),
      onLongPress: () => _showVaccineOptions(vaccine, index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Only show drag handle when not filtering
            if (_selectedMonth == null)
              ReorderableDragStartListener(
                index: index + 1,
                child: Icon(
                  Icons.drag_indicator,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.4)
                      : const Color(0xFF866F65).withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
            if (_selectedMonth == null) const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFFFDAB9)
                    : AppColors.accentPeach.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.vaccines,
                color: isCompleted
                    ? const Color(0xFFFFB4A2)
                    : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine['ad'],
                    style: AppTypography.h3(context).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted
                        ? '${l10n.applied} - $dateStr'
                        : dateStr.isNotEmpty
                        ? '${localizedPeriodLabel(l10n, vaccine['donem'])} • $dateStr'
                        : '${localizedPeriodLabel(l10n, vaccine['donem'])} • ${l10n.selectDate}',
                    style: AppTypography.caption(context).copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF866F65),
                    ),
                  ),
                  _buildProtocolSummary(vaccine, isDark),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : const Color(0xFF866F65).withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
    bool isCompleted,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = vaccine['tarih'] != null
        ? formatLocalizedDate(context, vaccine['tarih'] as DateTime)
        : '';

    return GestureDetector(
      onTap: () => _editVaccine(vaccine, index),
      onLongPress: () => _showVaccineOptions(vaccine, index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.vaccines,
                color: const Color(0xFFFFB4A2),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine['ad'],
                    style: AppTypography.h3(context).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted
                        ? '${l10n.applied} - $dateStr'
                        : dateStr.isNotEmpty
                        ? '${localizedPeriodLabel(l10n, vaccine['donem'])} • $dateStr'
                        : '${localizedPeriodLabel(l10n, vaccine['donem'])} • ${l10n.selectDate}',
                    style: AppTypography.caption(context).copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF866F65),
                    ),
                  ),
                  _buildProtocolSummary(vaccine, isDark),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : const Color(0xFF866F65).withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildUpcomingVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = vaccine['tarih'] != null
        ? formatLocalizedDate(context, vaccine['tarih'] as DateTime)
        : '';

    return GestureDetector(
      onTap: () => _editVaccine(vaccine, index),
      onLongPress: () => _showVaccineOptions(vaccine, index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentPeach.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.vaccines, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine['ad'],
                    style: AppTypography.h3(context).copyWith(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF866F65),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr.isNotEmpty
                        ? '${localizedPeriodLabel(l10n, vaccine['donem'])} • $dateStr'
                        : '${localizedPeriodLabel(l10n, vaccine['donem'])} • ${l10n.selectDate}',
                    style: AppTypography.caption(context).copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF866F65),
                    ),
                  ),
                  _buildProtocolSummary(vaccine, isDark),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : const Color(0xFF866F65).withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    // Month options: All, 0 (Doğumda), 1, 2, 4, 6, 9, 12, 18, 24, 48, 60
    final monthOptions = <int?>[
      null, // All
      0, 1, 2, 4, 6, 9, 12, 18, 24, 48, 60,
    ];

    String getMonthLabel(int? month) {
      if (month == null) return l10n.allLabel;
      if (month == 0) return l10n.birth;
      return l10n.monthNumber(month);
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: monthOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = monthOptions[index];
          final isSelected = _selectedMonth == month;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonth = month;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.bgDarkCard : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                getMonthLabel(month),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF866F65)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final showTurkishPresetByDefault = _showTurkishPresetByDefault;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.vaccines_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noVaccineRecords,
            style: AppTypography.h3(context),
            textAlign: TextAlign.center,
          ),
          if (showTurkishPresetByDefault) ...[
            const SizedBox(height: 8),
            Text(
              l10n.loadTurkishCalendar,
              style: AppTypography.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          if (showTurkishPresetByDefault)
            OutlinedButton.icon(
              onPressed: _initializeDefaultVaccines,
              icon: const Icon(Icons.calendar_month),
              label: Text(l10n.loadCalendarTitle),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _initializeDefaultVaccines,
              icon: const Icon(Icons.flag_outlined),
              label: Text(l10n.loadTurkishVaccineCalendar),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVaccineScreen()),
          );

          if (result == true) {
            _loadVaccines();
          }
        },
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
              l10n.addVaccine,
              style: AppTypography.button().copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
