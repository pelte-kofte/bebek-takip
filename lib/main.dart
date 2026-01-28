import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/milestones_screen.dart';
import 'screens/add_screen.dart';
import 'screens/vaccines_screen.dart';
import 'models/veri_yonetici.dart';
import 'models/dil.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize VeriYonetici (loads all data into cache)
  await VeriYonetici.init();

  runApp(const BabyTrackerApp());
}

class BabyTrackerApp extends StatefulWidget {
  const BabyTrackerApp({super.key});

  // ignore: library_private_types_in_public_api
  static _BabyTrackerAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_BabyTrackerAppState>();

  @override
  State<BabyTrackerApp> createState() => _BabyTrackerAppState();
}

class _BabyTrackerAppState extends State<BabyTrackerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = VeriYonetici.isDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    await VeriYonetici.setDarkMode(_themeMode == ThemeMode.dark);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bebek Takip',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddScreen(onSaved: _refresh),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(key: ValueKey('home_$_refreshKey'), onDataChanged: _refresh),
      ActivitiesScreen(refreshTrigger: _refreshKey),
      const SizedBox(),
      VaccinesScreen(key: ValueKey('vaccines_$_refreshKey')),
      MilestonesScreen(key: ValueKey('milestones_$_refreshKey')),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkCard : AppColors.bgLightCard,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Dil.navAnaSayfa),
                _buildNavItem(1, Icons.bar_chart_rounded, Dil.navAktiviteler),
                _buildAddButton(),
                _buildNavItem(3, Icons.vaccines_outlined, Dil.asilar),
                _buildNavItem(4, Icons.emoji_events_rounded, Dil.navGelisim),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
