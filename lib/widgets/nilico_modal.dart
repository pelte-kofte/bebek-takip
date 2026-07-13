import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const Color nilicoDestructiveColor = Color(0xFFB85C4A);

class NilicoDialog extends StatelessWidget {
  const NilicoDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final Widget title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.bgDarkCard : AppColors.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      title: DefaultTextStyle(
        style: AppTypography.dialogTitle(context),
        child: title,
      ),
      content: DefaultTextStyle(
        style: AppTypography.dialogBody(context),
        child: content,
      ),
      actions: actions,
    );
  }
}

class NilicoDialogAction extends StatelessWidget {
  const NilicoDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = destructive
        ? (isDark ? const Color(0xFFE09A8D) : nilicoDestructiveColor)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: AppTypography.dialogAction(context),
      ),
      child: loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Text(
              label,
              style: AppTypography.dialogAction(context).copyWith(color: color),
            ),
    );
  }
}

class NilicoSheetHandle extends StatelessWidget {
  const NilicoSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.textSecondary.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class NilicoSheetFrame extends StatelessWidget {
  const NilicoSheetFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 20),
    this.showHandle = true,
    this.safeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showHandle;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const NilicoSheetHandle(),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
    if (safeArea) {
      content = SafeArea(top: false, child: content);
    }
    return Material(
      color: isDark ? AppColors.bgDarkCard : AppColors.paper,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class NilicoSheetHeader extends StatelessWidget {
  const NilicoSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.sheetTitle(context)),
              if (subtitle case final subtitle? when subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall(context)),
              ],
            ],
          ),
        ),
        if (onClose != null) ...[
          const SizedBox(width: 12),
          IconButton(
            onPressed: onClose,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ],
    );
  }
}

class NilicoActionSheetRow extends StatelessWidget {
  const NilicoActionSheetRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = destructive
        ? (isDark ? const Color(0xFFE09A8D) : nilicoDestructiveColor)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: color.withValues(alpha: 0.82)),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body(context).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NilicoPickerSheet extends StatelessWidget {
  const NilicoPickerSheet({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    required this.child,
    this.title,
    this.contentHeight = 232,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Widget child;
  final String? title;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    return NilicoSheetFrame(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: contentHeight,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryColor,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(
                        cancelLabel,
                        style: AppTypography.dialogAction(
                          context,
                        ).copyWith(color: secondaryColor),
                      ),
                    ),
                  ),
                ),
                if (title != null)
                  Flexible(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.compactTitle(context),
                    ),
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onConfirm,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(
                        confirmLabel,
                        style: AppTypography.dialogAction(
                          context,
                        ).copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
