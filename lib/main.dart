import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/step_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/workout_hub_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: TechnoColors.bgSecondary,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final provider = AppProvider();
  await provider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: provider),
        ChangeNotifierProvider(create: (_) => StepProvider()),
      ],
      child: const TechnoGMApp(),
    ),
  );
}

class TechnoGMApp extends StatelessWidget {
  const TechnoGMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechnoGM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _SplashScreen();
          }
          if (!provider.hasCompletedOnboarding) {
            return const OnboardingWelcomeScreen();
          }
          return const _RootShell();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TechnoColors.bgPrimary,
      body: Center(
        child: CircularProgressIndicator(color: TechnoColors.neonCyan),
      ),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _tab = 0;

  static const _screens = [
    HomeScreen(),
    WorkoutHubScreen(),
    ExercisesScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: _NavBar(
        current: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _NavBar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      onDestinationSelected: onTap,
      height: 64,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'HOME',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'WORKOUT',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'EXERCISES',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'STATS',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'PROFILE',
        ),
      ],
    );
  }
}
