import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import 'allergies_screen.dart';
import 'ilaclar_screen.dart';
import 'vaccines_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecorativeBackground(
      preset: BackgroundPreset.vaccines,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.bgDarkCard
                          : Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF866F65),
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: AppTypography.label(context),
                      unselectedLabelStyle: AppTypography.bodySmall(context),
                      tabs: [
                        Tab(text: l10n.allergiesTitle),
                        Tab(text: l10n.vaccines),
                        Tab(text: l10n.medications),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Expanded(
                  child: TabBarView(
                    children: [
                      AllergiesScreen(embedded: true),
                      VaccinesScreen(embedded: true),
                      IlaclarScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
