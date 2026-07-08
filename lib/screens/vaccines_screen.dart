import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../models/asi_veri.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/decorative_background.dart';
import '../widgets/nilico_motion.dart';
import '../widgets/nilico_primary_button.dart';
import 'add_vaccine_screen.dart';

class VaccinesScreen extends StatefulWidget {
  final bool embedded;
  const VaccinesScreen({super.key, this.embedded = false});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  List<Map<String, dynamic>> _vaccines = [];
  late final VoidCallback _vaccineListener;
  String _screenBabyId = '';

  @override
  void initState() {
    super.initState();
    _screenBabyId = VeriYonetici.getActiveBabyId().trim();
    _vaccineListener = () {
      if (mounted) _loadVaccines();
    };
    VeriYonetici.vaccineNotifier.addListener(_vaccineListener);
    VeriYonetici.dataNotifier.addListener(_vaccineListener);
    _loadVaccines();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVaccines();
  }

  @override
  void dispose() {
    VeriYonetici.vaccineNotifier.removeListener(_vaccineListener);
    VeriYonetici.dataNotifier.removeListener(_vaccineListener);
    super.dispose();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[VaccinesScreen] $message');
    }
  }

  String _resolveScreenBabyId({String? preferredBabyId}) {
    final preferred = preferredBabyId?.trim() ?? '';
    if (preferred.isNotEmpty) {
      _screenBabyId = preferred;
      return _screenBabyId;
    }
    final activeBabyId = VeriYonetici.getActiveBabyId().trim();
    if (activeBabyId.isNotEmpty) {
      _screenBabyId = activeBabyId;
    }
    return _screenBabyId;
  }

  void _loadVaccines({String? preferredBabyId}) {
    final targetBabyId = _resolveScreenBabyId(preferredBabyId: preferredBabyId);
    final loaded = VeriYonetici.getAsiKayitlariForBaby(targetBabyId);
    _debugLog(
      '_screenBabyId=$targetBabyId loadedIds='
      '${loaded.map((v) => v['id']).join(',')}',
    );
    setState(() {
      _vaccines = loaded;
    });
  }

  String _getChildAge() {
    return formatLocalizedAge(context, VeriYonetici.getBirthDate());
  }

  String _getBabyName() {
    return VeriYonetici.getBabyName();
  }

  void _deleteVaccine(Map<String, dynamic> vaccine) async {
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
      final targetBabyId = _resolveScreenBabyId();
      _vaccines.removeWhere((item) => item['id'] == vaccine['id']);
      await VeriYonetici.saveAsiKayitlariForBaby(targetBabyId, _vaccines);
    }
  }

  void _editVaccine(Map<String, dynamic> vaccine) async {
    final targetBabyId = _resolveScreenBabyId(
      preferredBabyId: vaccine['babyId']?.toString(),
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddVaccineScreen(vaccine: vaccine, babyId: targetBabyId),
      ),
    );

    if (result == true) {
      _loadVaccines();
    } else if (result is Map && result['saved'] == true) {
      _loadVaccines(preferredBabyId: result['babyId']?.toString());
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
    final vaccine = VeriYonetici.getAsiKayitlariForBaby(
      _screenBabyId,
    ).where((v) => v['id'] == vaccineId).firstOrNull;
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

  void _showVaccineOptions(Map<String, dynamic> vaccine) {
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
                  _editVaccine(vaccine);
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
                  _deleteVaccine(vaccine);
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
    final targetBabyId = _resolveScreenBabyId();
    await VeriYonetici.saveAsiKayitlariForBaby(targetBabyId, _vaccines);
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
      final targetBabyId = _resolveScreenBabyId();
      final existingVaccines = VeriYonetici.getAsiKayitlariForBaby(
        targetBabyId,
      );

      final existingIds = existingVaccines.map((v) => v['id']).toSet();
      final newVaccines = defaultVaccines
          .where((v) => !existingIds.contains(v['id']))
          .toList();

      existingVaccines.addAll(newVaccines);
      await VeriYonetici.saveAsiKayitlariForBaby(
        targetBabyId,
        existingVaccines,
      );
      _loadVaccines(preferredBabyId: targetBabyId);

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
                                    VeriYonetici.getAsiKayitlariForBaby(
                                      _resolveScreenBabyId(),
                                    );
                                for (final vaccine in toAdd) {
                                  final newVaccine = Map<String, dynamic>.from(
                                    vaccine,
                                  );
                                  // Generate a unique ID to prevent ID conflicts
                                  newVaccine['id'] =
                                      '${vaccine['id']}_${DateTime.now().millisecondsSinceEpoch}_${existingVaccines.length}';
                                  existingVaccines.add(newVaccine);
                                }

                                await VeriYonetici.saveAsiKayitlariForBaby(
                                  _resolveScreenBabyId(),
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
    if (value == 'load_all') {
      _initializeDefaultVaccines();
    } else if (value == 'selector') {
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
              const SizedBox(height: 8),
              Expanded(
                child: _vaccines.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NilicoEntrance(child: _buildBabyInfoCard(isDark)),
                            const SizedBox(height: 20),
                            NilicoEntrance(child: _buildEmptyState(isDark)),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        buildDefaultDragHandles: false,
                        onReorder: _onReorder,
                        itemCount: _vaccines.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              key: const ValueKey('baby_info'),
                              padding: const EdgeInsets.only(bottom: 24),
                              child: NilicoEntrance(
                                key: const ValueKey('baby_info_entrance'),
                                child: _buildBabyInfoCard(isDark),
                              ),
                            );
                          }
                          final vaccineIndex = index - 1;
                          final vaccine = _vaccines[vaccineIndex];
                          final isCompleted = vaccine['durum'] == 'uygulandi';
                          return Padding(
                            key: ValueKey(vaccine['id'] ?? vaccineIndex),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NilicoEntrance(
                              key: ValueKey('vaccine_${vaccine['id'] ?? vaccineIndex}'),
                              child: _buildReorderableVaccineCard(
                                vaccine,
                                vaccineIndex,
                                isDark,
                                isCompleted,
                              ),
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
    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        child: Row(
          children: [const Spacer(), _buildCalendarMenuButton(isDark, l10n)],
        ),
      );
    }
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
          _buildCalendarMenuButton(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildCalendarMenuButton(bool isDark, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      tooltip: l10n.loadTurkishVaccineCalendar,
      onSelected: _handleTurkishCalendarMenuAction,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'load_all',
          child: Text(l10n.loadTurkishVaccineCalendar),
        ),
        PopupMenuItem(value: 'selector', child: Text(l10n.selectVaccine)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard
              : const Color(0xFFFFF3EE).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.calendar,
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFB4A2).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8DE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.child_care,
              color: const Color(0xFFFFB4A2),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getBabyName(),
                  style: AppTypography.h3(context).copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
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
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_vaccines.length}',
              style: AppTypography.h3(context).copyWith(fontSize: 15),
            ),
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
      onTap: () => _editVaccine(vaccine),
      onLongPress: () => _showVaccineOptions(vaccine),
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
            const SizedBox(width: 8),
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
      onTap: () => _editVaccine(vaccine),
      onLongPress: () => _showVaccineOptions(vaccine),
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
      onTap: () => _editVaccine(vaccine),
      onLongPress: () => _showVaccineOptions(vaccine),
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

  Widget _buildEmptyState(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.vaccines_outlined,
              size: 42,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noVaccineRecords,
            style: AppTypography.h3(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.vaccineEmptySubtitle,
            style: AppTypography.bodySmall(context).copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context)!;
    return NilicoPrimaryButton(
      label: l10n.addVaccine,
      icon: Icons.add_circle,
      onPressed: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddVaccineScreen(babyId: _resolveScreenBabyId()),
          ),
        );

        if (result == true) {
          _loadVaccines();
        } else if (result is Map && result['saved'] == true) {
          _loadVaccines(preferredBabyId: result['babyId']?.toString());
        }
      },
    );
  }
}
