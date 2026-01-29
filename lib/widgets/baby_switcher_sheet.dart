import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/baby.dart';
import '../theme/app_theme.dart';
import 'add_baby_sheet.dart';

class BabySwitcherSheet extends StatelessWidget {
  final VoidCallback onBabyChanged;

  const BabySwitcherSheet({super.key, required this.onBabyChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final babies = VeriYonetici.getBabies();
    final activeBabyId = VeriYonetici.getActiveBabyId();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFFFBF5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(
              'Bebek Sec',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2D1A18),
              ),
            ),
          ),
          // Baby list
          ...babies.map((baby) => _buildBabyTile(
                context,
                baby,
                isActive: baby.id == activeBabyId,
                isDark: isDark,
              )),
          const SizedBox(height: 8),
          // Add baby button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _openAddBabySheet(context),
                icon: const Icon(Icons.add, color: Color(0xFFFFB4A2)),
                label: const Text(
                  '+ Yeni Bebek Ekle',
                  style: TextStyle(
                    color: Color(0xFFFFB4A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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
                    ? const Color(0xFFFFB4A2).withValues(alpha: isDark ? 0.25 : 0.2)
                    : (isDark
                        ? const Color(0xFFEBE8FF).withValues(alpha: 0.12)
                        : const Color(0xFFEBE8FF)),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFFFB4A2)
                      : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? const Color(0xFFFFB4A2)
                        : (isDark ? AppColors.textSecondaryDark : const Color(0xFF7A749E)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + age
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baby.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2D1A18),
                    ),
                  ),
                  Text(
                    _formatAge(baby.birthDate),
                    style: TextStyle(
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
              const Icon(Icons.check_circle, color: Color(0xFFFFB4A2), size: 22),
          ],
        ),
      ),
    );
  }

  void _openAddBabySheet(BuildContext context) {
    showModalBottomSheet(
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

  String _formatAge(DateTime birthDate) {
    final now = DateTime.now();
    final diff = now.difference(birthDate);
    final months = (diff.inDays / 30).floor();
    if (months >= 12) {
      final years = months ~/ 12;
      final rem = months % 12;
      if (rem > 0) return '$years yil $rem ay';
      return '$years yil';
    } else if (months > 0) {
      return '$months ay';
    }
    return '${diff.inDays} gun';
  }
}
