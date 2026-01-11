import 'package:flutter/material.dart';
import 'decorative_background.dart';
import '../theme/app_theme.dart';

/// Centralized scaffold with consistent styling
/// Wraps DecorativeBackground and provides common structure
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final BackgroundVariant backgroundVariant;
  final bool useSafeArea;
  final EdgeInsets? padding;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundVariant = BackgroundVariant.home,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: DecorativeBackground(
        variant: backgroundVariant,
        child: useSafeArea
            ? SafeArea(
                child: padding != null
                    ? Padding(padding: padding!, child: body)
                    : body,
              )
            : padding != null
                ? Padding(padding: padding!, child: body)
                : body,
      ),
    );
  }
}

/// Simple wrapper for screens that don't need AppBar or bottom nav
class AppContainer extends StatelessWidget {
  final Widget child;
  final BackgroundVariant backgroundVariant;
  final bool useSafeArea;
  final EdgeInsets? padding;

  const AppContainer({
    super.key,
    required this.child,
    this.backgroundVariant = BackgroundVariant.home,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      variant: backgroundVariant,
      child: useSafeArea
          ? SafeArea(
              child: padding != null
                  ? Padding(padding: padding!, child: child)
                  : child,
            )
          : padding != null
              ? Padding(padding: padding!, child: child)
              : child,
    );
  }
}
