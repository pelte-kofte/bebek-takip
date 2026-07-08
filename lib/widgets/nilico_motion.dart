import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NilicoHapticType { none, selection, light, medium, success }

class NilicoMotion {
  NilicoMotion._();

  static const Duration pressDownDuration = Duration(milliseconds: 100);
  static const Duration pressUpDuration = Duration(milliseconds: 180);
  static const Duration chipDuration = Duration(milliseconds: 160);
  static const Duration tabItemDuration = Duration(milliseconds: 170);
  static const Duration entranceDuration = Duration(milliseconds: 180);
  static const Duration pageDuration = Duration(milliseconds: 240);
  static const Duration pageReverseDuration = Duration(milliseconds: 200);
  static const Duration sheetDuration = Duration(milliseconds: 360);
  static const Duration sheetReverseDuration = Duration(milliseconds: 280);
  static const Curve ease = Curves.easeOutCubic;
  static const Curve gentleSpring = Cubic(0.22, 1.0, 0.36, 1.04);
}

class NilicoHaptics {
  NilicoHaptics._();

  static Future<void> trigger(NilicoHapticType type) {
    switch (type) {
      case NilicoHapticType.none:
        return Future<void>.value();
      case NilicoHapticType.selection:
        return HapticFeedback.selectionClick();
      case NilicoHapticType.light:
        return HapticFeedback.lightImpact();
      case NilicoHapticType.medium:
        return HapticFeedback.mediumImpact();
      case NilicoHapticType.success:
        return HapticFeedback.lightImpact();
    }
  }
}

class NilicoPressable extends StatefulWidget {
  const NilicoPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.haptic = NilicoHapticType.none,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final NilicoHapticType haptic;
  final bool enabled;

  @override
  State<NilicoPressable> createState() => _NilicoPressableState();
}

class _NilicoPressableState extends State<NilicoPressable> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (!_interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_interactive || widget.onTap == null) return;
    NilicoHaptics.trigger(widget.haptic);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: _pressed
            ? NilicoMotion.pressDownDuration
            : NilicoMotion.pressUpDuration,
        curve: _pressed ? NilicoMotion.ease : NilicoMotion.gentleSpring,
        child: widget.child,
      ),
    );
  }
}

class NilicoEntrance extends StatefulWidget {
  const NilicoEntrance({
    super.key,
    required this.child,
    this.offsetY = 6,
  });

  final Widget child;
  final double offsetY;

  @override
  State<NilicoEntrance> createState() => _NilicoEntranceState();
}

class _NilicoEntranceState extends State<NilicoEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: NilicoMotion.entranceDuration,
      curve: NilicoMotion.ease,
      offset: _visible ? Offset.zero : Offset(0, widget.offsetY / 100),
      child: AnimatedOpacity(
        duration: NilicoMotion.entranceDuration,
        curve: NilicoMotion.ease,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

Route<T> buildNilicoPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool fullscreenDialog = false,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: NilicoMotion.pageDuration,
    reverseTransitionDuration: NilicoMotion.pageReverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: NilicoMotion.ease,
        reverseCurve: Curves.easeInCubic,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.035),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}

Future<T?> showNilicoModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    sheetAnimationStyle: const AnimationStyle(
      duration: NilicoMotion.sheetDuration,
      reverseDuration: NilicoMotion.sheetReverseDuration,
    ),
    builder: builder,
  );
}
