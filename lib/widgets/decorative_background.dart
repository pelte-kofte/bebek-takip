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
    const lavenderPrimary = AppColors.lavenderMist;
    const lavenderSecondary = AppColors.accentLavender;
    final blobOpacity = isDark ? 0.055 : 0.115;

    switch (preset) {
      case BackgroundPreset.home:
        return [
          Positioned(
            top: -40,
            left: -30,
            child: _circle(300, lavenderPrimary, blobOpacity),
          ),
          Positioned(
            bottom: -20,
            right: -30,
            child: _circle(280, lavenderSecondary, blobOpacity),
          ),
        ];

      case BackgroundPreset.add:
        return [
          Positioned(
            top: -50,
            right: -60,
            child: _circle(250, lavenderSecondary, blobOpacity),
          ),
          Positioned(
            bottom: -50,
            left: -60,
            child: _circle(230, lavenderPrimary, blobOpacity),
          ),
        ];

      case BackgroundPreset.activities:
        return [
          Positioned(
            top: -30,
            right: -40,
            child: _circle(280, lavenderPrimary, blobOpacity),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _circle(260, lavenderSecondary, blobOpacity),
          ),
        ];

      case BackgroundPreset.growth:
        return [
          Positioned(
            top: -40,
            right: -30,
            child: _circle(280, lavenderSecondary, blobOpacity),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _circle(260, lavenderPrimary, blobOpacity),
          ),
        ];

      case BackgroundPreset.vaccines:
        return [
          Positioned(
            top: -30,
            left: -20,
            child: _circle(300, lavenderPrimary, blobOpacity),
          ),
          Positioned(
            bottom: -60,
            right: -30,
            child: _circle(280, lavenderSecondary, blobOpacity),
          ),
        ];

      case BackgroundPreset.milestones:
        return [
          Positioned(
            top: -30,
            right: -30,
            child: _circle(300, lavenderSecondary, blobOpacity),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _circle(280, lavenderPrimary, blobOpacity),
          ),
        ];

      case BackgroundPreset.settings:
        return [
          Positioned(
            top: -50,
            right: -50,
            child: _circle(240, lavenderSecondary, blobOpacity),
          ),
          Positioned(
            bottom: -40,
            left: -50,
            child: _circle(220, lavenderPrimary, blobOpacity),
          ),
        ];

      case BackgroundPreset.profile:
        return [
          Positioned(
            top: -40,
            right: -40,
            child: _circle(270, lavenderSecondary, blobOpacity),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: _circle(250, lavenderPrimary, blobOpacity),
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
