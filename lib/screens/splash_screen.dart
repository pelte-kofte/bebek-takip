import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/veri_yonetici.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../widgets/decorative_background.dart';
import '../l10n/app_localizations.dart';
import 'login_entry_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _logoScale;
  late Animation<double> _fadeIn;
  late Animation<double> _float;
  bool _canTap = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _float = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
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
    _logoController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToNextScreen,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: DecorativeBackground(
          preset: BackgroundPreset.home,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Decorative illustration with float animation
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _floatController,
                    ]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _float.value),
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 60,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 25),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/icons/illustration/parents.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // App Title
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '🌱 ',
                                  style: TextStyle(fontSize: 32),
                                ),
                                Text(
                                  l10n.appName,
                                  style: AppTypography.h1(context).copyWith(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),

                            // Tagline
                            Text(
                              l10n.tagline,
                              style: AppTypography.body(context),
                            ),

                            SizedBox(height: AppSpacing.sm),

                            // Features Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureChip('✓ ${l10n.freeForever}'),
                                const SizedBox(width: 16),
                                _buildFeatureChip('✓ ${l10n.securePrivate}'),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Tap to continue
                  FadeTransition(
                    opacity: _fadeIn,
                    child: AnimatedOpacity(
                      opacity: _canTap ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.tapToStart,
                                      style: TextStyle(
                                        fontSize: 16,
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
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryLight,
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
      icon: 'assets/icons/illustration/nursing.png',
      title: l10n.feedingTracker,
      description: l10n.feedingTrackerDesc,
      color: AppColors.accentBlue,
      bgColor: const Color(0xFFEFF6FF),
    ),
    OnboardingData(
      icon: 'assets/icons/illustration/sleeping.png',
      title: l10n.sleepPatterns,
      description: l10n.sleepPatternsDesc,
      color: AppColors.accentLavender,
      bgColor: const Color(0xFFF5F3FF),
    ),
    OnboardingData(
      icon: 'assets/icons/illustration/growing.png',
      title: l10n.growthCharts,
      description: l10n.growthChartsDesc,
      color: AppColors.accentGreen,
      bgColor: const Color(0xFFF0FDF4),
    ),
    OnboardingData(
      icon: 'assets/icons/illustration/cuddle.png',
      title: l10n.preciousMemories,
      description: l10n.preciousMemoriesDesc,
      color: AppColors.primary,
      bgColor: const Color(0xFFFFF1F2),
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
