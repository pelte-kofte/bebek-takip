import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../models/baby.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import 'add_baby_sheet.dart';
import 'nilico_modal.dart';
import 'nilico_motion.dart';

class BabySwitcherSheet extends StatelessWidget {
  final VoidCallback onBabyChanged;

  const BabySwitcherSheet({super.key, required this.onBabyChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final babies = _dedupeById(VeriYonetici.getBabies());
    final activeBabyId = VeriYonetici.getActiveBabyId();

    return NilicoSheetFrame(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: NilicoSheetHeader(
              title: l10n.selectBaby,
              onClose: () => Navigator.pop(context),
            ),
          ),
          // Baby list
          ...babies.map(
            (baby) => _buildBabyTile(
              context,
              baby,
              isActive: baby.id == activeBabyId,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 8),
          // Add baby button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _openAddBabySheet(context),
                icon: const Icon(Icons.add, color: Color(0xFFFFB4A2)),
                label: Text(
                  '+ ${l10n.newBabyAdd}',
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyTile(
    BuildContext context,
    Baby baby, {
    required bool isActive,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () async {
        if (!isActive) {
          await VeriYonetici.setActiveBaby(baby.id);
        }
        if (context.mounted) Navigator.pop(context);
        onBabyChanged();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(
                        0xFFFFB4A2,
                      ).withValues(alpha: isDark ? 0.25 : 0.2)
                    : (isDark
                          ? const Color(0xFFEBE8FF).withValues(alpha: 0.12)
                          : const Color(0xFFEBE8FF)),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFFFB4A2)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                  style: AppTypography.sheetTitle(context).copyWith(
                    fontSize: 18,
                    color: isActive
                        ? const Color(0xFFFFB4A2)
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF7A749E)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + age + shared label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          baby.name,
                          style: AppTypography.body(context).copyWith(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2D1A18),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (VeriYonetici.isBabyVisiblyShared(baby.id)) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEFF7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.sharedBadge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6AADCF),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    formatLocalizedAge(context, baby.birthDate),
                    style: AppTypography.bodySmall(context).copyWith(
                      fontSize: 13,
                      color: (isDark ? Colors.white : const Color(0xFF2D1A18))
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFFB4A2),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _openAddBabySheet(BuildContext context) {
    showNilicoModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBabySheet(
        onBabyAdded: () {
          Navigator.pop(context); // close switcher
          onBabyChanged();
        },
      ),
    );
  }

  List<Baby> _dedupeById(List<Baby> babies) {
    final byId = <String, Baby>{};
    for (final baby in babies) {
      byId[baby.id] = baby;
    }
    return byId.values.toList();
  }
}
