import 'package:flutter/material.dart';
import '../models/daily_tip.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';

class TipsArchiveScreen extends StatelessWidget {
  const TipsArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : const Color(0xFF2D1A18);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;

    // Compute baby age for today's tip highlight only
    final birthDate = VeriYonetici.getBirthDate();
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    // Subtract 1 if we haven't reached the birth day yet this month
    if (now.day < birthDate.day) {
      months -= 1;
    }
    final babyAgeInMonths = months < 0 ? 0 : months;

    // Get today's tip (age-filtered) for highlighting
    final todayTip = DailyTip.todayForBaby(babyAgeInMonths);

    // Show ALL tips in archive (no age filtering)
    final allTips = DailyTip.tips;

    return DecorativeBackground(
      preset: BackgroundPreset.home,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardColor,
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
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Günlük İpuçları',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '0–1 Ay Dönemi',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tips list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  itemCount: allTips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tip = allTips[index];
                    final isToday = tip.id == todayTip.id;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isToday
                              ? const Color(0xFFFFB4A2).withValues(alpha: 0.5)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : const Color(
                                        0xFFE5E0F7,
                                      ).withValues(alpha: 0.4)),
                          width: isToday ? 1.5 : 1,
                        ),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE5E0F7,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Illustration
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(
                                      0xFFE5E0F7,
                                    ).withValues(alpha: 0.12)
                                  : const Color(
                                      0xFFE5E0F7,
                                    ).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                tip.illustrationPath,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: isDark
                                          ? AppColors.accentLavender
                                          : const Color(0xFF7A749E),
                                      size: 22,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tip.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (isToday)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB4A2)
                                              .withValues(
                                                alpha: isDark ? 0.25 : 0.15,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'BUGÜN',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                            color: isDark
                                                ? const Color(0xFFFFB4A2)
                                                : const Color(0xFFE8A0A0),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tip.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subtitleColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
