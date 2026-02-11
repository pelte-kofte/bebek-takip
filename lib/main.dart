import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/milestones_screen.dart';
import 'screens/add_screen.dart';
import 'screens/vaccines_screen.dart';
import 'models/veri_yonetici.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/reminder_service.dart';

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static void goToRoot(Widget screen) {
    final state = key.currentState;
    if (state == null) return;
    state.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required before FirebaseAuth usage)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize VeriYonetici (loads all data into cache)
  await VeriYonetici.init();

  // Initialize timezones once for scheduled reminders
  ReminderService.initializeTimeZonesOnce();

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
      title: 'Nilico',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.key,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tr')],
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
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      HomeScreen(key: ValueKey('home_$_refreshKey'), onDataChanged: _refresh),
      ActivitiesScreen(refreshTrigger: _refreshKey),
      const SizedBox(),
      VaccinesScreen(key: ValueKey('vaccines_$_refreshKey')),
      MilestonesScreen(key: ValueKey('milestones_$_refreshKey')),
    ];

    final safeIndex = _selectedIndex == 2 ? 0 : _selectedIndex;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomBarHeight = 56.0 + bottomInset + 16.0;

    return Scaffold(
      body: SizedBox.expand(child: screens[safeIndex]),
      bottomNavigationBar: SizedBox(
        height: bottomBarHeight,
        child: Container(
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
                children: [
                  Expanded(
                    child: Center(
                      child: _buildNavItem(0, Icons.home_rounded, l10n.home),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        1,
                        Icons.bar_chart_rounded,
                        l10n.activities,
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: _buildAddButton())),
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        3,
                        Icons.vaccines_outlined,
                        l10n.vaccines,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildNavItem(
                        4,
                        Icons.emoji_events_rounded,
                        l10n.memories,
                      ),
                    ),
                  ),
                ],
              ),
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
