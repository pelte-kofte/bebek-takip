import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import '../widgets/nilico_motion.dart';
import 'allergies_screen.dart';
import 'growth_screen.dart';
import 'ilaclar_screen.dart';
import 'vaccines_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  List<String> _tabLabels(BuildContext context, AppLocalizations l10n) {
    return <String>[
      l10n.growth,
      l10n.vaccines,
      l10n.medications,
      l10n.allergiesTitle,
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
                      _HealthTabPage(child: GrowthScreen(embedded: true)),
                      _HealthTabPage(child: VaccinesScreen(embedded: true)),
                      _HealthTabPage(child: IlaclarScreen(embedded: true)),
                      _HealthTabPage(child: AllergiesScreen(embedded: true)),
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

class _HealthTabPage extends StatefulWidget {
  const _HealthTabPage({required this.child});

  final Widget child;

  @override
  State<_HealthTabPage> createState() => _HealthTabPageState();
}

class _HealthTabPageState extends State<_HealthTabPage>
    with AutomaticKeepAliveClientMixin<_HealthTabPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _HealthTabCapsules extends StatelessWidget {
  const _HealthTabCapsules({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return _HealthSegmentedControl(labels: labels);
  }
}

class _HealthSegmentedControl extends StatelessWidget {
  const _HealthSegmentedControl({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final animation = controller.animation;

    if (animation == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.bgDarkCard.withValues(alpha: 0.34)
        : AppColors.paperMuted.withValues(alpha: 0.82);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppColors.borderSoft.withValues(alpha: 0.32);

    return SizedBox(
      height: 36,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 0.55),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final currentIndex = controller.index;
                  final indicatorLeft = animation.value * segmentWidth;

                  return Stack(
                    children: [
                      Positioned(
                        left: indicatorLeft,
                        top: 2,
                        width: segmentWidth,
                        height: 32,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : AppColors.controlActive,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.white.withValues(alpha: 0.85),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.16)
                                      : const Color(
                                          0x142F221C,
                                        ).withValues(alpha: 0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List<Widget>.generate(labels.length, (index) {
                          final distance = (animation.value - index).abs();
                          final selectedness = (1 - distance).clamp(0.0, 1.0);
                          final isActive = currentIndex == index;

                          return Expanded(
                            child: _HealthSegment(
                              label: labels[index],
                              selectedness: selectedness,
                              isActive: isActive,
                              onTap: () {
                                if (controller.index != index) {
                                  NilicoHaptics.trigger(
                                    NilicoHapticType.selection,
                                  );
                                }
                                controller.animateTo(index);
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HealthSegment extends StatelessWidget {
  const _HealthSegment({
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
      isDark
          ? AppColors.textSecondaryDark.withValues(alpha: 0.82)
          : AppColors.textSecondary.withValues(alpha: 0.96),
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      selectedness,
    )!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
              letterSpacing: -0.2,
              height: 1.0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
