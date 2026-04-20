import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/allergy.dart';
import '../models/veri_yonetici.dart';
import '../services/allergy_service.dart';
import '../theme/app_theme.dart';

class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  final AllergyService _service = AllergyService();
  bool _streamHasInlineError = false;

  String? get _babyId => VeriYonetici.getActiveBabyOrNull()?.id;

  String _formatAllergyError(Object error, AppLocalizations l10n) {
    return l10n.errorWithMessage(AllergyService.formatUserFacingError(error));
  }

  void _showErrorSnackBar(String message) {
    if (!mounted || _streamHasInlineError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  void _showAddSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final noteController = TextEditingController();
    bool isSaving = false;

    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : const Color(0xFF2D1A18);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12, bottom: 18),
                        decoration: BoxDecoration(
                          color: subtitleColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.addAllergy,
                            style: AppTypography.h2(
                              context,
                            ).copyWith(color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.allergySheetSubtitle,
                            style: AppTypography.bodySmall(
                              context,
                            ).copyWith(color: subtitleColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        style: AppTypography.body(
                          context,
                        ).copyWith(color: textColor),
                        decoration: InputDecoration(
                          labelText: l10n.allergyName,
                          labelStyle: AppTypography.caption(
                            context,
                          ).copyWith(color: subtitleColor),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFFE5E0F7).withValues(alpha: 0.08)
                              : const Color(0xFFF7F5FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: noteController,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTypography.body(
                          context,
                        ).copyWith(color: textColor),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.allergyNote,
                          labelStyle: AppTypography.caption(
                            context,
                          ).copyWith(color: subtitleColor),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFFE5E0F7).withValues(alpha: 0.08)
                              : const Color(0xFFF7F5FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB4A2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) return;
                                  final babyId = _babyId;
                                  if (babyId == null) return;

                                  setSheetState(() => isSaving = true);
                                  try {
                                    await _service.addAllergy(
                                      babyId,
                                      name,
                                      note: noteController.text.trim().isEmpty
                                          ? null
                                          : noteController.text.trim(),
                                    );
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.allergyAdded),
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    setSheetState(() => isSaving = false);
                                    _showErrorSnackBar(
                                      _formatAllergyError(error, l10n),
                                    );
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.addAllergy,
                                  style: AppTypography.label(
                                    context,
                                  ).copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(ctx).padding.bottom + 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Allergy allergy) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final babyId = _babyId;
    if (babyId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteAllergy,
          style: AppTypography.h2(context).copyWith(
            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18),
          ),
        ),
        content: Text(
          allergy.name,
          style: AppTypography.body(context).copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF7A749E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: AppTypography.label(
                context,
              ).copyWith(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.removeAllergy(babyId, allergy.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : const Color(0xFF2D1A18);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final body = _buildBody(
      context,
      cardColor: cardColor,
      subtitleColor: subtitleColor,
      textColor: textColor,
      isDark: isDark,
      l10n: l10n,
    );

    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.allergiesTitle,
                    style: AppTypography.h1(context).copyWith(color: textColor),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddSheet(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB4A2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFFFBF5),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back, color: textColor, size: 20),
          ),
        ),
        title: Text(
          l10n.allergiesTitle,
          style: AppTypography.h1(context).copyWith(color: textColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showAddSheet(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB4A2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required Color cardColor,
    required Color subtitleColor,
    required Color textColor,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final babyId = _babyId;

    if (babyId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Allergy>>(
      stream: _service.watchAllergies(babyId),
      builder: (context, snap) {
        _streamHasInlineError = snap.hasError;

        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _formatAllergyError(snap.error!, l10n),
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(
                  context,
                ).copyWith(color: subtitleColor),
              ),
            ),
          );
        }

        final allergies = snap.data ?? [];

        if (allergies.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.no_food_outlined,
                      size: 34,
                      color: subtitleColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noAllergies,
                    style: AppTypography.h2(context).copyWith(color: textColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.noAllergiesSummary,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(
                      context,
                    ).copyWith(color: subtitleColor),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.tonalIcon(
                    onPressed: () => _showAddSheet(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addAllergy),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: allergies.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final allergy = allergies[index];
            return Dismissible(
              key: ValueKey(allergy.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              confirmDismiss: (_) async {
                await _confirmDelete(context, allergy);
                return false; // handled inside _confirmDelete
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: allergy.isActive
                        ? const Color(0xFFFFE4DA)
                        : const Color(0xFFEAE4F4),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: allergy.isActive
                            ? const Color(0xFFFFF1EC)
                            : const Color(0xFFF3EFF7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        allergy.isActive
                            ? Icons.health_and_safety_outlined
                            : Icons.history_toggle_off_rounded,
                        color: allergy.isActive
                            ? const Color(0xFFE39A86)
                            : subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allergy.name,
                            style: AppTypography.h3(context).copyWith(
                              color: textColor,
                              decoration: allergy.isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            allergy.isActive
                                ? l10n.allergyActive
                                : l10n.allergyInactive,
                            style: AppTypography.caption(
                              context,
                            ).copyWith(color: subtitleColor),
                          ),
                          if (allergy.note != null &&
                              allergy.note!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              allergy.note!,
                              style: AppTypography.body(
                                context,
                              ).copyWith(color: subtitleColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch.adaptive(
                      value: allergy.isActive,
                      activeThumbColor: const Color(0xFFFFB4A2),
                      activeTrackColor: const Color(
                        0xFFFFB4A2,
                      ).withValues(alpha: 0.4),
                      onChanged: (value) => _service.toggleAllergyActive(
                        babyId,
                        allergy.id,
                        value,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
