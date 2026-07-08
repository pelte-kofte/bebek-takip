import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import '../widgets/nilico_motion.dart';
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
          : 'Meals',
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
    return _HealthTabScroller(labels: labels);
  }
}

class _HealthTabScroller extends StatefulWidget {
  const _HealthTabScroller({required this.labels});

  final List<String> labels;

  @override
  State<_HealthTabScroller> createState() => _HealthTabScrollerState();
}

class _HealthTabScrollerState extends State<_HealthTabScroller> {
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _pillKeys = List<GlobalKey>.generate(
    widget.labels.length,
    (_) => GlobalKey(),
  );
  int _lastEnsuredIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureSelectedVisible(int index) {
    if (_lastEnsuredIndex == index) return;
    _lastEnsuredIndex = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final pillContext = _pillKeys[index].currentContext;
      if (pillContext == null) return;

      Scrollable.ensureVisible(
        pillContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final animation = controller.animation;

    if (animation == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : const Color(0xFFF4F1EC).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF0E9E2),
          width: 0.6,
        ),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final currentIndex = controller.index;
          _ensureSelectedVisible(currentIndex);

          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                children: List<Widget>.generate(widget.labels.length, (index) {
                  final distance = (animation.value - index).abs();
                  final selectedness = (1 - distance).clamp(0.0, 1.0);
                  final isActive = currentIndex == index;

                  return Padding(
                    key: _pillKeys[index],
                    padding: EdgeInsets.only(
                      right: index == widget.labels.length - 1 ? 0 : 4,
                    ),
                    child: _HealthTabPill(
                      label: widget.labels[index],
                      selectedness: selectedness,
                      isActive: isActive,
                      onTap: () {
                        if (controller.index != index) {
                          NilicoHaptics.trigger(NilicoHapticType.selection);
                        }
                        controller.animateTo(index);
                      },
                    ),
                  );
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
    required this.selectedness,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final double selectedness;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Color.lerp(
      isDark ? Colors.white.withValues(alpha: 0.72) : const Color(0xFF7B7671),
      isDark ? Colors.white : const Color(0xFF4C4844),
      selectedness,
    )!;
    final borderColor = Color.lerp(
      Colors.transparent,
      isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE8E1DA),
      selectedness,
    )!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: NilicoMotion.chipDuration,
          curve: NilicoMotion.ease,
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.transparent,
              isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.84),
              selectedness,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.7),
          ),
          child: AnimatedDefaultTextStyle(
            duration: NilicoMotion.chipDuration,
            curve: NilicoMotion.ease,
            style: AppTypography.bodySmall(context).copyWith(
              color: textColor,
              fontSize: 12.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.15,
              height: 1.1,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
