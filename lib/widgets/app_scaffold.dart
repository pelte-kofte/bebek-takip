import 'package:flutter/material.dart';
import 'decorative_background.dart';

/// Centralized scaffold with consistent styling
/// Wraps DecorativeBackground and provides common structure
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final BackgroundPreset preset;
  final bool useSafeArea;
  final EdgeInsets? padding;

  const AppScaffold({
    super.key,
    required this.body,
    required this.preset,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      preset: preset,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: useSafeArea
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
  final BackgroundPreset preset;
  final bool useSafeArea;
  final EdgeInsets? padding;

  const AppContainer({
    super.key,
    required this.child,
    required this.preset,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      preset: preset,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: useSafeArea
            ? SafeArea(
                child: padding != null
                    ? Padding(padding: padding!, child: child)
                    : child,
              )
            : padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
