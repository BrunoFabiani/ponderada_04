import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const GameFinderApp());
}

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const gamesToPlay = '/games-to-play';
  static const recommendation = '/recommendation';
  static const profile = '/profile';
}

class GameFinderApp extends StatelessWidget {
  const GameFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeGame Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6B5C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFF7F8FA),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.gamesToPlay: (_) => const GamesToPlayScreen(),
        AppRoutes.recommendation: (_) => const RecommendationScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'FreeGame Finder',
      subtitle: 'Find free games that fit what you want to play next.',
      primaryLabel: 'Enter app',
      onPrimaryPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      secondaryLabel: 'Create account',
      onSecondaryPressed: () {
        Navigator.pushNamed(context, AppRoutes.register);
      },
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create profile',
      subtitle: 'Your profile will store your saved games and preferences.',
      primaryLabel: 'Create account',
      onPrimaryPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      secondaryLabel: 'Back to login',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.home,
      title: 'Discover',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Recommended free games',
            subtitle: 'This screen will consume the FreeToGame API.',
          ),
          const SizedBox(height: 12),
          PlaceholderCard(
            title: 'FreeToGame API list',
            subtitle:
                'Next step: load games by platform, genre and popularity.',
            icon: Icons.sports_esports,
            actionLabel: 'Open recommendation',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.recommendation);
            },
          ),
          const SizedBox(height: 12),
          PlaceholderCard(
            title: 'Saved list',
            subtitle:
                'Games selected by the user will appear in Games to Play.',
            icon: Icons.bookmark_border,
            actionLabel: 'View my list',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.gamesToPlay);
            },
          ),
        ],
      ),
    );
  }
}

class GamesToPlayScreen extends StatelessWidget {
  const GamesToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.gamesToPlay,
      title: 'Games to Play',
      child: const EmptyState(
        icon: Icons.bookmarks_outlined,
        title: 'No saved games yet',
        subtitle: 'Saved FreeToGame recommendations will be listed here.',
      ),
    );
  }
}

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.recommendation,
      title: 'Recommendation',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(
            title: 'Find my game',
            subtitle:
                'This flow will ask questions, send candidate games to the LLM and save the session.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            title: 'Akinator-style flow',
            subtitle:
                'Next step: build questions about genre, platform, play style and session length.',
            icon: Icons.psychology_alt_outlined,
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.profile,
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(
            title: 'Player profile',
            subtitle:
                'This screen will connect Supabase profile data and camera avatar upload.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            title: 'Camera avatar',
            subtitle:
                'Next step: take a photo, upload it to Supabase Storage and save avatar_url.',
            icon: Icons.photo_camera_outlined,
          ),
        ],
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String secondaryLabel;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.sports_esports,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: onPrimaryPressed,
                    child: Text(primaryLabel),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onSecondaryPressed,
                    child: Text(secondaryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.child,
  });

  final String currentRoute;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          final route = _routes[index];
          if (route != currentRoute) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int get _selectedIndex {
    final index = _routes.indexOf(currentRoute);
    return index < 0 ? 0 : index;
  }

  static const _routes = [
    AppRoutes.home,
    AppRoutes.gamesToPlay,
    AppRoutes.recommendation,
    AppRoutes.profile,
  ];
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onPressed,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
