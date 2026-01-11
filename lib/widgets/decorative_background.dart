import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BackgroundVariant {
  splash, // Full decorative with large blobs
  home, // Subtle decoration for home screen
  subtle, // Very minimal decoration
  none, // No decoration, just solid color
}

/// Reusable decorative background with circular blobs
/// Provides consistent visual style across screens
class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final BackgroundVariant variant;
  final Color? backgroundColor;

  const DecorativeBackground({
    super.key,
    required this.child,
    this.variant = BackgroundVariant.splash,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.bgDark : AppColors.bgLight);

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          // Decorative blobs based on variant
          if (variant != BackgroundVariant.none) ..._buildBlobs(isDark),

          // Main content
          child,
        ],
      ),
    );
  }

  List<Widget> _buildBlobs(bool isDark) {
    switch (variant) {
      case BackgroundVariant.splash:
        return [
          // Top-right green blob
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(isDark ? 0.15 : 0.3),
              ),
            ),
          ),
          // Bottom-left pink blob
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(isDark ? 0.2 : 0.4),
              ),
            ),
          ),
        ];

      case BackgroundVariant.home:
        return [
          // Top-right subtle blob
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue.withOpacity(isDark ? 0.1 : 0.2),
              ),
            ),
          ),
          // Bottom-left subtle blob
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPeach.withOpacity(isDark ? 0.1 : 0.2),
              ),
            ),
          ),
        ];

      case BackgroundVariant.subtle:
        return [
          // Single top blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.08 : 0.15),
              ),
            ),
          ),
        ];

      case BackgroundVariant.none:
        return [];
    }
  }
}
