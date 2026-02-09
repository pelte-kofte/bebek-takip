import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/veri_yonetici.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'login_entry_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  bool _canTap = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });

    // 2 saniye sonra dokunmaya izin ver
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _canTap = true);
      }
    });
  }

  void _goToNextScreen() {
    if (!_canTap) return;

    HapticFeedback.mediumImpact();

    final isFirstLaunch = VeriYonetici.isFirstLaunch();
    final showLoginEntry = !VeriYonetici.isLoginEntryShown();

    Widget nextScreen;
    if (isFirstLaunch) {
      nextScreen = const OnboardingScreen();
    } else if (showLoginEntry) {
      nextScreen = const LoginEntryScreen();
    } else {
      nextScreen = const MainScreen();
    }

    AppNavigator.goToRoot(nextScreen);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _goToNextScreen,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen hero image
            Image.asset('assets/onboarding/welcome.png', fit: BoxFit.cover),

            // Bottom gradient overlay for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Content overlay — bottom-aligned
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand + copy
                        FadeTransition(
                          opacity: _fadeIn,
                          child: Column(
                            children: [
                              // App name (text only, no emoji)
                              Text(
                                l10n.appName,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Tagline
                              Text(
                                l10n.tagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Feature chips (Wrap for small screens)
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildFeatureChip('✓ ${l10n.freeForever}'),
                                  _buildFeatureChip('✓ ${l10n.securePrivate}'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // CTA button
                        FadeTransition(
                          opacity: _fadeIn,
                          child: AnimatedOpacity(
                            opacity: _canTap ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.tapToStart,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

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
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await VeriYonetici.setFirstLaunchComplete();

    // Show login entry screen if not shown yet
    final showLoginEntry = !VeriYonetici.isLoginEntryShown();

    if (!mounted) return;

    AppNavigator.goToRoot(
      showLoginEntry ? const LoginEntryScreen() : const MainScreen(),
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
                              : pages[_currentPage].color.withOpacity(0.3),
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
                    shadowColor: Colors.black.withOpacity(0.2),
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
                  color: data.color.withOpacity(0.15),
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
