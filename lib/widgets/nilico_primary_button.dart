import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nilico_motion.dart';

class NilicoPrimaryButton extends StatefulWidget {
  const NilicoPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  @override
  State<NilicoPrimaryButton> createState() => _NilicoPrimaryButtonState();
}

class _NilicoPrimaryButtonState extends State<NilicoPrimaryButton> {
  bool _pressed = false;

  bool get _isEnabled => !widget.loading && widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_isEnabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.loading)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (widget.icon != null) ...[
          Icon(widget.icon, size: 24),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: AppTypography.button().copyWith(fontSize: 17),
        ),
      ],
    );

    final button = ElevatedButton(
      onPressed: widget.loading
          ? null
          : () {
              NilicoHaptics.trigger(NilicoHapticType.light);
              widget.onPressed?.call();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: buttonChild,
    );

    final wrappedButton = widget.fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: NilicoMotion.cardPressDuration,
        curve: NilicoMotion.ease,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.button(
              Theme.of(context).brightness == Brightness.dark,
            ),
          ),
          child: wrappedButton,
        ),
      ),
    );
  }
}
