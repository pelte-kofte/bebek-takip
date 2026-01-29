import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BackgroundPreset {
  home,
  add,
  activities,
  growth,
  vaccines,
  milestones,
  settings,
  profile,
}

class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final BackgroundPreset preset;
  final Color? backgroundColor;

  const DecorativeBackground({
    super.key,
    required this.child,
    this.preset = BackgroundPreset.home,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.bgDark : const Color(0xFFFFFBF5));

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          IgnorePointer(child: Stack(children: _buildShapes(isDark))),
          child,
        ],
      ),
    );
  }

  List<Widget> _buildShapes(bool isDark) {
    const peach = Color(0xFFFFB4A2);
    const lavender = Color(0xFFE5E0F7);
    const cream = Color(0xFFFFF8F0);

    // Visible in light mode, subtle in dark mode
    final primary = isDark ? 0.08 : 0.45;
    final secondary = isDark ? 0.06 : 0.35;

    switch (preset) {
      case BackgroundPreset.home:
        return [
          Positioned(
            top: -40,
            left: -30,
            child: _circle(300, lavender, primary),
          ),
          Positioned(
            bottom: -20,
            right: -30,
            child: _circle(280, peach, secondary),
          ),
        ];

      case BackgroundPreset.add:
        return [
          Positioned(top: -50, right: -60, child: _circle(250, peach, 0.08)),
          Positioned(
            bottom: -50,
            left: -60,
            child: _circle(230, lavender, isDark ? 0.05 : 0.07),
          ),
        ];

      case BackgroundPreset.activities:
        return [
          Positioned(
            top: -30,
            right: -40,
            child: _circle(280, lavender, primary),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _circle(260, peach, secondary),
          ),
        ];

      case BackgroundPreset.growth:
        return [
          Positioned(
            top: -40,
            right: -30,
            child: _circle(280, peach, secondary),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _circle(260, lavender, primary),
          ),
        ];

      case BackgroundPreset.vaccines:
        return [
          Positioned(
            top: -30,
            left: -20,
            child: _circle(300, lavender, primary),
          ),
          Positioned(
            bottom: -60,
            right: -30,
            child: _circle(280, peach, secondary),
          ),
        ];

      case BackgroundPreset.milestones:
        return [
          Positioned(
            top: -30,
            right: -30,
            child: _circle(300, peach, secondary),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _circle(280, lavender, primary),
          ),
        ];

      case BackgroundPreset.settings:
        return [
          Positioned(
            top: -50,
            right: -50,
            child: _circle(240, cream, isDark ? 0.06 : 0.15),
          ),
          Positioned(
            bottom: -40,
            left: -50,
            child: _circle(220, lavender, isDark ? 0.06 : 0.15),
          ),
        ];

      case BackgroundPreset.profile:
        return [
          Positioned(
            top: -40,
            right: -40,
            child: _circle(270, peach, secondary),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: _circle(250, lavender, primary),
          ),
        ];
    }
  }

  Widget _circle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

// Legacy alias for backward compatibility
typedef BackgroundVariant = BackgroundPreset;
