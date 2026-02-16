import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/valve_management_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/scheduling_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'services/token_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VanneControlApp()));
}

class VanneControlApp extends StatelessWidget {
  const VanneControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VanneControl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      home: const _InitialRouteDecider(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/valves': (context) => const ValveManagementScreen(),
        '/history': (context) => const HistoryScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/scheduling': (context) => const SchedulingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

/// Decides the initial route based on token check.
/// If already logged in, go straight to dashboard.
/// Otherwise, show the splash screen.
class _InitialRouteDecider extends StatefulWidget {
  const _InitialRouteDecider();

  @override
  State<_InitialRouteDecider> createState() => _InitialRouteDeciderState();
}

class _InitialRouteDeciderState extends State<_InitialRouteDecider> {
  bool _checking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await TokenManager.getInstance().isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      // Brief white screen while checking token
      return const Scaffold(
        backgroundColor: Colors.white,
      );
    }
    if (_isLoggedIn) {
      return const DashboardScreen();
    }
    return const SplashScreen();
  }
}
