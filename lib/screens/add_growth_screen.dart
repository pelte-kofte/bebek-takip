import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../l10n/app_localizations.dart';
import '../models/ikonlar.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';

class AddGrowthScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const AddGrowthScreen({super.key, this.onSaved});

  @override
  State<AddGrowthScreen> createState() => _AddGrowthScreenState();
}

class _AddGrowthScreenState extends State<AddGrowthScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF4A3F3F),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.growthEntryTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.h2(context).copyWith(
                            fontSize: 24,
                            color: const Color(0xFF2D1A18),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.growthEntrySubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(
                            context,
                          ).copyWith(color: const Color(0xFF7A749E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E0F7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(child: Ikonlar.growth(size: 64)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.dateLabel,
                      style: AppTypography.label(
                        context,
                      ).copyWith(color: const Color(0xFF7A749E)),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: Localizations.localeOf(context),
                          builder: (pickerContext, child) {
                            return Theme(
                              data: Theme.of(pickerContext).copyWith(
                                datePickerTheme: DatePickerThemeData(
                                  headerHeadlineStyle:
                                      AppTypography.dialogTitle(pickerContext),
                                  headerHelpStyle: AppTypography.caption(
                                    pickerContext,
                                  ),
                                  weekdayStyle: AppTypography.caption(
                                    pickerContext,
                                  ),
                                  dayStyle: AppTypography.bodySmall(
                                    pickerContext,
                                  ),
                                  yearStyle: AppTypography.bodySmall(
                                    pickerContext,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSoft),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.025),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E0F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF7A749E),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              intl.DateFormat.yMd(
                                localeName,
                              ).format(_selectedDate),
                              style: AppTypography.compactTitle(context)
                                  .copyWith(
                                    fontSize: 18,
                                    color: const Color(0xFF2D1A18),
                                  ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF7A749E),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.weight,
                      style: AppTypography.label(
                        context,
                      ).copyWith(color: const Color(0xFF7A749E)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSoft),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.growthWeightHint,
                          hintStyle: AppTypography.body(context).copyWith(
                            color: const Color(0xFF7A749E),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.42),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Icon(
                              Icons.monitor_weight_outlined,
                              color: Color(0xFFFFB4A2),
                              size: 24,
                            ),
                          ),
                          suffixText: l10n.kilogramUnit,
                          suffixStyle: AppTypography.bodySmall(
                            context,
                          ).copyWith(color: const Color(0xFF7A749E)),
                        ),
                        style: AppTypography.compactTitle(context).copyWith(
                          fontSize: 18,
                          color: const Color(0xFF2D1A18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.height,
                      style: AppTypography.label(
                        context,
                      ).copyWith(color: const Color(0xFF7A749E)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSoft),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.growthHeightHint,
                          hintStyle: AppTypography.body(context).copyWith(
                            color: const Color(0xFF7A749E),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.42),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Icon(
                              Icons.height,
                              color: Color(0xFFFFB4A2),
                              size: 24,
                            ),
                          ),
                          suffixText: l10n.centimeterUnit,
                          suffixStyle: AppTypography.bodySmall(
                            context,
                          ).copyWith(color: const Color(0xFF7A749E)),
                        ),
                        style: AppTypography.compactTitle(context).copyWith(
                          fontSize: 18,
                          color: const Color(0xFF2D1A18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.notesOptional,
                      style: AppTypography.label(
                        context,
                      ).copyWith(color: const Color(0xFF7A749E)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSoft),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.growthNotesHint,
                          hintStyle: AppTypography.bodySmall(context).copyWith(
                            color: const Color(
                              0xFF7A749E,
                            ).withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.42),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        style: AppTypography.bodySmall(
                          context,
                        ).copyWith(color: const Color(0xFF2D1A18)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _isSaving ? null : _saveGrowth,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB4A2),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFB4A2,
                              ).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.save,
                                textAlign: TextAlign.center,
                                style: AppTypography.button(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGrowth() async {
    if (_isSaving) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterWeightHeight),
          backgroundColor: const Color(0xFFFFB4A2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final records = VeriYonetici.getBoyKiloKayitlari();

      records.insert(0, {
        'tarih': _selectedDate,
        'boy':
            double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0,
        'kilo':
            double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0,
        'notlar': _notesController.text,
      });

      records.sort(
        (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
      );

      await VeriYonetici.saveBoyKiloKayitlari(records);
      try {
        widget.onSaved?.call();
      } catch (e) {
        debugPrint('AddGrowthScreen onSaved failed: $e');
      }
      if (!mounted) {
        return;
      }
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
}
