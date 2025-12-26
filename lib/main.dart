import 'package:flutter/material.dart';
import 'screens/mama_screen.dart';
import 'screens/kaka_screen.dart';
import 'screens/uyku_screen.dart';
import 'screens/ninni_screen.dart';
import 'screens/anilar_screen.dart';

void main() {
  runApp(const BabyTrackerApp());
}

class BabyTrackerApp extends StatelessWidget {
  const BabyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bebek Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: const Color(0x4DE91E63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          indicatorColor: const Color(0x33E91E63),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MamaScreen(),
    KakaScreen(),
    UykuScreen(),
    NinniScreen(),
    AnilarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant),
              selectedIcon: Icon(Icons.restaurant, color: Color(0xFFE91E63)),
              label: 'Mama',
            ),
            NavigationDestination(
              icon: Icon(Icons.baby_changing_station),
              selectedIcon: Icon(
                Icons.baby_changing_station,
                color: Color(0xFFE91E63),
              ),
              label: 'Bez',
            ),
            NavigationDestination(
              icon: Icon(Icons.bedtime),
              selectedIcon: Icon(Icons.bedtime, color: Color(0xFFE91E63)),
              label: 'Uyku',
            ),
            NavigationDestination(
              icon: Icon(Icons.music_note),
              selectedIcon: Icon(Icons.music_note, color: Color(0xFFE91E63)),
              label: 'Ninni',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_album),
              selectedIcon: Icon(Icons.photo_album, color: Color(0xFFE91E63)),
              label: 'Anılar',
            ),
          ],
        ),
      ),
    );
  }
}
