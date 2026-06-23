import 'package:flutter/material.dart';

import '../app/app_routes.dart';

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
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          final String route = routes[index];
          if (route != currentRoute) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Descobrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Salvos',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  int get selectedIndex {
    final int index = routes.indexOf(currentRoute);
    return index < 0 ? 0 : index;
  }

  static const List<String> routes = [
    AppRoutes.home,
    AppRoutes.gamesToPlay,
    AppRoutes.recommendation,
    AppRoutes.profile,
  ];
}
