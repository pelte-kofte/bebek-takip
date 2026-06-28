import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum NilicoSectionHeaderMode { eyebrow, titleRow }

class NilicoSectionHeader extends StatelessWidget {
  const NilicoSectionHeader({
    super.key,
    required this.title,
    this.mode = NilicoSectionHeaderMode.titleRow,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.subtitleColor,
  });

  final String title;
  final NilicoSectionHeaderMode mode;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case NilicoSectionHeaderMode.eyebrow:
        return Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: titleColor ?? AppColors.textSecondaryLight,
            letterSpacing: 1.0,
          ),
        );
      case NilicoSectionHeaderMode.titleRow:
        final defaultTitleColor = titleColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight);
        final defaultSubtitleColor = subtitleColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h3(
                      context,
                    ).copyWith(fontSize: 17, color: defaultTitleColor),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall(
                        context,
                      ).copyWith(color: defaultSubtitleColor),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        );
    }
  }
}
