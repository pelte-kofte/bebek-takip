import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/veri_yonetici.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'login_entry_screen.dart';

// ONBOARDING SCREEN
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(AppLocalizations l10n) => [
    OnboardingData(
      icon: 'assets/onboarding/nursing.png',
      title: l10n.feedingTracker,
      description: l10n.feedingTrackerDesc,
      color: AppColors.accentBlue,
      bgColor: const Color(0xFFEFF6FF),
    ),
    OnboardingData(
      icon: 'assets/onboarding/sleeping.png',
      title: l10n.sleepPatterns,
      description: l10n.sleepPatternsDesc,
      color: AppColors.accentLavender,
      bgColor: const Color(0xFFF5F3FF),
    ),
    OnboardingData(
      icon: 'assets/onboarding/growing.png',
      title: l10n.growthCharts,
      description: l10n.growthChartsDesc,
      color: AppColors.accentGreen,
      bgColor: const Color(0xFFF0FDF4),
    ),
    OnboardingData(
      icon: 'assets/onboarding/cuddle.png',
      title: l10n.preciousMemories,
      description: l10n.preciousMemoriesDesc,
      color: AppColors.primary,
      bgColor: const Color(0xFFFFF1F2),
    ),
    OnboardingData(
      icon: 'assets/onboarding/onboarding_daily_rhythm.png',
      title: l10n.dailyRhythm,
      description: l10n.dailyRhythmDesc,
      color: AppColors.accentPeach,
      bgColor: const Color(0xFFFFF8F0),
    ),
  ];

  void _nextPage(int pagesLength) {
    if (_currentPage < pagesLength - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(showPremiumDiscoveryAfterLogin: true);
    }
  }

  void _completeOnboarding({
    bool showPremiumDiscoveryAfterLogin = false,
  }) async {
    await VeriYonetici.setFirstLaunchComplete();

    if (!mounted) return;

    AppNavigator.goToRoot(
      LoginEntryScreen(
        showPremiumDiscoveryAfterLogin: showPremiumDiscoveryAfterLogin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(l10n);

    return Scaffold(
      backgroundColor: pages[_currentPage].bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress dots
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? pages[_currentPage].color
                              : pages[_currentPage].color.withValues(
                                  alpha: 0.3,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Skip
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      l10n.skip,
                      style: TextStyle(
                        color: pages[_currentPage].color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  HapticFeedback.selectionClick();
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index]);
                },
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _nextPage(pages.length);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == pages.length - 1
                            ? l10n.startYourJourney
                            : l10n.continueBtn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Decorative illustration (top area)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.15),
                  blurRadius: 60,
                  spreadRadius: 10,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(data.icon, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 56),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppColors.textSecondaryLight,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final Color bgColor;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.bgColor,
  });
}
