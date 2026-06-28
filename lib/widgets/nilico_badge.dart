import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nilico_motion.dart';

enum NilicoBadgeVariant { status, type, premium, inactive, success }

class NilicoBadge extends StatelessWidget {
  const NilicoBadge({super.key, required this.label, required this.variant});

  final String label;
  final NilicoBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(variant);

    return AnimatedContainer(
      duration: NilicoMotion.chipDuration,
      curve: NilicoMotion.ease,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedDefaultTextStyle(
        duration: NilicoMotion.chipDuration,
        curve: NilicoMotion.ease,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: palette.foreground,
        ),
        child: Text(label),
      ),
    );
  }

  _NilicoBadgePalette _paletteFor(NilicoBadgeVariant variant) {
    switch (variant) {
      case NilicoBadgeVariant.status:
        return _NilicoBadgePalette(
          background: AppColors.primary.withValues(alpha: 0.15),
          foreground: AppColors.primary,
        );
      case NilicoBadgeVariant.type:
        return const _NilicoBadgePalette(
          background: Color(0xFFE5E0F7),
          foreground: Color(0xFF6B5B95),
        );
      case NilicoBadgeVariant.premium:
        return const _NilicoBadgePalette(
          background: Color(0xFFE5E0F7),
          foreground: Color(0xFF9C88CC),
        );
      case NilicoBadgeVariant.inactive:
        const color = Color(0xFF9A8F88);
        return _NilicoBadgePalette(
          background: color.withValues(alpha: 0.12),
          foreground: color,
        );
      case NilicoBadgeVariant.success:
        const color = Color(0xFF4CA984);
        return _NilicoBadgePalette(
          background: color.withValues(alpha: 0.12),
          foreground: color,
        );
    }
  }
}

class _NilicoBadgePalette {
  const _NilicoBadgePalette({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
