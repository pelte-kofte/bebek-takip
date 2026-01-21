import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BackgroundPreset {
  home,
  add,
  activities,
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
    final bgColor = backgroundColor ??
        (isDark ? AppColors.bgDark : const Color(0xFFFFFBF5));

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          IgnorePointer(
            child: Stack(children: _buildShapes(isDark)),
          ),
          child,
        ],
      ),
    );
  }

  List<Widget> _buildShapes(bool isDark) {
    const peach = Color(0xFFFFB4A2);
    const lavender = Color(0xFFE5E0F7);
    const cream = Color(0xFFFFF8F0);

    final baseOpacity = isDark ? 0.05 : 0.07;

    switch (preset) {
      case BackgroundPreset.home:
        return [
          Positioned(
            top: -60,
            left: -50,
            child: _circle(260, lavender, baseOpacity),
          ),
          Positioned(
            bottom: -40,
            right: -50,
            child: _circle(220, peach, baseOpacity),
          ),
        ];

      case BackgroundPreset.add:
        return [
          Positioned(
            top: -50,
            right: -60,
            child: _circle(250, peach, 0.08),
          ),
          Positioned(
            bottom: -50,
            left: -60,
            child: _circle(230, lavender, baseOpacity),
          ),
        ];

      case BackgroundPreset.activities:
        return [
          Positioned(
            top: -50,
            right: -60,
            child: _circle(240, lavender, baseOpacity),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: _circle(220, lavender, baseOpacity),
          ),
        ];

      case BackgroundPreset.vaccines:
        return [
          Positioned(
            top: -60,
            left: -50,
            child: _circle(230, lavender, baseOpacity),
          ),
          Positioned(
            bottom: -50,
            right: -60,
            child: _circle(200, peach, 0.06),
          ),
        ];

      case BackgroundPreset.milestones:
        return [
          Positioned(
            top: -40,
            right: -40,
            child: _circle(280, peach, 0.08),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: _circle(260, lavender, baseOpacity),
          ),
        ];

      case BackgroundPreset.settings:
        return [
          Positioned(
            top: -60,
            right: -70,
            child: _circle(220, cream, 0.06),
          ),
          Positioned(
            bottom: -50,
            left: -60,
            child: _circle(200, lavender, 0.06),
          ),
        ];

      case BackgroundPreset.profile:
        return [
          Positioned(
            top: -50,
            right: -50,
            child: _circle(250, peach, baseOpacity),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: _circle(230, lavender, baseOpacity),
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
