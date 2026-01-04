import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/veri_yonetici.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _float = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });

    // 1.5 saniye sonra dokunmaya izin ver
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _canTap = true);
      }
    });
  }

  void _goToNextScreen() {
    if (!_canTap) return;
    
    HapticFeedback.mediumImpact();
    
    final isFirstLaunch = VeriYonetici.isFirstLaunch();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isFirstLaunch 
            ? const OnboardingScreen() 
            : const MainScreen(),
      ),
    );
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF8F0),
                Color(0xFFFFF0F5),
                Color(0xFFE8F5E9),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Floating decorations
                _buildFloatingDecoration(50, 100, '🌸', 20),
                _buildFloatingDecoration(300, 150, '⭐', 16),
                _buildFloatingDecoration(80, 500, '🌙', 18),
                _buildFloatingDecoration(280, 600, '💫', 14),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      
                      // Logo with float animation
                      AnimatedBuilder(
                        animation: Listenable.merge([_logoController, _floatController]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _float.value),
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8F0),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color(0xFFFFB5BA),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFB5BA).withOpacity(0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('👶', style: TextStyle(fontSize: 70)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // App name
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          children: [
                            Text(
                              'Bebek Takip',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE88B8C),
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFFFB5BA).withOpacity(0.5),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9B8E8).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '✨ Her anı birlikte büyütelim ✨',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9B8BB8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 2),
                      
                      // Tap to continue text
                      FadeTransition(
                        opacity: _fadeIn,
                        child: AnimatedOpacity(
                          opacity: _canTap ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              const _LoadingDots(),
                              const SizedBox(height: 16),
                              Text(
                                'Devam etmek için dokun',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(),
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

  Widget _buildFloatingDecoration(double left, double top, String emoji, double size) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_float.value * 0.5, _float.value),
            child: Opacity(
              opacity: 0.6,
              child: Text(emoji, style: TextStyle(fontSize: size)),
            ),
          );
        },
      ),
    );
  }
}

// Loading dots animation
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animation = (_controller.value + delay) % 1.0;
            final scale = 0.5 + (animation < 0.5 ? animation : 1 - animation) * 1.0;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: [
                      const Color(0xFFFFB5BA),
                      const Color(0xFFC9B8E8),
                      const Color(0xFFA8E6CF),
                    ][index],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ONBOARDING SCREEN - Storybook Style
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: '🤱',
      title: 'Beslenmeyi Takip Edin',
      description: 'Emzirme sürelerini, biberon miktarlarını kolayca kaydedin. Sol ve sağ meme takibi ile detaylı istatistikler alın.',
      color: const Color(0xFFFFB5BA),
      bgColor: const Color(0xFFFFF0F3),
      decoration: '🍼',
    ),
    OnboardingData(
      icon: '😴',
      title: 'Uyku Düzenini İzleyin',
      description: 'Bebeğinizin uyku saatlerini kaydedin. Sağlıklı uyku alışkanlıkları geliştirmesine yardımcı olun.',
      color: const Color(0xFFC9B8E8),
      bgColor: const Color(0xFFF5F0FF),
      decoration: '🌙',
    ),
    OnboardingData(
      icon: '📊',
      title: 'Büyümeyi Görün',
      description: 'Boy ve kilo değişimlerini grafiklerle takip edin. Haftalık ve aylık detaylı raporlar oluşturun.',
      color: const Color(0xFFA8E6CF),
      bgColor: const Color(0xFFF0FFF4),
      decoration: '🌱',
    ),
    OnboardingData(
      icon: '💕',
      title: 'Anıları Saklayın',
      description: 'İlk adım, ilk söz, ilk gülüş... Tüm özel anları kaydedin ve sonsuza dek saklayın.',
      color: const Color(0xFFFFD4A3),
      bgColor: const Color(0xFFFFF8F0),
      decoration: '⭐',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    VeriYonetici.setFirstLaunchComplete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[_currentPage].bgColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _pages[_currentPage].color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${_pages.length}',
                        style: TextStyle(
                          color: _pages[_currentPage].color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Atla →',
                        style: TextStyle(
                          color: _pages[_currentPage].color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    HapticFeedback.selectionClick();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 28 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].color
                            : _pages[_currentPage].color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _pages[_currentPage].color.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _nextPage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1 ? 'Başlayalım!' : 'Devam',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1 
                              ? Icons.celebration 
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative element
          Text(data.decoration, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          
          // Icon with storybook style frame
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.color.withOpacity(0.3),
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.color.withOpacity(0.1),
                ),
              ),
              // Inner circle
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: data.color,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    data.icon,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Title with underline decoration
          Column(
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: data.color.withOpacity(0.9),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Description in a card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: data.color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
          ),
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
  final String decoration;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.bgColor,
    this.decoration = '✨',
  });
}