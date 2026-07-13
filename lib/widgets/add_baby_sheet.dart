import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoDatePicker, CupertinoDatePickerMode;
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import 'nilico_modal.dart';
import 'nilico_motion.dart';

class AddBabySheet extends StatefulWidget {
  final VoidCallback onBabyAdded;

  const AddBabySheet({super.key, required this.onBabyAdded});

  @override
  State<AddBabySheet> createState() => _AddBabySheetState();
}

class _AddBabySheetState extends State<AddBabySheet> {
  final _nameController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final newId = await VeriYonetici.addBaby(
        name: name,
        birthDate: _birthDate,
      );
      await VeriYonetici.setActiveBaby(newId);

      if (!mounted) return;
      NilicoHaptics.trigger(NilicoHapticType.success);
      Navigator.pop(context);
      widget.onBabyAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorWithMessage(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _pickDate() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showNilicoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DateTime selected = _birthDate;
        return NilicoSheetFrame(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            height: 232,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          l10n.cancel,
                          style: AppTypography.dialogAction(ctx).copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF866F65),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _birthDate = selected);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          l10n.ok,
                          style: AppTypography.dialogAction(
                            ctx,
                          ).copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    maximumDate: DateTime.now(),
                    initialDateTime: _birthDate,
                    onDateTimeChanged: (d) => selected = d,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D1A18);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: NilicoSheetFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NilicoSheetHeader(
              title: l10n.newBabyAdd,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 18),
            // Name field
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: AppTypography.body(context).copyWith(color: textColor),
              decoration: InputDecoration(
                hintText: l10n.babyNameHint,
                hintStyle: AppTypography.body(
                  context,
                ).copyWith(color: textColor.withValues(alpha: 0.4)),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFEBE8FF).withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Birth date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFEBE8FF).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      color: textColor.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatLocalizedDate(context, _birthDate),
                      style: AppTypography.body(
                        context,
                      ).copyWith(color: textColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB4A2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
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
}
