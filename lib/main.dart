import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/milestones_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_screen.dart';
import 'models/veri_yonetici.dart';
import 'models/dil.dart';
import '../models/ikonlar.dart';

void main() {
  runApp(const BabyTrackerApp());
}

class BabyTrackerApp extends StatefulWidget {
  const BabyTrackerApp({super.key});

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

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      VeriYonetici.setDarkMode(_themeMode == ThemeMode.dark);
    });
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bebek Takip',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
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
      _showAddMenu();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScreen(onSaved: _refresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(key: ValueKey('home_$_refreshKey')),
      ActivitiesScreen(key: ValueKey('activities_$_refreshKey')),
      const SizedBox(),
      MilestonesScreen(key: ValueKey('milestones_$_refreshKey')),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x1A000000),
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
                _buildNavItem(3, Icons.emoji_events_rounded, Dil.navGelisim),
                _buildNavItem(4, Icons.settings_outlined, Dil.navAyarlar),
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
                ? const Color(0xFFE91E63)
                : (isDark ? Colors.grey.shade400 : Colors.grey),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? const Color(0xFFE91E63)
                  : (isDark ? Colors.grey.shade400 : Colors.grey),
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
        decoration: const BoxDecoration(
          color: Color(0xFFE91E63),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x40E91E63),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
