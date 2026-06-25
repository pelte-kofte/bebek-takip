import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import 'allergies_screen.dart';
import 'baby_meals_screen.dart';
import 'ilaclar_screen.dart';
import 'vaccines_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  List<String> _tabLabels(BuildContext context, AppLocalizations l10n) {
    return <String>[
      l10n.allergiesTitle,
      l10n.vaccines,
      l10n.medications,
      Localizations.localeOf(context).languageCode == 'tr'
          ? 'Ek Gıda'
          : 'Baby Meals',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecorativeBackground(
      preset: BackgroundPreset.vaccines,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: _HealthTabCapsules(labels: _tabLabels(context, l10n)),
                ),
                const SizedBox(height: 10),
                const Expanded(
                  child: TabBarView(
                    children: [
                      AllergiesScreen(embedded: true),
                      VaccinesScreen(embedded: true),
                      IlaclarScreen(embedded: true),
                      BabyMealsScreen(embedded: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthTabCapsules extends StatelessWidget {
  const _HealthTabCapsules({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final animation = controller.animation;

    if (animation == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 58,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final animationValue = animation.value;
          final currentIndex = controller.index;
          const overlap = 18.0;

          final widths = labels
              .map((label) => math.max(112.0, 52.0 + (label.length * 7.2)))
              .toList(growable: false);
          final totalWidth =
              widths.fold<double>(0, (sum, width) => sum + width) -
              (overlap * (labels.length - 1));

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              width: totalWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: List<Widget>.generate(labels.length, (index) {
                  final distance = (animationValue - index).abs();
                  final selectedness = (1 - distance).clamp(0.0, 1.0);
                  final isActive = currentIndex == index;
                  final left = widths
                          .take(index)
                          .fold<double>(0, (sum, width) => sum + width) -
                      (overlap * index);

                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    child: _HealthTabPill(
                      label: labels[index],
                      width: widths[index],
                      selectedness: selectedness,
                      isActive: isActive,
                      onTap: () => controller.animateTo(index),
                    ),
                  );
                })
                  ..sort((a, b) {
                    final aPositioned = a as Positioned;
                    final bPositioned = b as Positioned;
                    final aPill = aPositioned.child as _HealthTabPill;
                    final bPill = bPositioned.child as _HealthTabPill;
                    return aPill.isActive == bPill.isActive
                        ? 0
                        : (aPill.isActive ? 1 : -1);
                  }),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HealthTabPill extends StatelessWidget {
  const _HealthTabPill({
    required this.label,
    required this.width,
    required this.selectedness,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final double width;
  final double selectedness;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = Color.lerp(
      isDark ? AppColors.bgDarkCard : const Color(0xFFFFFBF7),
      isDark ? const Color(0xFF6F628A) : const Color(0xFFE7E0F6),
      selectedness,
    )!;
    final textColor = Color.lerp(
      isDark ? AppColors.textSecondaryDark : const Color(0xFF7B6B67),
      isDark ? Colors.white : const Color(0xFF55476B),
      selectedness,
    )!;
    final borderColor = Color.lerp(
      isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFE7DED8).withValues(alpha: 0.9),
      isDark ? const Color(0xFF8F80AB) : const Color(0xFFD7CCE9),
      selectedness,
    )!;

    return Material(
      color: Colors.transparent,
      elevation: isActive ? 0 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: width,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(
                        alpha: 0.14 + (0.10 * selectedness),
                      )
                    : const Color(0xFFB5A6D3).withValues(
                        alpha: 0.06 + (0.16 * selectedness),
                      ),
                blurRadius: 12 + (8 * selectedness),
                offset: Offset(0, 4 + (math.max(0, selectedness) * 4)),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: AppTypography.bodySmall(context).copyWith(
              color: textColor,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
