import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/events_page.dart';
import 'pages/profile_page.dart';
import 'pages/boosts_page.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';
import 'services/push_service.dart';
import 'config/supabase_options.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Empêche le crash si les clés ne sont pas fournies.
  final url = SupabaseOptions.resolvedUrl;
  final key = SupabaseOptions.resolvedAnonKey;
  if (url.isEmpty || key.isEmpty) {
    throw PlatformException(
        code: 'missing-supabase-keys',
        message:
            'Définis SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define ou dans lib/config/supabase_options.dart');
  }
  await SupabaseService.init(url: url, anonKey: key);
  // FCM n'est pas configuré pour le Web ici ; on initialise le push uniquement sur mobile.
  if (!kIsWeb) {
    await PushService.init();
  }
  runApp(const BarlyApp());
}

class BarlyApp extends StatelessWidget {
  const BarlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/map': (_) => const MapPage(),
        '/boosts': (_) => const BoostsPage(),
        '/home': (_) => const MainTabs(),
      },
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  final api = ApiService();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final token = await api.token;
    if (!mounted) return;
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F6FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_bar,
              size: 80,
              color: Color(0xFF9B7BFF),
            ),
            SizedBox(height: 20),
            Text(
              'Barly',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B7BFF),
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B7BFF)),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int index = 0;
  final pages = const [HomePage(), MapPage(), EventsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map'),
          NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Events'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/boosts'),
              label: const Text('Boosts'),
              icon: const Icon(Icons.bolt))
          : null,
    );
  }
}
