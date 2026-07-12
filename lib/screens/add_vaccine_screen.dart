import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/decorative_background.dart';

class AddVaccineScreen extends StatefulWidget {
  final Map<String, dynamic>? vaccine;
  final String? babyId;

  const AddVaccineScreen({super.key, this.vaccine, this.babyId});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedStatus = 'bekleniyor';
  DateTime? _selectedDate;
  bool _isSaving = false;
  late final String _targetBabyId;

  @override
  void initState() {
    super.initState();
    _targetBabyId =
        widget.vaccine?['babyId']?.toString().trim() ??
        widget.babyId?.trim() ??
        VeriYonetici.getActiveBabyId();
    if (widget.vaccine != null) {
      _nameController.text = widget.vaccine!['ad'] ?? '';
      _notesController.text = widget.vaccine!['notlar'] ?? '';
      _selectedStatus = widget.vaccine!['durum'] ?? 'bekleniyor';
      _selectedDate = widget.vaccine!['tarih'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AddVaccineScreen] $message');
    }
  }

  Future<void> _saveVaccine() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.vaccineNameCannotBeEmpty)));
      return;
    }
    setState(() => _isSaving = true);

    try {
      final targetBabyId = _targetBabyId.trim();
      if (targetBabyId.isEmpty) {
        throw StateError(l10n.spNoActiveBaby);
      }
      final vaccines = VeriYonetici.getAsiKayitlariForBaby(targetBabyId);
      _debugLog(
        'targetBabyId=$targetBabyId beforeCount=${vaccines.length} '
        'existingIds=${vaccines.map((v) => v['id']).join(',')}',
      );
      final newVaccine = {
        'id':
            widget.vaccine?['id'] ??
            'vaccine_${DateTime.now().microsecondsSinceEpoch}',
        'babyId': targetBabyId,
        'ad': _nameController.text.trim(),
        // Keep the legacy field compatible without exposing period as editable
        // vaccine data. Calendar dates are the scheduling source of truth.
        'donem': widget.vaccine?['donem'] ?? '',
        'durum': _selectedStatus,
        'tarih': _selectedDate,
        'notlar': _notesController.text.trim(),
        'isDeleted': false,
      };
      _debugLog(
        'newVaccine '
        'id=${newVaccine['id']} '
        'babyId=${newVaccine['babyId']} '
        'ad=${newVaccine['ad']} '
        'durum=${newVaccine['durum']} '
        'donem=${newVaccine['donem']} '
        'isDeleted=${newVaccine['isDeleted']}',
      );

      final existingIndex = vaccines.indexWhere(
        (v) => v['id'] == widget.vaccine?['id'],
      );
      if (existingIndex >= 0) {
        vaccines[existingIndex] = newVaccine;
      } else {
        vaccines.add(newVaccine);
      }

      await VeriYonetici.saveAsiKayitlariForBaby(targetBabyId, vaccines);
      final persisted = VeriYonetici.getAsiKayitlariForBaby(targetBabyId);
      final persistedIds = persisted
          .map((v) => (v['id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      final savedId = (newVaccine['id'] ?? '').toString();
      _debugLog(
        'afterSave targetBabyId=$targetBabyId afterCount=${persisted.length} '
        'persistedIds=${persistedIds.join(',')}',
      );
      if (!persistedIds.contains(savedId)) {
        final detail =
            'Vaccine missing after save '
            'targetBabyId=$targetBabyId '
            'savedId=$savedId '
            'persistedIds=${persistedIds.join(',')}';
        _debugLog(detail);
        throw StateError(kDebugMode ? detail : l10n.saveFailedTryAgain);
      }
      HapticFeedback.lightImpact();
      if (!mounted) return;
      Navigator.pop(context, <String, dynamic>{
        'saved': true,
        'babyId': targetBabyId,
        'vaccineId': savedId,
      });
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

  void _selectDate() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    DateTime tempDate = _selectedDate ?? DateTime.now();
    final lastDate = _selectedStatus == 'bekleniyor'
        ? DateTime.now().add(const Duration(days: 365 * 5))
        : DateTime.now();

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: AppTypography.dialogAction(context).copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempDate;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.ok,
                        style: AppTypography.dialogAction(
                          context,
                        ).copyWith(color: const Color(0xFFFFB4A2)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate.isAfter(lastDate)
                      ? lastDate
                      : tempDate,
                  minimumDate: DateTime(2020),
                  maximumDate: lastDate,
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.vaccine != null;

    return DecorativeBackground(
      preset: BackgroundPreset.vaccines,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(isDark, isEdit),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameField(isDark),
                          const SizedBox(height: 24),
                          _buildStatusSelector(isDark),

                          const SizedBox(height: 24),
                          _buildDateSelector(isDark),

                          const SizedBox(height: 24),
                          _buildNotesField(isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isEdit) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: const Color(0xFFFFB4A2),
                size: 24,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isEdit ? l10n.editVaccine : l10n.addVaccine,
            style: AppTypography.h1(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.vaccineName,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            style: AppTypography.body(context),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.vaccineNameHint,
              hintStyle: AppTypography.bodySmall(context),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.status,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = 'bekleniyor';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedStatus == 'bekleniyor'
                        ? const Color(0xFFE5E0F7)
                        : (isDark
                              ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedStatus == 'bekleniyor'
                          ? const Color(0xFFE5E0F7)
                          : const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      if (_selectedStatus == 'bekleniyor')
                        BoxShadow(
                          color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      l10n.pending,
                      style: AppTypography.body(context).copyWith(
                        color: _selectedStatus == 'bekleniyor'
                            ? const Color(0xFF5D3FD3)
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = 'uygulandi';
                    _selectedDate ??= DateTime.now();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedStatus == 'uygulandi'
                        ? const Color(0xFF81C784)
                        : (isDark
                              ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedStatus == 'uygulandi'
                          ? const Color(0xFF81C784)
                          : const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      if (_selectedStatus == 'uygulandi')
                        BoxShadow(
                          color: const Color(0xFF81C784).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      l10n.applied,
                      style: AppTypography.body(context).copyWith(
                        color: _selectedStatus == 'uygulandi'
                            ? Colors.white
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final dateLabel = _selectedStatus == 'bekleniyor'
        ? l10n.scheduledDate
        : l10n.selectDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            dateLabel,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: const Color(0xFFFFB4A2),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? formatLocalizedDate(context, _selectedDate!)
                      : l10n.selectDate,
                  style: AppTypography.body(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.optionalNotes,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            style: AppTypography.body(context),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.vaccineDoseHint,
              hintStyle: AppTypography.bodySmall(context),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveVaccine,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB4A2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.vaccine != null ? l10n.update : l10n.save,
                style: AppTypography.button().copyWith(fontSize: 18),
              ),
      ),
    );
  }
}
